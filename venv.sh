#!/bin/bash

deactivate
rm -rf venv
python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install numpy
pip install opencv-python
pip install opencv-contrib-python
pip install av
pip install python-rtsp

#pip install -r requirements.txt