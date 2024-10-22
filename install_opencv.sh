#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Log functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install OpenCV dependencies
install_opencv_dependencies() {
    log_info "Installing OpenCV system dependencies..."

    # Install required system packages
    sudo dnf install -y \
        python3-devel \
        python3-pip \
        gcc \
        gcc-c++ \
        gtk3-devel \
        qt5-qtbase-devel \
        libX11-devel \
        libXcomposite-devel \
        libXcursor-devel \
        libXdamage-devel \
        libXext-devel \
        libXfixes-devel \
        libXi-devel \
        libXinerama-devel \
        libXrandr-devel \
        libXrender-devel \
        libxshmfence-devel \
        mesa-libGL-devel \
        mesa-libGLU-devel \
        xcb-util-renderutil-devel \
        xcb-util-wm-devel \
        xcb-util-devel \
        libwayland-client-devel \
        libwayland-cursor-devel \
        libwayland-egl-devel \
        xorg-x11-server-Xvfb \
        mesa-libGL \
        mesa-libGLU \
        opencv \
        opencv-devel \
        atlas-devel \
        gstreamer1-devel \
        gstreamer1-plugins-base-devel

    log_info "System dependencies installed"
}

# Install Python packages
install_python_packages() {
    log_info "Installing Python packages..."

    # Upgrade pip
    python3 -m pip install --upgrade pip

    # Install opencv-python and related packages
    python3 -m pip install --no-cache-dir \
        numpy \
        opencv-python \
        opencv-contrib-python

    log_info "Python packages installed"
}

# Verify installation
verify_installation() {
    log_info "Verifying OpenCV installation..."

    python3 << EOF
import cv2
import numpy as np
print("OpenCV version:", cv2.__version__)
print("NumPy version:", np.__version__)
EOF

    if [ $? -eq 0 ]; then
        log_info "OpenCV installation verified successfully!"
    else
        log_error "OpenCV verification failed"
        exit 1
    fi
}

# Main installation function
main() {
    log_info "Starting OpenCV installation..."

    # Install system dependencies
    install_opencv_dependencies

    # Install Python packages
    install_python_packages

    # Verify installation
    verify_installation
}

# Run main function
main