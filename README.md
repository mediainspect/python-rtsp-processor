# RTSP Stream Processor

Real-time RTSP video stream processor with motion detection, object recognition, and analysis capabilities. Built with Python and OpenCV.

## 🚀 Features

- **RTSP Stream Handling**
  - Secure credential management
  - Automatic reconnection
  - Buffer management
  - Support for TCP/UDP protocols

- **Video Processing**
  - Motion detection
  - Object recognition
  - Frame analysis
  - Real-time statistics

- **Monitoring**
  - Performance metrics
  - Health checks
  - Processing statistics
  - Docker integration

## 📋 Prerequisites

- Python 3.7+
- FFmpeg
- OpenCV dependencies
- Docker (optional)

## 🔧 Installation

### Using pip

```bash
# Clone the repository
git clone https://github.com/yourusername/rtsp-processor.git
cd rtsp-processor

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: .\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Using Docker

```bash
# Build and run using docker-compose
docker-compose up -d

# View logs
docker-compose logs -f
```

## ⚙️ Configuration

1. Create environment file:
```bash
cp .env.template .env
```

2. Configure your settings:
```env
# RTSP Credentials
RTSP_USER=your_username
RTSP_PASSWORD=your_password

# RTSP Stream Configuration
RTSP_HOST=stream_host_ip
RTSP_PORT=554
RTSP_PATH=/stream

# Processing Configuration
MOTION_THRESHOLD=25.0
BLUR_SIZE=21
```

## 💻 Usage

### Basic Usage

```python
from rtsp_client import RTSPClient

# Initialize client
client = RTSPClient()

# Connect to stream
if client.connect():
    try:
        while True:
            frame = client.read_frame()
            # Process frame here
    finally:
        client.disconnect()
```

### With Custom Processing

```python
from video_processor import VideoProcessor

processor = VideoProcessor(
    motion_threshold=25.0,
    blur_size=21,
    min_object_size=1000
)

def process_frame(frame):
    processed_frame, stats = processor.process(frame)
    return processed_frame
```

## 🔍 Monitor and Debug

### Health Checks

Access health metrics at:
- http://localhost:8080/health
- http://localhost:8080/metrics

### Prometheus & Grafana

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

## 🛠️ Development

### Project Structure

```
rtsp-processor/
├── src/
│   ├── rtsp_client.py     # RTSP handling
│   ├── video_processor.py # Video processing
│   └── config.py         # Configuration management
├── tests/
│   └── test_*.py        # Test files
├── docker/
│   ├── Dockerfile       # Container definition
│   └── docker-compose.yml
├── .env.template        # Environment template
└── README.md           # This file
```

### Running Tests

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests
pytest
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 Versioning

We use [SemVer](http://semver.org/) for versioning. For available versions, see the [CHANGELOG.md](CHANGELOG.md).

## 🔒 Security

### Credential Handling

- Credentials stored in .env file
- Passwords never logged
- URL encoding for special characters
- Secure connection handling

### Best Practices

- Use environment variables
- Regularly update dependencies
- Follow security advisories
- Implement proper error handling

## ❗ Common Issues

1. **OpenCV Import Error**
```bash
# Install system dependencies
sudo ./install_opencv.sh
```

2. **RTSP Connection Failed**
- Verify credentials
- Check network connectivity
- Confirm stream availability

3. **Performance Issues**
- Adjust buffer size
- Modify processing parameters
- Check system resources

## 📈 Performance Tuning

### Memory Usage

```python
# Configure buffer size
client = RTSPClient(buffer_size=1024*1024)
```

### Processing Speed

```python
# Adjust processing parameters
processor = VideoProcessor(
    skip_frames=2,
    downscale_factor=0.5
)
```

## 📚 Documentation

- [API Reference](docs/API.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- OpenCV community
- FFmpeg project
- Docker community
- All contributors

## 📞 Support

For support, please:
1. Check documentation
2. Search existing issues
3. Create new issue if needed

## 🔄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for all changes.