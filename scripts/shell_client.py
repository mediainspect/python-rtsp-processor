"""
Shell client for mediainspect-rtsp
Starts an interactive Python shell with project context.
"""
import code
import sys

banner = """
🐚 Welcome to the mediainspect-rtsp shell!
You have access to the package context. Example:
>>> import mediainspect_rtsp
"""

namespace = {}
try:
    import mediainspect_rtsp
    namespace['mediainspect_rtsp'] = mediainspect_rtsp
except ImportError:
    pass

code.interact(banner=banner, local=namespace)
