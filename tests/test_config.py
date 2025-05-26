from mediainspect_rtsp import config

def test_config_import():
    assert hasattr(config, '__file__') or hasattr(config, '__doc__')
