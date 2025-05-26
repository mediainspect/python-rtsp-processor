from mediainspect_rtsp import init

def test_init_import():
    assert hasattr(init, '__file__') or hasattr(init, '__doc__')
