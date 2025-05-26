from mediainspect_rtsp import web_rtsp_processor

def test_web_rtsp_processor_import():
    assert hasattr(web_rtsp_processor, '__file__') or hasattr(web_rtsp_processor, '__doc__')
