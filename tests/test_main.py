from mediainspect_rtsp import main

def test_main_import():
    assert hasattr(main, '__file__') or hasattr(main, '__doc__')
