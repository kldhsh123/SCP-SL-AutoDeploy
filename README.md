# SCP:SL 服务端一键部署脚本 / SCP:SL Server Auto-Deploy Script

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Ubuntu%2022.04%2B%20%7C%20Debian%2012%2B-orange.svg)](https://github.com/kldhsh123/SCP-SL-AutoDeploy)

一个功能完整的 SCP: Secret Laboratory 服务端自动化部署脚本，支持双语界面、智能系统检测、自动依赖安装、防火墙配置、EXILED 模组管理等功能。

A comprehensive SCP: Secret Laboratory server auto-deployment script with bilingual interface, intelligent system detection, automatic dependency installation, firewall configuration, EXILED mod management, and more.
![18ab0d4d233dc8ff4a53419918102e9e](https://github.com/user-attachments/assets/60d92854-3d7f-4a4c-a724-b185de6c753a)


## 🌟 主要特性 / Key Features

### 🔧 智能系统管理 / Intelligent System Management
- **系统兼容性检测** / System compatibility detection (Ubuntu 22.04+, Debian 12+)
- **架构验证** / Architecture validation (x86_64 only)
- **资源评估** / Resource assessment (RAM, CPU, Disk space)
- **自动虚拟内存配置** / Automatic swap configuration with optimization

### 🌐 双语支持 / Bilingual Support
- **智能语言检测** / Intelligent language detection
- **完整中英文界面** / Complete Chinese/English interface
- **双语日志输出** / Bilingual logging output

### 🛡️ 安全与网络 / Security & Network
- **防火墙自动配置** / Automatic firewall configuration (UFW/Firewalld/Iptables)
- **端口管理** / Port management
- **GitHub 加速镜像支持** / GitHub acceleration mirror support for China

### 🎮 游戏服务端管理 / Game Server Management
- **SteamCMD 自动安装** / Automatic SteamCMD installation
- **SCP:SL 服务端部署** / SCP:SL server deployment
- **EXILED 模组框架** / EXILED mod framework integration
- **Tmux 会话管理** / Tmux session management

### 📊 运维工具 / Operations Tools
- **完整管理脚本** / Complete management scripts
- **服务端状态监控** / Server status monitoring
- **一键更新功能** / One-click update functionality
- **虚拟内存优化** / Memory optimization tools

![74c1edee07811d0565964a59450c8da2](https://github.com/user-attachments/assets/70947230-9a37-4dff-9892-6c2a8ca082f4)


## 📋 系统要求 / System Requirements

### 支持的操作系统 / Supported Operating Systems
- **Ubuntu 22.04 LTS** 或更高版本 / or higher
- **Debian 12** 或更高版本 / or higher

### 硬件要求 / Hardware Requirements
- **CPU**: 2核心或以上 / 2 cores or more (推荐 / recommended)
- **内存**: 3GB RAM 或以上 / or more (推荐 / recommended)
- **存储**: 4GB 可用空间 / available space (推荐 / recommended)
- **架构**: x86_64 (不支持 ARM / ARM not supported)

### 网络要求 / Network Requirements
- **互联网连接** / Internet connection (用于下载依赖 / for downloading dependencies)
- **开放端口** / Open ports: 7777 (默认游戏端口 / default game port)

## 🚀 快速开始 / Quick Start

### 方法一：直接下载运行 / Method 1: Direct Download & Run

```bash
# 下载脚本 / Download script
wget https://raw.githubusercontent.com/kldhsh123/SCP-SL-AutoDeploy/main/scpsl-server-install.sh

# 或使用加速镜像 (中国大陆用户推荐) / Or use acceleration mirror (recommended for China mainland users)
wget https://j.1lin.dpdns.org/https://raw.githubusercontent.com/kldhsh123/SCP-SL-AutoDeploy/main/scpsl-server-install.sh

# 赋予执行权限 / Grant execute permission
chmod +x scpsl-server-install.sh

# 运行脚本 / Run script
sudo ./scpsl-server-install.sh
```

### 方法二：克隆仓库 / Method 2: Clone Repository

```bash
# 克隆仓库 / Clone repository
git clone https://github.com/kldhsh123/SCP-SL-AutoDeploy.git

# 或使用加速镜像 / Or use acceleration mirror
git clone https://j.1lin.dpdns.org/https://github.com/kldhsh123/SCP-SL-AutoDeploy.git

# 进入目录 / Enter directory
cd SCP-SL-AutoDeploy

# 运行安装脚本 / Run installation script
sudo ./scpsl-server-install.sh
```

## 🔧 安装过程 / Installation Process

脚本将自动执行以下步骤 / The script will automatically perform the following steps:

1. **语言检测与选择** / Language detection and selection
2. **系统兼容性检查** / System compatibility check
3. **资源评估** / Resource assessment
4. **虚拟内存配置** / Swap configuration (如需要 / if needed)
5. **依赖软件安装** / Dependency installation
   - SteamCMD
   - Mono
   - 必要的库文件 / Required libraries
6. **用户环境设置** / User environment setup
7. **SCP:SL 服务端下载** / SCP:SL server download
8. **防火墙配置** / Firewall configuration
9. **EXILED 模组安装** / EXILED mod installation
10. **管理脚本创建** / Management scripts creation

## 📖 管理命令 / Management Commands

安装完成后，使用 `scpsl-manager` 命令管理服务端 / After installation, use `scpsl-manager` command to manage the server:

### 基本操作 / Basic Operations
```bash
scpsl-manager start      # 启动服务端 / Start server
scpsl-manager stop       # 停止服务端 / Stop server
scpsl-manager restart    # 重启服务端 / Restart server
scpsl-manager status     # 查看状态 / Check status
scpsl-manager console    # 连接控制台 / Connect to console
scpsl-manager update     # 更新服务端 / Update server
```

### 高级功能 / Advanced Features
```bash
scpsl-manager swap           # 查看虚拟内存状态 / Check swap status
scpsl-manager setup-swap     # 设置虚拟内存 / Setup swap
scpsl-manager firewall       # 查看防火墙状态 / Check firewall status
scpsl-manager exiled install # 安装 EXILED / Install EXILED
scpsl-manager exiled status  # 查看 EXILED 状态 / Check EXILED status
```

## 🎯 EXILED 模组框架 / EXILED Mod Framework

脚本自动集成 EXILED 模组框架 / The script automatically integrates EXILED mod framework:

- **自动版本检测** / Automatic version detection
- **多仓库支持** / Multi-repository support (ExSLMod-Team & ExMod-Team)
- **GitHub 加速镜像** / GitHub acceleration mirrors
- **配置文件管理** / Configuration file management

### EXILED 安装位置 / EXILED Installation Locations
- **EXILED 框架** / EXILED Framework: `/home/steam/.config/EXILED/`
- **游戏配置** / Game Configuration: `/home/steam/.config/SCP Secret Laboratory/`

## 🌐 GitHub 加速镜像 / GitHub Acceleration Mirrors

为中国大陆用户提供的加速镜像 / Acceleration mirrors for China mainland users:

- `https://j.1lin.dpdns.org/`
- `https://jiashu.1win.eu.org/`
- `https://j.1win.ggff.net/`

脚本会自动测试并选择最佳镜像 / The script automatically tests and selects the best mirror.

## 📁 文件结构 / File Structure

```
/home/steam/
├── steamcmd/
│   └── scpsl/              # SCP:SL 服务端文件 / SCP:SL server files
├── .config/
│   ├── EXILED/             # EXILED 模组框架 / EXILED mod framework
│   └── SCP Secret Laboratory/  # 游戏配置文件 / Game configuration files
└── start_scpsl.sh          # 启动脚本 / Startup script

/usr/local/bin/
└── scpsl-manager           # 管理脚本 / Management script
```

## 🔥 防火墙配置 / Firewall Configuration

脚本支持多种防火墙系统 / The script supports multiple firewall systems:

- **UFW** (Ubuntu Firewall)
- **Firewalld** (CentOS/RHEL style)
- **Iptables** (Traditional Linux firewall)

默认开放端口 / Default open ports:
- **7777** (游戏端口 / Game port)
- 可自定义其他端口 / Customizable additional ports

## 🛠️ 故障排除 / Troubleshooting

### 常见问题 / Common Issues

#### 1. 内存不足 / Insufficient Memory
```bash
# 检查内存状态 / Check memory status
scpsl-manager swap

# 设置虚拟内存 / Setup swap
scpsl-manager setup-swap
```

#### 2. 网络连接问题 / Network Connection Issues
- 脚本会自动尝试 GitHub 加速镜像 / Script automatically tries GitHub acceleration mirrors
- 确保防火墙允许出站连接 / Ensure firewall allows outbound connections

#### 3. 权限问题 / Permission Issues
```bash
# 确保使用 sudo 运行安装脚本 / Ensure running installation script with sudo
sudo ./scpsl-server-install.sh
```

#### 4. 服务端无法启动 / Server Won't Start
```bash
# 检查服务端状态 / Check server status
scpsl-manager status

# 查看服务端日志 / View server logs
scpsl-manager console
```

## 📝 更新日志 / Changelog

### v1.0.0
- 初始版本发布 / Initial release
- 双语支持 / Bilingual support
- 自动系统检测 / Automatic system detection
- EXILED 集成 / EXILED integration
- 防火墙配置 / Firewall configuration
- GitHub 加速镜像支持 / GitHub acceleration mirror support

## 🤝 贡献 / Contributing

欢迎提交 Issue 和 Pull Request！/ Welcome to submit Issues and Pull Requests!

## 📄 许可证 / License

本项目采用 GPL-3.0 许可证 / This project is licensed under GPL-3.0 License.

## 👨‍💻 作者 / Author

- **中文** / Chinese: 开朗的火山河123
- **English**: kldhsh123

## 🔗 相关链接 / Related Links

- **项目仓库** / Project Repository: [https://github.com/kldhsh123/SCP-SL-AutoDeploy](https://github.com/kldhsh123/SCP-SL-AutoDeploy)
- **加速镜像** / Acceleration Mirror: [https://j.1lin.dpdns.org/https://github.com/kldhsh123/SCP-SL-AutoDeploy](https://j.1lin.dpdns.org/https://github.com/kldhsh123/SCP-SL-AutoDeploy)
- **SCP:SL 官网** / SCP:SL Official: [https://scpslgame.com/](https://scpslgame.com/)
- **EXILED 框架** / EXILED Framework: [https://github.com/ExSLMod-Team/EXILED](https://github.com/ExSLMod-Team/EXILED)

## ⚙️ 高级配置 / Advanced Configuration

### 虚拟内存优化 / Swap Optimization

脚本提供智能虚拟内存配置 / The script provides intelligent swap configuration:

#### Swappiness 配置 / Swappiness Configuration
```bash
# 查看当前设置 / Check current setting
cat /proc/sys/vm/swappiness

# 推荐值 / Recommended values:
# 1-10:  高性能，最少使用swap / High performance, minimal swap usage
# 10-30: 平衡性能 / Balanced performance
# 30-60: 默认策略 / Default strategy
```

#### VFS Cache Pressure 优化 / VFS Cache Pressure Optimization
```bash
# 查看当前设置 / Check current setting
cat /proc/sys/vm/vfs_cache_pressure

# 推荐值 50: 减少缓存回收，提高文件访问性能
# Recommended value 50: Reduce cache recycling, improve file access performance
```

### 服务端配置 / Server Configuration

#### 端口配置 / Port Configuration
默认端口配置 / Default port configuration:
- **7777**: 主游戏端口 / Main game port
- **7778**: 查询端口 / Query port (可选 / optional)

#### 性能调优 / Performance Tuning
```bash
# 检查服务端性能 / Check server performance
scpsl-manager status

# 监控资源使用 / Monitor resource usage
htop  # 或 / or: top
```

### EXILED 插件管理 / EXILED Plugin Management

#### 插件安装位置 / Plugin Installation Location
```
/home/steam/.config/EXILED/Plugins/
├── dependencies/           # 依赖文件 / Dependencies
├── *.dll                  # 插件文件 / Plugin files
└── configs/               # 配置文件 / Configuration files
```

#### 常用插件推荐 / Recommended Plugins
- **AdminTools**: 管理员工具 / Admin tools
- **RespawnTimer**: 重生计时器 / Respawn timer
- **CustomItems**: 自定义物品 / Custom items
- **SCPStats**: 统计插件 / Statistics plugin

## 🔒 安全配置 / Security Configuration

### 防火墙最佳实践 / Firewall Best Practices

#### UFW 配置示例 / UFW Configuration Example
```bash
# 启用 UFW / Enable UFW
sudo ufw enable

# 允许 SSH (重要!) / Allow SSH (Important!)
sudo ufw allow ssh

# 允许 SCP:SL 端口 / Allow SCP:SL ports
sudo ufw allow 7777/tcp
sudo ufw allow 7777/udp

# 查看状态 / Check status
sudo ufw status verbose
```

#### Firewalld 配置示例 / Firewalld Configuration Example
```bash
# 添加端口 / Add ports
sudo firewall-cmd --permanent --add-port=7777/tcp
sudo firewall-cmd --permanent --add-port=7777/udp

# 重载配置 / Reload configuration
sudo firewall-cmd --reload

# 查看配置 / Check configuration
sudo firewall-cmd --list-ports
```

### 用户权限管理 / User Permission Management

脚本创建专用的 `steam` 用户来运行服务端 / The script creates a dedicated `steam` user to run the server:

```bash
# 切换到 steam 用户 / Switch to steam user
sudo -u steam bash

# 查看 steam 用户文件 / View steam user files
ls -la /home/steam/
```

## 📊 监控与日志 / Monitoring & Logging

### 服务端日志 / Server Logs

#### 实时查看日志 / Real-time Log Viewing
```bash
# 连接到服务端控制台 / Connect to server console
scpsl-manager console

# 分离会话快捷键 / Detach session shortcut
# Ctrl+B, 然后按 D / then press D
```

#### 日志文件位置 / Log File Locations
```
/home/steam/.config/SCP Secret Laboratory/
├── config/                # 配置文件 / Configuration files
├── logs/                  # 日志文件 / Log files
└── UserData/              # 用户数据 / User data
```

### 系统监控 / System Monitoring

#### 资源使用监控 / Resource Usage Monitoring
```bash
# 内存使用 / Memory usage
free -h

# CPU 使用 / CPU usage
top -p $(pgrep -f LocalAdmin)

# 磁盘使用 / Disk usage
df -h

# 网络连接 / Network connections
netstat -tulpn | grep 7777
```

## 🚀 性能优化 / Performance Optimization

### 系统级优化 / System-level Optimization

#### 内核参数调优 / Kernel Parameter Tuning
脚本自动配置以下参数 / The script automatically configures the following parameters:

```bash
# 查看当前配置 / Check current configuration
sysctl vm.swappiness
sysctl vm.vfs_cache_pressure

# 手动调整 (如需要) / Manual adjustment (if needed)
echo 'vm.swappiness=10' >> /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf
sysctl -p
```

#### 网络优化 / Network Optimization
```bash
# TCP 缓冲区优化 / TCP buffer optimization
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf
```

### 服务端优化 / Server Optimization

#### 启动参数优化 / Startup Parameter Optimization
可以修改启动脚本添加参数 / You can modify the startup script to add parameters:

```bash
# 编辑启动脚本 / Edit startup script
sudo -u steam nano /home/steam/start_scpsl.sh

# 示例优化参数 / Example optimization parameters
./LocalAdmin -batchmode -nographics -silent-crashes
```

## 🔧 故障排除详解 / Detailed Troubleshooting

### 安装问题 / Installation Issues

#### 1. SteamCMD 安装失败 / SteamCMD Installation Failed
```bash
# 手动安装 SteamCMD / Manual SteamCMD installation
sudo apt update
sudo apt install steamcmd

# 验证安装 / Verify installation
which steamcmd
```

#### 2. Mono 安装问题 / Mono Installation Issues
```bash
# 检查 Mono 版本 / Check Mono version
mono --version

# 重新安装 Mono / Reinstall Mono
sudo apt remove mono-complete
sudo apt install mono-complete
```

#### 3. 权限问题 / Permission Issues
```bash
# 修复 steam 用户权限 / Fix steam user permissions
sudo chown -R steam:steam /home/steam/
sudo chmod -R 755 /home/steam/steamcmd/
```

### 运行时问题 / Runtime Issues

#### 1. 服务端无法启动 / Server Won't Start
```bash
# 检查依赖 / Check dependencies
ldd /home/steam/steamcmd/scpsl/LocalAdmin

# 检查端口占用 / Check port usage
netstat -tulpn | grep 7777

# 手动启动测试 / Manual startup test
sudo -u steam /home/steam/steamcmd/scpsl/LocalAdmin
```

#### 2. 内存不足错误 / Out of Memory Error
```bash
# 检查内存使用 / Check memory usage
free -h

# 增加虚拟内存 / Increase swap
scpsl-manager setup-swap

# 优化 Java 堆内存 (如果适用) / Optimize Java heap memory (if applicable)
export JAVA_OPTS="-Xmx2G -Xms1G"
```

#### 3. 网络连接问题 / Network Connection Issues
```bash
# 检查防火墙状态 / Check firewall status
scpsl-manager firewall

# 测试端口连通性 / Test port connectivity
telnet localhost 7777

# 检查网络接口 / Check network interfaces
ip addr show
```

### EXILED 相关问题 / EXILED Related Issues

#### 1. EXILED 加载失败 / EXILED Loading Failed
```bash
# 检查 EXILED 状态 / Check EXILED status
scpsl-manager exiled status

# 重新安装 EXILED / Reinstall EXILED
scpsl-manager exiled install

# 检查配置文件 / Check configuration files
ls -la /home/steam/.config/EXILED/
```

#### 2. 插件冲突 / Plugin Conflicts
```bash
# 查看插件目录 / View plugins directory
ls -la /home/steam/.config/EXILED/Plugins/

# 禁用有问题的插件 / Disable problematic plugins
mv /home/steam/.config/EXILED/Plugins/problem_plugin.dll /home/steam/.config/EXILED/Plugins/disabled/
```

## 📚 常见问题解答 / FAQ

### Q1: 脚本支持哪些 Linux 发行版？/ Which Linux distributions does the script support?
**A**: 目前支持 Ubuntu 22.04+ 和 Debian 12+。其他发行版可能需要手动调整。
**A**: Currently supports Ubuntu 22.04+ and Debian 12+. Other distributions may require manual adjustments.

### Q2: 可以在 VPS 上运行吗？/ Can it run on VPS?
**A**: 可以，但建议至少 2GB RAM 和 2 CPU 核心。脚本会自动检测资源并提供优化建议。
**A**: Yes, but recommend at least 2GB RAM and 2 CPU cores. The script automatically detects resources and provides optimization suggestions.

### Q3: 如何备份服务端数据？/ How to backup server data?
**A**:
```bash
# 备份配置和数据 / Backup configuration and data
sudo tar -czf scpsl_backup_$(date +%Y%m%d).tar.gz /home/steam/.config/
```

### Q4: 如何更改服务端端口？/ How to change server port?
**A**: 编辑配置文件 `/home/steam/.config/SCP Secret Laboratory/config/config.yml` 并重启服务端。
**A**: Edit configuration file `/home/steam/.config/SCP Secret Laboratory/config/config.yml` and restart server.

### Q5: GitHub 连接失败怎么办？/ What to do if GitHub connection fails?
**A**: 脚本会自动尝试加速镜像。如果仍然失败，可以手动下载文件后本地安装。
**A**: The script automatically tries acceleration mirrors. If it still fails, you can manually download files and install locally.

## 🔄 更新与维护 / Updates & Maintenance

### 自动更新 / Automatic Updates
```bash
# 更新服务端 / Update server
scpsl-manager update

# 更新 EXILED / Update EXILED
scpsl-manager exiled install
```

### 手动维护 / Manual Maintenance
```bash
# 清理日志文件 / Clean log files
find /home/steam/.config/SCP\ Secret\ Laboratory/logs/ -name "*.log" -mtime +7 -delete

# 清理临时文件 / Clean temporary files
sudo -u steam rm -rf /home/steam/temp_*

# 检查磁盘使用 / Check disk usage
du -sh /home/steam/
```

## 📞 技术支持 / Technical Support

如果遇到问题，请按以下步骤获取帮助 / If you encounter issues, please follow these steps for help:

1. **查看日志** / Check logs: `scpsl-manager console`
2. **检查系统状态** / Check system status: `scpsl-manager status`
3. **提交 Issue** / Submit Issue: [GitHub Issues](https://github.com/kldhsh123/SCP-SL-AutoDeploy/issues)

提交 Issue 时请包含 / When submitting an Issue, please include:
- 操作系统版本 / Operating system version
- 错误信息 / Error messages
- 系统资源信息 / System resource information

---

**⭐ 如果这个项目对你有帮助，请给个 Star！/ If this project helps you, please give it a Star!**
