"""
Data models for network scanning functionality.
"""
from dataclasses import dataclass
from typing import Dict, List, Optional


@dataclass
class NetworkService:
    """Represents a discovered network service."""
    ip: str
    port: int
    service: str = "unknown"
    protocol: str = "tcp"
    banner: str = ""
    is_secure: bool = False
    is_up: bool = True


class ScanResult:
    """Container for scan results with additional metadata."""
    
    def __init__(self, services: List[NetworkService], duration: float):
        self.services = services
        self.duration = duration
        self.total_ports = len(services)
        self.open_ports = len([s for s in services if s.is_up])
    
    def to_dict(self) -> Dict:
        """Convert results to a dictionary."""
        return {
            'duration': self.duration,
            'total_ports': self.total_ports,
            'open_ports': self.open_ports,
            'services': [
                {
                    'ip': s.ip,
                    'port': s.port,
                    'service': s.service,
                    'protocol': s.protocol,
                    'is_secure': s.is_secure,
                    'banner': s.banner
                }
                for s in self.services
            ]
        }
