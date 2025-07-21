[English](README.en.md) | 中文

# Brick 时钟服务

一个用 Go 构建的高精度网络时间协议 (NTP) 服务，为分布式系统提供客户端和服务器两种时间同步能力。

## 🚀 功能特性

- **NTP 客户端模式**: 与上游 NTP 服务器同步时间
- **NTP 服务器模式**: 作为其他设备的时间源
- **RESTful API**: 用于监控和管理的完整 HTTP API
- **实时状态**: 实时跟踪同步状态
- **服务器管理**: 添加、删除和配置 NTP 服务器
- **活动监控**: 跟踪成功/失败统计
- **Docker 就绪**: 使用 Alpine Linux 的容器化部署
- **健康监控**: 内置健康检查和状态端点
- **缓存层**: 内存缓存以提高性能
- **动态配置**: 运行时服务器和模式配置

## 📋 前置条件

- Docker 和 Docker Compose
- Linux 环境 (为了 NTP 兼容性)
- 对 NTP 服务器的网络访问
- 123/UDP 端口可用于 NTP 流量
- 17103/TCP 端口可用于 API
- `jq` (可选, 用于在测试中格式化 JSON)

## 🛠️ 快速开始

### 选项 1: 一键设置 (推荐)

```bash
./scripts/quick.sh
```

此脚本执行完整的构建 → 运行 → 测试周期。

### 选项 2: 分步设置

```bash
# 构建 Docker 镜像
./scripts/build.sh

# 启动容器
./scripts/start.sh

# 测试 API 端点
./scripts/test.sh

# 停止容器
./scripts/stop.sh
```

## 📚 脚本参考

### 主要管理脚本

```bash
./scripts/quick.sh [command] [version]
```

**命令:**
- `build` - 只构建 Docker 镜像
- `run` - 只运行容器
- `test` - 只测试 API 端点
- `clean` - 停止并移除容器
- `logs` - 显示容器日志
- `status` - 检查容器状态
- `all` - 完整周期 (默认)

**示例:**
```bash
./scripts/quick.sh                    # 使用默认版本完整周期
./scripts/quick.sh test               # 只测试
./scripts/quick.sh all 1.0.0         # 使用特定版本完整周期
```

### 单独脚本

| 脚本 | 用途 | 用法 |
|--------|---------|-------|
| `build.sh` | 构建 Docker 镜像 | `./scripts/build.sh [version]` |
| `start.sh` | 启动容器 | `./scripts/start.sh [--force]` |
| `stop.sh` | 停止容器 | `./scripts/stop.sh [--remove]` |
| `test.sh` | 测试 API 端点 | `./scripts/test.sh [host:port]` |
| `clean.sh` | 清理资源 | `./scripts/clean.sh [--image]` |
| `config.sh` | 配置管理 | `./scripts/config.sh` |

## 🔌 API 参考

### 核心端点

| 方法 | 端点 | 描述 |
|--------|----------|-------------|
| `GET` | `/health` | 健康检查端点 |
| `GET` | `/version` | 应用版本和构建信息 |
| `GET` | `/app-version` | 应用版本信息 |
| `GET` | `/status` | 当前同步状态 |
| `GET` | `/status/tracking` | 详细跟踪信息 |
| `GET` | `/status/sources` | NTP 源信息 |
| `GET` | `/status/activity` | 活动统计 |
| `GET` | `/status/clients` | 连接的客户端信息 |
| `GET` | `/servers` | 列出配置的 NTP 服务器 |
| `PUT` | `/servers` | 配置 NTP 服务器 |
| `DELETE` | `/servers` | 重置为默认服务器 |
| `PUT` | `/servers/default` | 设置默认 NTP 服务器 |
| `GET` | `/server-mode` | 获取服务器模式状态 |
| `PUT` | `/server-mode` | 启用/禁用服务器模式 |

### Status 端点参数

`/status` 端点支持查询参数来控制返回的数据:

| 参数 | 值 | 描述 |
|-----------|-------|-------------|
| `flags` | `1` | 只包含跟踪数据 |
| `flags` | `2` | 只包含源数据 |
| `flags` | `4` | 只包含活动数据 |
| `flags` | `8` | 只包含客户端数据 |
| `flags` | `16` | 只包含服务器模式数据 |
| `flags` | `23` | 包含跟踪 + 源 + 活动 + 服务器模式 (不包括客户端) |
| `flags` | `31` | 包含所有数据 (默认) |

### 请求/响应示例

**健康检查:**
```bash
curl http://localhost:17103/health
# 响应: OK
```

**版本信息:**
```bash
curl http://localhost:17103/version
```

**响应:**
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

**状态信息:**
```bash
curl http://localhost:17103/status
```

**响应:**
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

**配置服务器:**
```bash
curl -X PUT http://localhost:17103/servers \
  -H "Content-Type: application/json" \
  -d '{"servers": ["pool.ntp.org", "time.google.com"]}'
```

**服务器模式控制:**
```bash
# 启用服务器模式
curl -X PUT http://localhost:17103/server-mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}'

# 禁用服务器模式
curl -X PUT http://localhost:17103/server-mode \
  -H "Content-Type: application/json" \
  -d '{"enabled": false}'
```

**响应:**
```json
{
  "success": true,
  "server_mode_enabled": true
}
```

## 🔧 配置

### NTP 配置

该服务使用自定义 NTP 配置，包含以下关键设置:

```conf
# 上游 NTP 服务器
server pool.ntp.org iburst

# 允许所有客户端 (服务器模式)
allow 0.0.0.0/0

# 本地 stratum 作为备用
local stratum 10

# NTP 端口
port 123

# 日志设置
log measurements statistics tracking
```

### 环境变量

| 变量 | 默认值 | 描述 |
|----------|---------|-------------|
| `VERSION` | `0.1.0-dev` | 应用版本 |
| `BUILD_DATETIME` | 当前时间 | 构建时间戳 |
| `IMAGE_NAME` | `el/brick-x-clock` | Docker 镜像名称 |
| `CONTAINER_NAME` | `el-brick-x-clock` | Docker 容器名称 |
| `API_PORT` | `17103` | API 服务器端口 |
| `NTP_PORT` | `123` | NTP 服务器端口 |

## 🌐 网络端口

| 端口 | 协议 | 用途 |
|------|----------|---------|
| `123` | UDP | NTP 服务器/客户端流量 |
| `17103` | TCP | HTTP API 服务器 |

## 🐳 Docker 部署

### 构建镜像

```bash
./scripts/build.sh [version]
```

**示例:**
```bash
./scripts/build.sh                    # 使用默认版本构建 (0.1.0-dev)
./scripts/build.sh 1.0.0             # 使用特定版本构建
```

### 运行容器

```bash
./scripts/run.sh [version]
```

**示例:**
```bash
./scripts/run.sh                     # 使用默认版本运行
./scripts/run.sh 1.0.0              # 使用特定版本运行
```

### Docker Compose

```yaml
version: '3.8'
services:
  brick-x-clock:
    image: el/brick-x-clock:latest
    container_name: el-brick-x-clock
    ports:
      - "123:123/udp"
      - "17103:17103"
    restart: unless-stopped
    privileged: true
    volumes:
      - /etc/localtime:/etc/localtime:ro
    environment:
      - VERSION=0.1.0-dev
```

## 🔍 监控与故障排除

### 检查服务状态

```bash
# 容器状态
./scripts/quick.sh status

# 查看日志
./scripts/quick.sh logs

# 测试 API
curl http://localhost:17103/health
curl http://localhost:17103/status
```

### 常见问题

1. **端口冲突**: 确保 123/UDP 和 17103/TCP 端口可用
2. **容器无法启动**
   ```bash
   # Check image
   docker images | grep brick-x-clock
   
   # View logs
   docker logs el-brick-x-clock
   ```

3. **Synchronization Issues**

### 日志位置

- **应用日志**: Docker 容器日志
- **NTP 日志**: `/var/log/ntp/` (容器内)

### 健康检查

```bash
# 基本健康检查
curl http://localhost:17103/health

# 详细状态检查
curl http://localhost:17103/status?flags=23

# 测试所有端点
./scripts/test.sh
```

## 🏗️ 架构

### 服务组件

- **API 服务器**: 运行在 17103 端口的 Go HTTP 服务器
- **NTP 守护进程**: 运行在 123 端口的后台 NTP 服务
- **配置管理**: 动态服务器配置
- **缓存层**: 用于提高性能的内存缓存 (30秒 TTL)
- **健康监控**: 内置健康检查

### 数据流

1. **客户端请求** → API 服务器 (17103 端口)
2. **API 服务器** → NTP 守护进程 (内部通信)
3. **NTP 守护进程** → 上游 NTP 服务器 (123 端口)
4. **响应** → 通过 API 返回客户端

### 缓存策略

- **跟踪数据**: 30秒 TTL
- **源数据**: 30秒 TTL
- **活动数据**: 30秒 TTL
- **服务器模式**: 5秒 TTL
- **客户端数据**: 30秒 TTL

## 🔒 安全考虑

- **网络**: 使用 VPN 进行安全的 NTP 通信
- **认证**: 考虑实现 API 认证
- **更新**: 定期更新 NTP 以获取安全补丁
- **防火墙**: 仅限制对必要端口的访问
- **容器安全**: 以最小所需权限运行

## 🚀 性能

- **响应时间**: API 调用 < 100ms
- **内存使用**: ~50MB 容器占用
- **CPU 使用**: 正常操作期间极少
- **网络**: 高效的 NTP 包处理
- **缓存**: 减少 NTP 命令开销

## 🧪 测试

### 自动化测试

```bash
# 运行所有测试
./scripts/test.sh

# 使用自定义主机测试
./scripts/test.sh localhost:17103

# 使用远程主机测试
./scripts/test.sh api.example.com:17103
```

### 手动测试

```bash
# 健康检查
curl http://localhost:17103/health

# 版本信息
curl http://localhost:17103/version

# 带特定标志的状态
curl "http://localhost:17103/status?flags=23"

# 配置服务器
curl -X PUT http://localhost:17103/servers \
  -H "Content-Type: application/json" \
  -d '{"servers": ["pool.ntp.org"]}'
```

## 🤝 贡献

1. Fork 仓库
2. 创建功能分支
3. 进行更改
4. 如果适用，添加测试
5. 运行测试套件: `./scripts/test.sh`
6. 提交拉取请求

## 📄 许可证

本项目根据 MIT 许可证授权 - 详情见 LICENSE 文件。

## 🆘 支持

如有问题:
- 查看上方的故障排除部分
- 查看日志: `docker logs el-brick-x-clock`
- 手动测试 API 端点
- 在 GitHub 上开启一个 issue

## 📝 更新日志

### 版本 0.1.0-dev
- 初始版本
- NTP 客户端和服务器功能
- 用于管理的 RESTful API
- Docker 容器化
- 用于性能的缓存层
- 全面的测试套件

---

**版本**: 0.1.0-dev  
**最后更新**: 2025年7月