# SCOPE: track centroid using simple Euclidean distances

import argparse
import os, glob
from natsort import natsorted as nts
import numpy as np
import cv2
import tkinter as tk
from tkinter import simpledialog
from centroidtracker import CentroidTracker



def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument("-d", "--path-to-data", help="path to annotation files", default = "/home/analysis-of-ONC-video-data/back_up")
    #ap.add_argument('-c', '--n-classes', type = int, default = 1, help = "number of classes")
    ap.add_argument('-m', '--max-skip', type = int, default = 2, help = "max skipped empty frames before deleting id. Increase for videos with higher time resolution.")
    ap.add_argument('-f','--conf-tresh', type = float, default = 0.8, help = "discard rows below this confidence treshold")
    ap.add_argument('-e', '--empty-frames', help = "include empty frames", action='store_true')    
    ap.add_argument('-o', '--outname', type = str, default = "/home/analysis-of-ONC-video-data/ONC_video_tracks", help = "path of txt file with count outcomes")
    ap.add_argument('-w', '--write-raw', help = "write raw centroids only", action='store_true')
    ap.add_argument('-v', '--video-show', help = "only show video", action='store_true')
    ap.add_argument('-s', '--save-video', help = "save video tracking", action='store_true')
    ap.add_argument('-n', '--video-name', type = str, default = "example", help = "name of saved video")
    args = ap.parse_args()
    return args


def xywh_to_box(x:float, y:float, w:float, h:float) -> np.array:
    """Convert xywh YOLO coordinates into xmin, ymin, xmax, ymax
    """
    hw = w/2
    hh = h/2
    xmin = x - hw
    ymin = y - hh
    xmax = x + hw
    ymax = y + hh
    box = np.array([xmin, ymin, xmax, ymax])
    return box
    

def get_video_info(path_to_video_labels: str)-> list:
    """Get frame shape and number of frames in video
    """    
    path = os.path.split(path_to_video_labels)[0]
    path_to_video = glob.glob(os.path.join(path, "*.mp4"))[0]   # must be one video !!!
    vcap = cv2.VideoCapture(path_to_video)
    if vcap.isOpened():
        dw  = vcap.get(3)  # float `width`
        dh = vcap.get(4)   # float `height`
        nr_frames = int(vcap.get(cv2.CAP_PROP_FRAME_COUNT))
    vcap.release()
    try:
        out = [np.array([dw, dh, dw, dh]), nr_frames]
    except UnboundLocalError:
        print('UnboundLocalError in ' + path_to_video_labels)
        raise UnboundLocalError(' ')
    return(out)

def get_time_info(path_to_video_labels: str) -> str:
    mainpath = os.path.split(path_to_video_labels)[0]
    vpath = glob.glob(os.path.join(mainpath, "*mp4"))[0]
    filesize = os.path.getsize(vpath)/1e6      # in Mb
    name = os.path.split(vpath)[1].split("_")
    datetime = os.path.splitext(name[-1])[0] # last split        
    device = name[0]
    year = datetime[0:4]
    month = datetime[4:6]
    day = datetime[6:8]
    hour = datetime[9:11]
    minute = datetime[11:13]
    second = datetime[13:15]
    one_line = ' '.join([str(filesize), device, year, month, day, hour, minute, second])   
    return one_line

def include_empty_frames(path_to_video_labels: str, empty_frames: bool) -> list:    
    """Return file-name sequence of YOLO txt frame detections, including empty frames (onnly one video data)
    """    
    full_frames = nts(glob.glob(os.path.join(path_to_video_labels, "*.txt")))    # maybe empty
    if len(full_frames) < 1:     # then no detections occurred
        return []
    if empty_frames:
        frame_nr = []
        for txt in full_frames:
            nr = os.path.splitext(txt)[0].split("_")[-1]
            frame_nr.append(int(nr))
        _, last_frame = get_video_info(path_to_video_labels)
        all_nr = [str(x) for x in range(1, last_frame + 1)]
        main_name = '_'.join(os.path.splitext(full_frames[0])[0].split("_")[:-1])        
        all_frames = []
        for i in all_nr:
            out = main_name + "_" + i + ".txt"
            all_frames.append(out)                                # empty frames are not files   
    else:
        all_frames = full_frames
    return(all_frames)                       


def get_boxes(path_to_video_labels: str, conf_tresh: float, empty_frames: bool) -> list:
    """Get all boxes in each frame
    """        
    img_shape, _ = get_video_info(path_to_video_labels)     # grab frame shape 
    all_frames = include_empty_frames(path_to_video_labels, empty_frames)                     # full + empty frames
    if len(all_frames) < 1:
        return []
    frames = []
    for f in all_frames:
        boxes = []    
        if os.path.isfile(f):                          
            with open(f) as obj:                    
                for i in obj:
                    x, y, w, h, tresh = i.split(' ')[1:6]       # TODO add class loop
                    if float(tresh) < conf_tresh:
                        continue
                    else:                            
                        b = xywh_to_box(float(x), float(y), float(w), float(h))
                        b = b*img_shape                             # must convert into pixel val
                        boxes.append(b.astype("int"))
        frames.append(boxes)
    return frames


def track_boxes_frame_by_frame(path_to_video_labels: str, conf_tresh: float, max_skip: int, empty_frames: bool) -> list:
    
    ################ 17.6.2021 temporary workaround to address high FP in AXIS
    time_info = get_time_info(path_to_video_labels)
    filesize = time_info.split(' ')[0]
    device = time_info.split(' ')[1]
    if device.startswith("AXIS"):
        conf_tresh = 0.95
    if float(filesize) > 50:
        max_skip = 40
    ###############################################################
    
    frames = get_boxes(path_to_video_labels, conf_tresh, empty_frames)
    if len(frames) < 1:
        return [[], [], 0, 0]
    ct = CentroidTracker(maxDisappeared = max_skip)              # initialize progrmam and track     
    ids = []
    centroids = []
    fr_num = []
    for frame in frames:
        objects = ct.update(frame)
        if len(frame) > 0:
                is_full = True
        else:
                is_full = False
        fr_num.append(is_full)
        for (ID, centroid) in objects.items():
                ids.append(str(ID))
                centroids.append(centroid)
    return [ids, centroids, fr_num, len(set(ids))]



def track_boxes_frame_by_frame_video_show(path_to_video_labels: str, conf_tresh: float, max_skip: int, empty_frames: bool, save_video: bool, video_name: str) -> None:
    rects = get_boxes(path_to_video_labels, conf_tresh, empty_frames)
    if len(rects) < 1:
        print('No bounding boxes detected = Zero counts')
        return             
    ct = CentroidTracker(maxDisappeared = max_skip)             # initialize progrmam and track     
    path = os.path.split(path_to_video_labels)[0]
    path_to_video = glob.glob(os.path.join(path, "*.mp4"))[0]   # must be one video !!!
    vcap = cv2.VideoCapture(path_to_video)
    if save_video:
        vout = cv2.VideoWriter(video_name + ".mp4", cv2.VideoWriter_fourcc(*'mp4v'),
                           vcap.get(cv2.CAP_PROP_FPS),
                           (round(vcap.get(cv2.CAP_PROP_FRAME_WIDTH)),
                            round(vcap.get(cv2.CAP_PROP_FRAME_HEIGHT)) ))
    for (i, rect) in enumerate(rects):
        _, frame = vcap.read()
        objects = ct.update(rect)
        for (ID, centroid) in objects.items():
                text = "ID " + str(ID)
                cv2.putText(frame, text, (centroid[0] - 10, centroid[1] - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
                cv2.circle(frame, (centroid[0], centroid[1]), 4, (0, 255, 0), -1)
        cv2.imshow("Frame", frame)
        if save_video:
            vout.write(frame)
        key = cv2.waitKey(1) & 0xFF
        if key == ord("q"):
                break
    vcap.release()
    cv2.destroyAllWindows()


def write_raw_boxes(path_to_video_labels: str, conf_tresh: float, empty_frames: bool, outfile: str) -> None:
    """Get all boxes in each frame 
    """
    video_tag = os.path.split(os.path.split(path_to_video_labels)[0])[1]     
    all_frames = include_empty_frames(path_to_video_labels, empty_frames)                     # full + empty frames
    frames = []
    for (i, f) in enumerate(all_frames):            
        if os.path.isfile(f):                          
            with open(f) as obj:                    
                for j in obj:
                    x, y, _, _, tresh = j.split(' ')[1:6]       # TODO add class loop
                    if float(tresh) < conf_tresh:
                        out = ' '.join([video_tag, str(i), "NA","NA","NA", "\n"])    # TODO: adding bits here ...think about just continuing
                    else:
                        out = ' '.join([video_tag,str(i),x,y,tresh])   # has already \n
                    frames.append(out)
        else:
            frames.append(' '.join([video_tag, str(i), "NA","NA","NA", "\n"]))
    with open(outfile, 'a') as of:
        of.write(''.join(frames))
        


def track_boxes_video_by_video(path_to_data: str, conf_tresh: float, max_skip: int, empty_frames: bool, outname: str, write_raw: bool) -> None:
    """for each YOLO video (exp*) counts total tracks ID (one record).
       It writes a txt file with this information.
    """
    outfile = outname + ".txt"
    if os.path.exists(outfile):
        os.remove(outfile)                                  # must remove if exists, otherwise it will append            
    all_videos = glob.glob(os.path.join(path_to_data, "exp*"))
    if write_raw:
        for d in all_videos:
            path_to_video_labels = os.path.join(d, "labels")
            write_raw_boxes(path_to_video_labels, conf_tresh, empty_frames, outfile)        
    else:
        all_lines = []                                          # info from all videos
        for d in all_videos:
            video_tag = os.path.split(d)[1]      
            path_to_video_labels = os.path.join(d, "labels")
            time_info = get_time_info(path_to_video_labels)
            _, _, _, counts = track_boxes_frame_by_frame(path_to_video_labels, conf_tresh, max_skip, empty_frames)
            line = ' '.join([video_tag, time_info, str(counts) + "\n"])     # one record tab separated
            all_lines.append(line)
        with open(outfile, 'a') as out:
            for line in all_lines:
                out.write(line)


def track_boxes(path_to_data: str, conf_tresh: float, max_skip: int, empty_frames: bool,  outname: str, write_raw: bool, video_show: bool, save_video: bool, video_name: str) -> None:
        if video_show:
                print("Showing tracking into one predefined video ...")
                all_videos = nts(glob.glob(os.path.join(path_to_data, "exp*")))
                path_to_video_labels = []
                for d in all_videos:
                        video_tag = os.path.split(d)[1]
                        path_to_video_labels.append(os.path.join(d, "labels"))
                N = len(path_to_video_labels)
                window = tk.Tk()
                window.geometry("580x400+300+200")
                mess = "Please enter an integer between 1 and {}".format(N) 
                answer = simpledialog.askinteger("Choose one video by ID number", mess, parent=window, minvalue=0, maxvalue=N)
                chosen = path_to_video_labels[answer-1]
                track_boxes_frame_by_frame_video_show(chosen, conf_tresh, max_skip, empty_frames, save_video, video_name)
        else:
                print("Counting objects in all videos and returning a txt file ...")
                track_boxes_video_by_video(path_to_data, conf_tresh, max_skip, empty_frames, outname, write_raw)
                
                

def do_func(args):
    track_boxes(args.path_to_data, args.conf_tresh, args.max_skip, args.empty_frames, args.outname, args.write_raw, args.video_show, args.save_video, args.video_name)
    
if __name__ == "__main__":
    args = parse_args()
    do_func(args)



