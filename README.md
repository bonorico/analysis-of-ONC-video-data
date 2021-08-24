# analysis-of-ONC-video-data
This pipeline describes the automatic processesing of ONC video data from an observational study to obtain sablefish count time series.  

## Instructions
The code is run via Linux Terminal (Ubuntu 20). 

### Requirements
- Python3 (>= 3.6), R (>= 3)
- We suggest creating a python [virtual environment](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/), say in `~/venv`, where all python requirements are installed.  
- Activate venv. Do all steps below while venv is activated.
- Install YOLO, say in `~/`

```
cd
git clone https://github.com/ultralytics/yolov5
cd yolov5
pip install -r requirements.txt

```
- Install ONC library (always venv on)

```
pip install onc

```

- Get your ONC token to access ONC data-archives by logging in to your [ONC Oceans 2.0 account ](https://data.oceannetworks.ca/), if you already have one, or register to set up one.
- In your account go in the tab 'Profile' (top-right corner by your profile name) and click on 'Web Services API'. Your token will be there.

- Clone repository containing Python, R, and other files for running the detection/counting analysis and for producing the time-series output.
```
cd 
git clone https://github.com/bonorico/analysis-of-ONC-video-data.git

```

### Analysis

Always in Terminal and with venv on. Run the following commands. Beware: considerable disk space and computing time is required. If you have ssh access to a remote machine, you can also run the command in [nohup mode](https://en.wikipedia.org/wiki/Nohup).  

- Dowload data (Beware: about 1 Tb of disk space needed !)

```
cd analysis-of-ONC-video-data



```

- Reduce size of downloaded data

```
pip install onc

```
- Perform automatic detection on reduced data using trained YOLO model (Beware: computing time will last few days !)

```
pip install onc

```

- Back-up YOLO results otheriwise they can be overwritten in their original folder

```
pip install onc

```

- Perform tracking on YOLO detections (allows for robustness analysis by varying parameter "m")
```
pip install onc

```
- Run R script to print time-series

```
pip install onc

```
- Done ! You have spared yourself visualization of over 650 hours of video material and manual counting of over 200000 sablefishes ! You can be grateful ;)
