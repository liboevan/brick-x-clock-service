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
- Port 17003/TCP available for API
- `jq` (optional, for JSON formatting in tests)

## 🛠️ Quick Start

### Option 1: One-Command Setup (Recommended)

```bash
./scripts/quick_start.sh
```

This script performs a complete build → run → test cycle.

### Option 2: Step-by-Step Setup

```bash
# Build the Docker image
./scripts/build.sh

# Run the container
./scripts/run.sh

# Test the API endpoints
./scripts/test.sh
```

## 📚 Scripts Reference

### Main Management Script

```bash
./scripts/quick_start.sh [command] [version]
```

**Commands:**
- `build` - Build Docker image only
- `run` - Run container only  
- `test` - Test API endpoints only
- `clean` - Stop and remove containers
- `logs` - Show container logs
- `status` - Check container status
- `all` - Full cycle (default)

**Examples:**
```bash
./scripts/quick_start.sh                    # Full cycle with default version
./scripts/quick_start.sh test               # Test only
./scripts/quick_start.sh all 1.0.0         # Full cycle with specific version
```

### Individual Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `build.sh` | Build Docker image | `./scripts/build.sh [version]` |
| `run.sh` | Start container | `./scripts/run.sh [version]` |
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
curl http://localhost:17003/health
# Response: OK
```

**Version Information:**
```bash
curl http://localhost:17003/version
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
curl http://localhost:17003/status
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
curl -X PUT http://localhost:17003/servers \
  -H "Content-Type: application/json" \
  -d '{"servers": ["pool.ntp.org", "time.google.com"]}'
```

**Server Mode Control:**
```bash
# Enable server mode
curl -X PUT http://localhost:17003/server-mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}'

# Disable server mode
curl -X PUT http://localhost:17003/server-mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}'
```

## 🔧 Configuration

### Environment Variables
- `TZ=UTC` - Timezone setting
- `NTP_SERVERS` - Default NTP servers (space-separated)

### Ports
- **123/UDP** - NTP protocol port
- **17003/TCP** - HTTP API port

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
   
   # Stop existing NTP service
   sudo systemctl stop ntp
   ```

2. **Container Won't Start**
   ```bash
   # Check image
   docker images | grep brick-x-clock
   
   # View logs
   ./scripts/run.sh logs
   ```

3. **Synchronization Issues**
   ```bash
   # Check NTP status
   curl http://localhost:17003/status
   
   # Test with different servers
   curl -X PUT http://localhost:17003/servers \
     -H "Content-Type: application/json" \
     -d '{"servers": ["time.google.com"]}'
   ```

### Debug Commands
```bash
# Check container status
./scripts/run.sh status

# View detailed logs
./scripts/run.sh logs -f

# Test health check
curl http://localhost:17003/health

# Check NTP synchronization
curl http://localhost:17003/status?flags=1
```

## 🎯 Best Practices

1. **Use reliable NTP servers** - Choose stable, low-latency servers
2. **Monitor synchronization** - Regularly check status endpoints
3. **Configure timezone** - Set appropriate TZ environment variable
4. **Backup configuration** - Save custom server configurations
5. **Monitor logs** - Use `./scripts/run.sh logs` to view output

## 📞 Support

For issues or questions:
1. Check service status: `./scripts/run.sh status`
2. View service logs: `./scripts/run.sh logs`
3. Test NTP synchronization: `curl http://localhost:17003/status`
4. Verify port availability: `sudo lsof -i :123`
5. Check container details: `docker inspect el-brick-x-clock` 