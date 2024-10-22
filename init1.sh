#!/bin/bash

install_requirements() {
    log_info "Installing Python requirements..."
    
    # Create requirements.txt
    cat > requirements.txt << EOL
opencv-python>=4.8.0
av>=10.0.0
numpy>=1.24.0
python-rtsp>=0.1.4
typing-extensions>=4.5.0
dataclasses>=0.6
EOL
    
    # Install requirements with pip
    pip install --no-cache-dir -r requirements.txt
    
    # Verify imports
    log_info "Verifying Python package installation..."
    python3 -c "
import cv2
import av
import numpy
print('OpenCV version:', cv2.__version__)
print('PyAV version:', av.__version__)
print('NumPy version:', numpy.__version__)
"
    
    if [ $? -eq 0 ]; then
        log_info "Python packages installed and verified successfully"
    else
        log_error "Python package verification failed"
        exit 1
    fi
}