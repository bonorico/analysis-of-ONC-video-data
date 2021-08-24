# analysis-of-ONC-video-data
This pipeline describes the automatic processesing of ONC video data collected during an observational study in Barkley Canyon (off Vancouver Island) over a four months period and consisting of short video clips recorded hourly at three different Canyon sites. The pipeline consists of automatically detecting and counting sablefishes appearing in the videos and obtaining the respective count time series.  

## Instructions
The code is run via Linux Terminal, CentOS Linux release 8.3.2011, on a Intel(R) Core(TM) i7-4800MQ CPU @ 2.70GHz. Equally an Ubuntu 20 OS can be used on other hardware specific. No paralell computations are performed. 
 

### Requirements
- Python3 (>= 3.6), R (>= 3)
- We suggest creating a python [virtual environment](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/), say in `~/venv`, where all python requirements are installed.  
- Activate venv. Do all steps below while venv is activated.
- Install YOLO, say in `~/`

```cd
git clone https://github.com/ultralytics/yolov5
cd yolov5
pip install -r requirements.txt
```
- Install ONC library (always venv on)

```pip install onc
```

- Get your ONC **token** to access ONC data-archives by logging in to your [ONC Oceans 2.0 account ](https://data.oceannetworks.ca/), if you already have one, or register to set up one.
- In your account go in the tab 'Profile' (top-right corner by your profile name) and click on 'Web Services API'. Your token will be there.

- Clone repository containing Python, R, and other files for running the detection/counting analysis and for producing the time-series output.
```cd 
git clone https://github.com/bonorico/analysis-of-ONC-video-data.git
```

### Analysis pipeline

Always in Terminal and with venv on. Run the following commands. Beware: considerable disk space and computing time is required. If you have ssh access to a remote machine, you can also run the command in [nohup mode](https://en.wikipedia.org/wiki/Nohup).  

- Dowload data (**Beware**: about 1 Tb of disk space needed !). You need to give your token as argument to -t

```cd analysis-of-ONC-video-data
python3 block_download.py -t <your_toke_here>
```

- Reduce size of downloaded data. Adjust paths if needed. For help do python3 block_process.py  --h

```python3 block_process.py 
```
- Perform automatic detection on reduced data using a trained YOLO model (**Beware**: computing time will last few days !). Adjust paths if needed. Flag -d stands for "detection only"

```python3 block_process.py -d 
```

- Back-up YOLO results otheriwise they can be overwritten in their original folder. Adjust paths if needed. Cp can take time.

```cp -r /home/yolov5/runs/detect/* back_up/
```

- Perform a tracking algorithm on YOLO detections to obtain counts. Running time can last up to a hour.

```python3 track_centroid_euclidean.py -e
```
- Also do a robustness analysis by varying parameter "m"

```python3 track_centroid_euclidean.py -e -m 3 -o /home/federico/ONC_video_tracks_m3
```

- Run R script to print count time-series

```
pip install onc

```
- Done ! You have spared yourself visualization of over 650 hours of video material and manual counting of over 200000 sablefishes ! You can be happy ;)
