"""
Core network scanning functionality.
"""
import asyncio
import time
from typing import List, Dict, Any, Optional

from . import models


class SimpleNetworkScanner:
    """Simple network scanner that doesn't require root privileges."""
    
    COMMON_PORTS = {
        'rtsp': [554, 8554],
        'http': [80, 8080, 8000, 8888],
        'https': [443, 8443],
        'ssh': [22],
        'vnc': [5900, 5901],
        'rdp': [3389],
        'mqtt': [1883],
        'mqtts': [8883]
    }
    
    def __init__(self, timeout: float = 2.0):
        """Initialize the scanner with connection timeout."""
        self.timeout = timeout
    
    async def check_port(self, ip: str, port: int) -> bool:
        """Check if a port is open."""
        try:
            reader, writer = await asyncio.wait_for(
                asyncio.open_connection(ip, port),
                timeout=self.timeout
            )
            writer.close()
            await writer.wait_closed()
            return True
        except (asyncio.TimeoutError, ConnectionRefusedError, OSError, ConnectionResetError):
            return False
    
    async def identify_service(self, ip: str, port: int) -> Dict[str, Any]:
        """Identify service running on the port."""
        # First check common ports
        for service, ports in self.COMMON_PORTS.items():
            if port in ports:
                return {
                    'service': service,
                    'protocol': 'tcp',
                    'banner': '',
                    'secure': service.endswith('s')
                }
        
        # Try to grab banner for unknown ports
        try:
            reader, writer = await asyncio.wait_for(
                asyncio.open_connection(ip, port),
                timeout=self.timeout
            )
            
            # Try to read banner if possible
            try:
                banner = await asyncio.wait_for(reader.read(1024), timeout=1.0)
                banner = banner.decode('utf-8', errors='ignore').strip()
            except (asyncio.TimeoutError, UnicodeDecodeError):
                banner = ''
                
            writer.close()
            await writer.wait_closed()
            
            return {
                'service': 'unknown',
                'protocol': 'tcp',
                'banner': banner,
                'secure': False
            }
            
        except (asyncio.TimeoutError, ConnectionRefusedError, OSError, ConnectionResetError):
            return {
                'service': 'unknown',
                'protocol': 'tcp',
                'banner': '',
                'secure': False
            }
    
    async def scan_port(self, ip: str, port: int) -> models.NetworkService:
        """
        Scan a single port and return service information.
        
        Args:
            ip: IP address to scan
            port: Port number to scan
            
        Returns:
            NetworkService object with scan results
        """
        is_open = await self.check_port(ip, port)
        if not is_open:
            return models.NetworkService(ip=ip, port=port, is_up=False)
            
        service_info = await self.identify_service(ip, port)
        
        return models.NetworkService(
            ip=ip,
            port=port,
            service=service_info['service'],
            protocol=service_info['protocol'],
            banner=service_info['banner'],
            is_secure=service_info['secure'],
            is_up=True
        )
    
    async def scan_ports(self, ip: str, ports: List[int]) -> models.ScanResult:
        """
        Scan multiple ports concurrently.
        
        Args:
            ip: IP address to scan
            ports: List of port numbers to scan
            
        Returns:
            ScanResult object with scan results
        """
        start_time = time.monotonic()
        tasks = [self.scan_port(ip, port) for port in ports]
        services = await asyncio.gather(*tasks, return_exceptions=False)
        duration = time.monotonic() - start_time
        
        return models.ScanResult(
            services=services,
            duration=duration
        )
    
    async def scan_common_ports(self, ip: str) -> models.ScanResult:
        """
        Scan all common ports for a given IP.
        
        Args:
            ip: IP address to scan
            
        Returns:
            ScanResult object with scan results
        """
        # Flatten the list of common ports
        ports = [port for port_list in self.COMMON_PORTS.values() for port in port_list]
        return await self.scan_ports(ip, ports)
