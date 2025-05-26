from mediainspect_rtsp import object_detector

def test_object_detector_import():
    assert hasattr(object_detector, '__file__') or hasattr(object_detector, '__doc__')
