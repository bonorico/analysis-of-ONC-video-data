import os, glob
from datetime import datetime, timedelta
from dateutil.parser import parse
from onc.onc import ONC
import subprocess as sb
import argparse

def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('-c','--cameras', nargs='+', default = ["DRAGONFISHSUBC13112", "SUBC1CAMMK5_15548", "AXISCAM00408CB52C86"], help="device codes")
    ap.add_argument("-p", "--python-bin", type = str, help="path to python bin", default = "/home/venv/bin/python3")
    ap.add_argument("-y", "--yolov5", type = str, help="path to yolov5", default = "/home/yolov5")
    ap.add_argument("-w", "--weights", type = str, help="path to yolov5 weigths", default = "/home/analysis-of-ONC-video-data/yolov5s_newdata_plus_connordata_0.pt")
    ap.add_argument("-t", "--run-timeout", type = float, default = 60*60*20)
    ap.add_argument('-d', '--only-detect', help = "only detection", action='store_true')

 
    args = ap.parse_args()
    return args


def block_reduce(cameras: list, python_bin: str, run_timeout: float) -> None:
    
    for i in cameras:
        data_folder = os.path.join(os.getcwd(), i)
        res_list = glob.glob(os.path.join(data_folder, "*.mp4"))
        if len(res_list) > 0:                
            for f in res_list:
                cmd_reduce = [python_bin, "lower_resol_video.py", "-d", f, "-w"]
                sb.run(cmd_reduce, timeout = run_timeout)
                # check that reduction occurred
                fsize = os.path.getsize(f)/1e6   # in Mb
                if fsize > 50:
                    print(f)
                    ValueError('File too big (' + f + '). No reduction occurred. I am stopping.')
    return


def block_detect(cameras: list, python_bin: str, yolov5: str, weights: str, run_timeout: float) -> None:
    
    for i in cameras:
        data_folder = os.path.join(os.getcwd(), i)
        res_list = glob.glob(os.path.join(data_folder, "*.mp4"))
        if len(res_list) > 0:                
            for f in res_list:                
                cmd_detect = ["python3", "detect.py", "--weights", weights, "--source", f, "--save-txt", "--save-conf"]
                sb.run(cmd_detect, cwd = yolov5, timeout = run_timeout)
                os.remove(f)                    
    return


def data_process_pipeline(cameras: list, python_bin: str, yolov5: str, weights: str, run_timeout: float, only_detect: bool) -> None:
    if not only_detect:
        block_reduce(cameras, python_bin, run_timeout)
    else:
        block_detect(cameras, python_bin, yolov5, weights, run_timeout)
    return

def do_func(args):
    data_process_pipeline(args.cameras, args.python_bin, args.yolov5, args.weights, args.run_timeout, args.only_detect)


if __name__ == "__main__":
    args = parse_args()
    do_func(args)



