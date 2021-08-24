import os
from datetime import datetime, timedelta
from dateutil.parser import parse
from onc.onc import ONC
import subprocess as sb
import argparse

def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('-t','--mytoken', type = str, required = True)
    ap.add_argument('-s','--datefrom', type = str, default = "2019-09-17T23:04:00.000Z")
    ap.add_argument('-e','--dateto', type = str, default = "2020-02-28T00:00:00.000Z")
    ap.add_argument('-c','--cameras', nargs='+', default = ["DRAGONFISHSUBC13112", "SUBC1CAMMK5_15548", "AXISCAM00408CB52C86"], help="device codes")
  )
 
    args = ap.parse_args()
    return args


def data_process_pipeline(mytoken: str, cameras: list, datefrom: str, dateto: str) -> None:

    
    for i in cameras:
        os.mkdir("./" + i)
        onc = ONC(token = mytoken, outPath = "./" + i)
        filters = {
        "dataProductCode" : 'MP4V', 
        "deviceCode" : i,
        "dateFrom" : datefrom,
        "dateTo" : dateto,
        "extension" : "mp4"}

        request_info = onc.requestDataProduct(filters)
        print("From device: " + str(i) + "\n")
        print(request_info["fileSize"])

        res_list = onc.getListByDevice(filters, allPages=True)["files"]
        print(len(res_list))

        if len(res_list) > 0:
            failed = []                           
            for (j, f) in enumerate(res_list):
                try:
                    out = onc.getFile(f)
                except Exception:
                    failed.append(f)
                    
                with open("./failed.txt", 'w') as log:
                    for i in failed:
                        log.write(i)
                    

    return

def do_func(args):
    data_process_pipeline(args.mytoken, args.cameras, args.datefrom, args.dateto)


if __name__ == "__main__":
    args = parse_args()
    do_func(args)
