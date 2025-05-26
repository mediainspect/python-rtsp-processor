from mediainspect_rtsp import rtsp_client

def test_rtsp_client_import():
    assert hasattr(rtsp_client, '__file__') or hasattr(rtsp_client, '__doc__')
