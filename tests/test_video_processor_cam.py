from mediainspect_rtsp import video_processor_cam

def test_video_processor_cam_import():
    assert hasattr(video_processor_cam, '__file__') or hasattr(video_processor_cam, '__doc__')
