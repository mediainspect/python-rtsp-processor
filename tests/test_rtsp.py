from mediainspect_rtsp import rtsp

def test_rtsp_import():
    assert hasattr(rtsp, '__file__') or hasattr(rtsp, '__doc__')
