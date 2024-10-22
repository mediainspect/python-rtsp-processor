#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log levels
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root (use sudo)"
        exit 1
    fi
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    log_info "Detected OS: $OS (Version: $VERSION)"
}

# Check Python version
check_python() {
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 -c 'import sys; print("%d.%d" % (sys.version_info.major, sys.version_info.minor))')
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

        if [ "$PYTHON_MAJOR" -gt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 7 ]); then
            log_info "Python version $PYTHON_VERSION found"
            PYTHON_CMD="python3"
        else
            log_error "Python version must be 3.7 or higher (found $PYTHON_VERSION)"
            exit 1
        fi
    else
        log_error "Python 3 not found"
        exit 1
    fi
}

# Install system dependencies for Fedora
install_fedora_dependencies() {
    log_info "Installing dependencies for Fedora..."

    # Remove conflicting packages first
    log_info "Removing conflicting packages..."
    dnf remove -y libswscale-free libavcodec-free libavformat-free libavutil-free

    # Install RPM Fusion repositories
    log_info "Installing RPM Fusion repositories..."
    dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Update package list
    dnf check-update

    # Install development tools and basic dependencies
    log_info "Installing development tools and basic dependencies..."
    dnf groupinstall -y "Development Tools"
    dnf install -y \
        python3-devel \
        python3-pip \
        pkg-config \
        redhat-rpm-config

    # Install FFmpeg and related packages
    log_info "Installing FFmpeg and related packages..."
    dnf install -y --allowerasing \
        ffmpeg \
        ffmpeg-devel \
        SDL2-devel \
        libv4l-devel \
        libX11-devel \
        libXv-devel \
        openjpeg2-devel \
        libvdpau-devel \
        freetype-devel

    log_info "System dependencies installed successfully"
}

# Create virtual environment
create_venv() {
    log_info "Creating virtual environment..."
    $PYTHON_CMD -m pip install --upgrade virtualenv
    $PYTHON_CMD -m virtualenv venv

    # Activate virtual environment
    source venv/bin/activate

    log_info "Virtual environment created and activated"
}

# Install Python requirements
install_requirements() {
    log_info "Installing Python requirements..."

    # Create requirements.txt
    cat > requirements.txt << EOL
opencv-python>=4.8.0
av>=10.0.0
numpy>=1.24.0
av-ffmpeg>=6.0.0
python-rtsp>=0.1.4
typing-extensions>=4.5.0
dataclasses>=0.6
EOL

    # Install requirements with pip
    pip install --no-cache-dir -r requirements.txt

    log_info "Python requirements installed"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."

    # Check if key packages are installed
    $PYTHON_CMD << EOL
import cv2
import av
import numpy
print("OpenCV version:", cv2.__version__)
print("PyAV version:", av.__version__)
print("NumPy version:", numpy.__version__)
EOL

    if [ $? -eq 0 ]; then
        log_info "Installation verified successfully"
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Main installation function
main() {
    log_info "Starting installation..."

    # Check if running as root
    check_root

    # Install system dependencies
    install_fedora_dependencies

    # Check Python version
    check_python

    # Create virtual environment and install requirements
    create_venv
    install_requirements

    # Verify installation
    verify_installation

    log_info "Installation completed successfully!"
    log_info "To activate the virtual environment, run: source venv/bin/activate"
}

# Script execution
detect_os
main

exit 0