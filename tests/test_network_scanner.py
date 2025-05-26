import pytest
import asyncio
from mediainspect_rtsp.network import SimpleNetworkScanner, NetworkService


def test_simple_network_scanner_import():
    assert hasattr(SimpleNetworkScanner, 'scan_port'), "SimpleNetworkScanner should have scan_port method"


def test_network_service_dataclass():
    """Test that NetworkService dataclass works as expected"""
    service = NetworkService(ip="127.0.0.1", port=80, service="http", is_up=True)
    assert service.ip == "127.0.0.1"
    assert service.port == 80
    assert service.service == "http"
    assert service.is_up is True


@pytest.mark.asyncio
async def test_scan_port_localhost():
    """Test scanning a port (using localhost as a safe target)"""
    scanner = SimpleNetworkScanner()
    # Test a port that should be closed
    result = await scanner.scan_port("127.0.0.1", 9999)
    assert isinstance(result, NetworkService)
    assert result.port == 9999
    assert result.is_up is False


@pytest.mark.asyncio
async def test_common_ports_definition():
    """Test that common ports are defined"""
    scanner = SimpleNetworkScanner()
    assert hasattr(scanner, 'COMMON_PORTS')
    assert isinstance(scanner.COMMON_PORTS, dict)
    assert 'http' in scanner.COMMON_PORTS
    assert 80 in scanner.COMMON_PORTS['http']


def test_parse_ports():
    """Test the parse_ports utility function"""
    from mediainspect_rtsp.simple_network_scanner import parse_ports
    
    # Test single port
    assert parse_ports("80") == [80]
    
    # Test multiple ports
    assert sorted(parse_ports("80,443,8080")) == [80, 443, 8080]
    
    # Test range
    assert parse_ports("8080-8082") == [8080, 8081, 8082]
    
    # Test mixed
    assert sorted(parse_ports("80,443,8080-8082")) == [80, 443, 8080, 8081, 8082]
