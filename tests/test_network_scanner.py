import pytest
from mediainspect_rtsp import network_scanner


def test_network_scanner_import():
    assert hasattr(network_scanner, 'NetworkScanner'), "NetworkScanner class should exist"


def test_network_scanner_instance():
    scanner = network_scanner.NetworkScanner()
    assert scanner is not None

# Optionally, add more tests for methods if any are available
# Example (replace with actual method names):
# def test_scan_network_returns_list():
#     scanner = network_scanner.NetworkScanner()
#     result = scanner.scan_network()
#     assert isinstance(result, list)
