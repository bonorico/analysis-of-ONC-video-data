# analysis-of-ONC-video-data
This pipeline describes automatic processesing of ONC video data to obtain sablefish count time series.  

## Instructions
The code is run via Linux Terminal (Ubuntu 20). 

```
cd 
git clone https://github.com/bonorico/analysis-of-ONC-video-data.git

```
### Requirements
- Python3 (>= 3.6), R (>= 3)
- We suggest creating a python [virtual environment](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/), say in `~/venv`, where all python requirements are installed.  
- Activate venv. Do all steps below while venv is activated.
- Install YOLO, say in `~/`.

pip requirements, ONC tokens, ...

```
cd
git clone https://github.com/ultralytics/yolov5
cd yolov5
pip install -r requirements.txt

```

