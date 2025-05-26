from mediainspect_rtsp import video_processor_rtsp

def test_video_processor_rtsp_import():
    assert hasattr(video_processor_rtsp, '__file__') or hasattr(video_processor_rtsp, '__doc__')
