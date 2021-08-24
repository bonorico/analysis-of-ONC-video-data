# SCOPE: reduces resolution (Nr frames, Nr pixels) of video
# ARGUMENTS: video_path, skip_frames (1, ,2 ..), reduce (50% of frame shape), outname, overwrite (bool, outname = inname)


import cv2 as cv
import os, glob
import imutils
import argparse


def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument("-d", "--path_to_video", help="path to video file", required = True)
    ap.add_argument('-s','--skip-by', type = int, default = 20, help = "number of frames to skip before writing one frame")
    ap.add_argument('-r', '--shrink_by', type = float, default = 0.5, help = "percent reduction in frame dimension")
    ap.add_argument('-w', '--overwrite', help = "overwrite input file", action='store_true')
    ap.add_argument("-o", "--outname", type = str, help="name of output file", default = "reducedvideo")
    args = ap.parse_args()
    return args


def reduce_video(path_to_video: str, skip_by: int, shrink_by: float, overwrite: bool, outname: str) -> None:
    vid = cv.VideoCapture(path_to_video)
    target_fps = vid.get(cv.CAP_PROP_FPS)
    target_width = round(vid.get(cv.CAP_PROP_FRAME_WIDTH)*shrink_by)
    target_height = round(vid.get(cv.CAP_PROP_FRAME_HEIGHT)*shrink_by)
    frame_count = round(vid.get(cv.CAP_PROP_FRAME_COUNT))
    outfile = os.path.join(os.getcwd(), outname + ".mp4")
    out = cv.VideoWriter(outfile, cv.VideoWriter_fourcc(*'mp4v'), target_fps, (target_width, target_height))
    ok, frame = vid.read()
    i = 0
    while ok:
        ok, frame = vid.read()
        i += 1
        if frame is None:      # important since some frames can be nontype
            continue
        if ((i % skip_by) == 0):
            frame = imutils.resize(frame, width = target_width, height = target_height)
            out.write(frame)
    if overwrite:
        os.remove(path_to_video)
        os.rename(outfile, path_to_video)
    vid.release()
    out.release()


def do_func(args):
    reduce_video(args.path_to_video, args.skip_by, args.shrink_by, args.overwrite, args.outname)

if __name__ == "__main__":
    args = parse_args()
    do_func(args)


