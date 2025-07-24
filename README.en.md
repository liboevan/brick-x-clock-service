[中文](README.md) | English

# Brick X Clock Service

A high-precision Network Time Protocol (NTP) service built with Go, providing both client and server capabilities for time synchronization in distributed systems.

## 🚀 Features

- **NTP Client Mode**: Synchronize with upstream NTP servers
- **NTP Server Mode**: Act as a time source for other devices
- **RESTful API**: Full HTTP API for monitoring and management
- **Real-time Status**: Live tracking of synchronization status
- **Server Management**: Add, remove, and configure NTP servers
- **Activity Monitoring**: Track success/failure statistics
- **Docker Ready**: Containerized deployment with Alpine Linux
- **Health Monitoring**: Built-in health checks and status endpoints
- **Caching Layer**: In-memory caching for improved performance
- **Dynamic Configuration**: Runtime server and mode configuration

## 📋 Prerequisites

- Docker and Docker Compose
- Linux environment (for NTP compatibility)
- Network access to NTP servers
- Port 123/UDP available for NTP traffic
- Port 17103/TCP available for API
- `jq` (optional, for JSON formatting in tests)

## 🛠️ Quick Start

### Option 1: One-Command Setup (Recommended)

```bash
./scripts/quick.sh
```

This script performs a complete build → run → test cycle.

### Option 2: Step-by-Step Setup

```bash
# Build the Docker image
./scripts/build.sh

# Start the container
./scripts/start.sh

# Test the API endpoints
./scripts/test.sh

# Stop the container
./scripts/stop.sh
```

## 📚 Scripts Reference

### Main Management Script

```bash
./scripts/quick.sh [command]
```

**Commands:**
- `build` - Build Docker image only
- `start` - Start container only  
- `stop` - Stop container only
- `test` - Test API endpoints only
- `clean` - Stop and remove containers and images
- `logs` - Show container logs
- `status` - Check container status
- `all` - Full cycle (default)

**Examples:**
```bash
./scripts/quick.sh                    # Full cycle
./scripts/quick.sh test               # Test only
./scripts/quick.sh all 1.0.0         # Full cycle with specific version
```

### Individual Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `build.sh` | Build Docker image | `./scripts/build.sh [version]` |
| `start.sh` | Start container | `./scripts/start.sh [--force]` |
| `stop.sh` | Stop container | `./scripts/stop.sh [--remove]` |
| `test.sh` | Test API endpoints | `./scripts/test.sh [host:port]` |
| `clean.sh` | Clean up resources | `./scripts/clean.sh [--image]` |
| `config.sh` | Configuration management | `./scripts/config.sh` |

## 🔌 API Reference

### Core Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check endpoint |
| `GET` | `/version` | Application version and build info |
| `GET` | `/app-version` | Application version info |
| `GET` | `/status` | Current synchronization status |
| `GET` | `/status/tracking` | Detailed tracking information |
| `GET` | `/status/sources` | NTP source information |
| `GET` | `/status/activity` | Activity statistics |
| `GET` | `/status/clients` | Connected client information |
| `GET` | `/servers` | List configured NTP servers |
| `PUT` | `/servers` | Configure NTP servers |
| `DELETE` | `/servers` | Reset to default servers |
| `PUT` | `/servers/default` | Set default NTP servers |
| `GET` | `/server-mode` | Get server mode status |
| `PUT` | `/server-mode` | Enable/disable server mode |

### Status Endpoint Parameters

The `/status` endpoint supports query parameters to control which data is returned:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `flags` | `1` | Include tracking data only |
| `flags` | `2` | Include sources data only |
| `flags` | `4` | Include activity data only |
| `flags` | `8` | Include clients data only |
| `flags` | `16` | Include server mode data only |
| `flags` | `23` | Include tracking + sources + activity + server mode (excludes clients) |
| `flags` | `31` | Include all data (default) |

### Request/Response Examples

**Health Check:**
```bash
curl http://localhost:17103/health
# Response: OK
```

**Version Information:**
```bash
curl http://localhost:17103/version
```

**Response:**
```json
{
  "version": "0.1.0-dev",
  "buildInfo": {
    "version": "0.1.0-dev",
    "buildDateTime": "2024-03-18T10:30:45Z",
    "buildTimestamp": 1710759045,
    "environment": "production",
    "service": "brick-x-clock",
    "description": "Brick Clock NTP Service"
  }
}
```

**Status Information:**
```bash
curl http://localhost:17103/status
```

**Response:**
```json
{
  "tracking": {
    "Reference ID": "202.118.1.130",
    "Stratum": "3",
    "Ref time (UTC)": "Mon Mar 18 10:30:45 2024",
    "System time": "0.000000000 seconds slow of NTP time",
    "Last offset": "+0.000123456 seconds",
    "RMS offset": "0.000123456 seconds",
    "Frequency": "+0.000 ppm",
    "Residual freq": "+0.000 ppm",
    "Skew": "0.000 ppm",
    "Root delay": "0.001234567 seconds",
    "Root dispersion": "0.000123456 seconds",
    "Update interval": "64.0 seconds",
    "Leap status": "Normal"
  },
  "sources": [
    {
      "state": "^",
      "name": "202.118.1.130",
      "stratum": "2",
      "poll": "6",
      "reach": "377",
      "lastrx": "19",
      "offset": "+625ms"
    }
  ],
  "activity": {
    "ok_count": "1234",
    "failed_count": "5",
    "bogus_count": "0",
    "timeout_count": "2"
  },
  "clients": [],
  "server_mode_enabled": true
}
```

**Configure Servers:**
```bash
curl -X PUT http://localhost:17103/servers \
  -H "Content-Type: application/json" \
  -d '{"servers": ["pool.ntp.org", "time.google.com"]}'
```

**Server Mode Control:**
```bash
# Enable server mode
curl -X PUT http://localhost:17103/server-mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}'

# Disable server mode
curl -X PUT http://localhost:17103/server-mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}'
```

## 🔧 Configuration

### Environment Variables
- `TZ=UTC` - Timezone setting
- `NTP_SERVERS` - Default NTP servers (space-separated)

### Ports
- **123/UDP** - NTP protocol port
- **17103/TCP** - HTTP API port

### Default NTP Servers
- `pool.ntp.org`
- `time.google.com`
- `time.windows.com`

## 🐛 Troubleshooting

### Common Issues

1. **NTP Port Already in Use**
   ```bash
   # Check port usage
   sudo lsof -i :123
   ```

2. **Container Won't Start**
   ```bash
   # Check if the Docker image exists
   docker images | grep brick-x-clock
   
   # View container logs
   docker logs brick-x-clock
   ```

3. **Synchronization Issues**
   ```bash
   # Check NTP status via API
   curl http://localhost:17103/status
   ```

### Debug Commands
```bash
# Check container status
docker ps --filter name=brick-x-clock

# View detailed logs in real-time
docker logs -f brick-x-clock

# Test health check
curl http://localhost:17103/health
```

## 📞 Support

For issues or questions:
1. Check service status: `docker ps --filter name=brick-x-clock`
2. View service logs: `docker logs brick-x-clock`
3. Test NTP synchronization: `curl http://localhost:17103/status`
4. Verify port availability: `sudo lsof -i :123`