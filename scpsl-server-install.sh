#!/bin/bash

# SCP:SL 服务端一键部署脚本 / SCP:SL Server One-Click Deployment Script
# 适用于 Ubuntu 22.04+ 和 Debian 12+ / Compatible with Ubuntu 22.04+ and Debian 12+
# 作者 / Author: 开朗的火山河123 / kldhsh123
# V1.2 / GPL-3.0 license

set -e  # 遇到错误时退出

# 颜色定义 / Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 语言检测和设置 / Language detection and settings
detect_language() {
    # 检测系统语言或允许用户选择 / Detect system language or allow user choice
    if [[ "${LANG:-}" =~ ^zh ]]; then
        SCRIPT_LANG="zh"
        echo "自动检测到中文环境" "Chinese environment detected automatically"
    elif [[ "${LANG:-}" =~ ^en ]]; then
        SCRIPT_LANG="en"
        echo "English environment detected automatically" "English environment detected automatically"
    else
        # 默认根据地区设置选择语言 / Default language based on locale
        echo "请选择语言 / Please select language:"
        echo "1) 中文 (Chinese)"
        echo "2) English"
        read -p "选择 / Choice (1-2): " lang_choice
        case $lang_choice in
            1) 
                SCRIPT_LANG="zh"
                echo "已选择中文界面" "Chinese interface selected"
                ;;
            2) 
                SCRIPT_LANG="en"
                echo "English interface selected" "English interface selected"
                ;;
            *) 
                SCRIPT_LANG="zh"
                echo "无效选择，默认使用中文界面" "Invalid choice, using Chinese interface by default"
                ;;
        esac
    fi
    export SCRIPT_LANG
}

# 显示作者信息 / Show author information
show_author_info() {
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo -e "${BLUE}[作者]${NC} 开朗的火山河123"
    else
        echo -e "${BLUE}[Author]${NC} kldhsh123"
    fi
}

# 双语文本配置 / Bilingual text configuration
declare -A TEXTS
TEXTS["info_zh"]="信息"
TEXTS["info_en"]="INFO"
TEXTS["success_zh"]="成功"
TEXTS["success_en"]="SUCCESS"
TEXTS["warning_zh"]="警告"
TEXTS["warning_en"]="WARNING"
TEXTS["error_zh"]="错误"
TEXTS["error_en"]="ERROR"

# 双语日志函数 / Bilingual logging functions
log_info() {
    local msg_zh="$1"
    local msg_en="${2:-$1}"
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo -e "${BLUE}[${TEXTS["info_zh"]}]${NC} $msg_zh"
    else
        echo -e "${BLUE}[${TEXTS["info_en"]}]${NC} $msg_en"
    fi
}

log_success() {
    local msg_zh="$1"
    local msg_en="${2:-$1}"
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo -e "${GREEN}[${TEXTS["success_zh"]}]${NC} $msg_zh"
    else
        echo -e "${GREEN}[${TEXTS["success_en"]}]${NC} $msg_en"
    fi
}

log_warning() {
    local msg_zh="$1"
    local msg_en="${2:-$1}"
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo -e "${YELLOW}[${TEXTS["warning_zh"]}]${NC} $msg_zh"
    else
        echo -e "${YELLOW}[${TEXTS["warning_en"]}]${NC} $msg_en"
    fi
}

log_error() {
    local msg_zh="$1"
    local msg_en="${2:-$1}"
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo -e "${RED}[${TEXTS["error_zh"]}]${NC} $msg_zh"
    else
        echo -e "${RED}[${TEXTS["error_en"]}]${NC} $msg_en"
    fi
}

# 检查是否为root用户 / Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 sudo 权限运行此脚本" "Please run this script with sudo privileges"
        exit 1
    fi
}

# 检查系统架构
check_architecture() {
    log_info "正在检查系统架构..." "Checking system architecture..."
    
    ARCH=$(dpkg --print-architecture)
    if [[ $ARCH == "arm64" || $ARCH == "armhf" ]]; then
        log_error "不支持 ARM 架构 ($ARCH)" "ARM architecture ($ARCH) is not supported"
        log_error "SCP:SL 服务端只支持 x86_64 架构" "SCP:SL server only supports x86_64 architecture"
        exit 1
    fi
    
    log_success "架构检查通过: $ARCH" "Architecture check passed: $ARCH"
}

# 检查系统资源
check_resources() {
    log_info "正在检查系统资源..." "Checking system resources..."
    
    # 检查内存
    TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
    TOTAL_SWAP=$(free -m | awk 'NR==3{print $2}')
    TOTAL_AVAILABLE=$(($TOTAL_MEM + $TOTAL_SWAP))
    
    log_info "物理内存: ${TOTAL_MEM}MB" "Physical memory: ${TOTAL_MEM}MB"
    log_info "虚拟内存: ${TOTAL_SWAP}MB" "Virtual memory: ${TOTAL_SWAP}MB"
    log_info "总可用内存: ${TOTAL_AVAILABLE}MB" "Total available memory: ${TOTAL_AVAILABLE}MB"
    
    if [ $TOTAL_MEM -lt 3072 ]; then
        log_warning "物理内存不足3GB，可能影响服务器性能" "Physical memory less than 3GB, may affect server performance"
        log_warning "当前物理内存: ${TOTAL_MEM}MB，建议: 3GB+" "Current physical memory: ${TOTAL_MEM}MB, recommended: 3GB+"
        
        if [ $TOTAL_AVAILABLE -lt 3072 ]; then
            log_warning "总可用内存(物理+虚拟)也不足3GB" "Total available memory (physical+virtual) also less than 3GB"
            log_warning "建议设置虚拟内存来提高性能" "It's recommended to set up virtual memory for better performance"
            NEED_SWAP_SETUP=true
        else
            log_info "总可用内存足够，但建议增加物理内存" "Total available memory is enough, but it's recommended to increase physical memory"
        fi
    else
        log_success "内存检查通过: ${TOTAL_MEM}MB" "Memory check passed: ${TOTAL_MEM}MB"
    fi
    
    # 检查CPU核心数
    CPU_CORES=$(nproc)
    if [ $CPU_CORES -lt 2 ]; then
        log_warning "CPU核心数不足2个，可能影响服务器性能" "CPU cores less than 2, may affect server performance"
        log_warning "当前核心数: $CPU_CORES，建议: 2+" "Current cores: $CPU_CORES, recommended: 2+"
    else
        log_success "CPU检查通过: ${CPU_CORES}核" "CPU check passed: ${CPU_CORES} cores"
    fi
    
    # 检查磁盘空间
    DISK_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ $DISK_SPACE -lt 4 ]; then
        log_warning "磁盘空间不足4GB，可能影响安装" "Disk space less than 4GB, may affect installation"
        log_warning "当前可用空间: ${DISK_SPACE}GB，建议: 4GB+" "Current available space: ${DISK_SPACE}GB, recommended: 4GB+"
    else
        log_success "磁盘空间检查通过: ${DISK_SPACE}GB" "Disk space check passed: ${DISK_SPACE}GB"
    fi
}

# 设置虚拟内存
setup_swap() {
    log_info "正在设置虚拟内存..." "Setting up swap..."
    
    # 检查是否已有swap
    CURRENT_SWAP=$(free -m | awk 'NR==3{print $2}')
    if [ $CURRENT_SWAP -gt 0 ]; then
        log_info "当前虚拟内存: ${CURRENT_SWAP}MB" "Current virtual memory: ${CURRENT_SWAP}MB"
        
        # 询问是否要增加更多swap
        echo ""
        echo "当前系统已有 ${CURRENT_SWAP}MB 虚拟内存" "Current system has ${CURRENT_SWAP}MB virtual memory"
        echo "是否要增加更多虚拟内存？" "Do you want to add more virtual memory?"
        echo "1) 是，增加虚拟内存" "1) Yes, add virtual memory"
        echo "2) 否，保持当前设置" "2) No, keep current setting"
        echo "3) 重新配置虚拟内存" "3) Reconfigure virtual memory"
        echo ""
        read -p "请选择 (1-3): " swap_choice
        
        case $swap_choice in
            1)
                log_info "将增加额外的虚拟内存" "Additional virtual memory will be added"
                ;;
            2)
                log_info "保持当前虚拟内存设置" "Keeping current virtual memory setting"
                return
                ;;
            3)
                log_info "将重新配置虚拟内存" "Reconfiguring virtual memory"
                # 关闭现有swap
                swapoff -a
                # 删除现有swap文件
                if [ -f /swapfile ]; then
                    rm -f /swapfile
                fi
                ;;
            *)
                log_info "无效选择，保持现有设置" "Invalid choice, keeping current setting"
                return
                ;;
        esac
    fi
    
    # 计算推荐的swap大小
    PHYSICAL_MEM=$(free -m | awk 'NR==2{print $2}')
    
    if [ $PHYSICAL_MEM -lt 2048 ]; then
        RECOMMENDED_SWAP=2048  # 2GB
    elif [ $PHYSICAL_MEM -lt 4096 ]; then
        RECOMMENDED_SWAP=4096  # 4GB
    elif [ $PHYSICAL_MEM -lt 8192 ]; then
        RECOMMENDED_SWAP=4096  # 4GB
    else
        RECOMMENDED_SWAP=2048  # 2GB
    fi
    
    echo ""
    echo "虚拟内存大小建议：" "Virtual memory size recommendation:"
    echo "当前物理内存: ${PHYSICAL_MEM}MB" "Current physical memory: ${PHYSICAL_MEM}MB"
    echo "推荐虚拟内存: ${RECOMMENDED_SWAP}MB" "Recommended virtual memory: ${RECOMMENDED_SWAP}MB"
    echo ""
    echo "请选择虚拟内存大小：" "Please select virtual memory size:"
    echo "1) 1GB (1024MB)" "1) 1GB (1024MB)"
    echo "2) 2GB (2048MB) - 推荐用于低内存服务器" "2) 2GB (2048MB) - Recommended for low memory server"
    echo "3) 4GB (4096MB) - 推荐用于中等内存服务器" "3) 4GB (4096MB) - Recommended for medium memory server"
    echo "4) 自定义大小" "4) Custom size"
    echo "5) 跳过虚拟内存设置" "5) Skip virtual memory setup"
    echo ""
    read -p "请选择 (1-5): " size_choice
    
    case $size_choice in
        1)
            SWAP_SIZE=1024
            ;;
        2)
            SWAP_SIZE=2048
            ;;
        3)
            SWAP_SIZE=4096
            ;;
        4)
            echo ""
            read -p "请输入虚拟内存大小 (MB): " SWAP_SIZE
            if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]] || [ $SWAP_SIZE -lt 512 ]; then
                log_error "无效的大小，最小为512MB" "Invalid size, minimum 512MB"
                return
            fi
            ;;
        5)
            log_info "跳过虚拟内存设置" "Skipping virtual memory setup"
            return
            ;;
        *)
            log_warning "无效选择，使用推荐大小: ${RECOMMENDED_SWAP}MB" "Invalid choice, using recommended size: ${RECOMMENDED_SWAP}MB"
            SWAP_SIZE=$RECOMMENDED_SWAP
            ;;
    esac
    
    # 检查磁盘空间是否足够
    AVAILABLE_SPACE=$(df -BM / | awk 'NR==2 {print $4}' | sed 's/M//')
    REQUIRED_SPACE=$(($SWAP_SIZE + 1024))  # 额外1GB缓冲
    
    if [ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]; then
        log_error "磁盘空间不足！" "Disk space insufficient!"
        log_error "需要: ${REQUIRED_SPACE}MB，可用: ${AVAILABLE_SPACE}MB" "Required: ${REQUIRED_SPACE}MB, available: ${AVAILABLE_SPACE}MB"
        return
    fi
    
    log_info "正在创建 ${SWAP_SIZE}MB 的虚拟内存文件..." "Creating ${SWAP_SIZE}MB virtual memory file..."
    
    # 创建swap文件名（如果已存在swap，使用不同名称）
    SWAP_FILE="/swapfile"
    if [ -f "$SWAP_FILE" ]; then
        SWAP_FILE="/swapfile_$(date +%s)"
    fi
    
    # 创建swap文件
    dd if=/dev/zero of=$SWAP_FILE bs=1M count=$SWAP_SIZE status=progress
    
    # 设置正确的权限
    chmod 600 $SWAP_FILE
    
    # 设置为swap
    mkswap $SWAP_FILE
    
    # 启用swap
    swapon $SWAP_FILE
    
    # 添加到fstab以便开机自动挂载
    if grep -q "$SWAP_FILE" /etc/fstab; then
        log_info "虚拟内存已在 fstab 中配置" "Virtual memory already configured in fstab"
    else
        echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
        log_info "已添加虚拟内存到 fstab" "Virtual memory added to fstab"
    fi
    
    # 配置swap使用策略
    echo ""
    echo "虚拟内存使用策略配置：" "Virtual memory usage strategy configuration:"
    echo "vm.swappiness 控制系统使用虚拟内存的积极程度 (0-100)：" "vm.swappiness controls the degree of system use of virtual memory (0-100):"
    echo ""
    echo "  0-10  : 极少使用swap，优先使用物理内存 (推荐用于游戏服务器)" "  0-10  : Less use of swap, prioritize physical memory (recommended for game server)"
    echo "  10-30 : 较少使用swap，平衡性能" "  10-30 : Less use of swap, balance performance"
    echo "  30-60 : 默认策略，平衡使用" "  30-60 : Default strategy, balance use"
    echo "  60-100: 积极使用swap，节省物理内存" "  60-100: Active use of swap, save physical memory"
    echo ""
    echo "当前系统默认值: $(cat /proc/sys/vm/swappiness)" "Current system default value: $(cat /proc/sys/vm/swappiness)"
    echo ""
    echo "请选择swappiness值：" "Please select swappiness value:"
    echo "1) 1  - 最少使用swap (高性能，推荐用于充足内存)" "1) 1  - Less use of swap (high performance, recommended for sufficient memory)"
    echo "2) 10 - 很少使用swap (推荐用于SCP:SL服务端)" "2) 10 - Less use of swap (recommended for SCP:SL server)"
    echo "3) 30 - 较少使用swap (平衡选择)" "3) 30 - Less use of swap (balance choice)"
    echo "4) 60 - 系统默认策略" "4) 60 - System default strategy"
    echo "5) 自定义值 (0-100)" "5) Custom value (0-100)"
    echo "6) 不修改 (保持系统默认)" "6) Not modify (keep system default)"
    echo ""
    read -p "请选择 (1-6): " swappiness_choice
    
    case $swappiness_choice in
        1)
            SWAPPINESS=1
            ;;
        2)
            SWAPPINESS=10
            ;;
        3)
            SWAPPINESS=30
            ;;
        4)
            SWAPPINESS=60
            ;;
        5)
            echo ""
            read -p "请输入swappiness值 (0-100): " SWAPPINESS
            if ! [[ "$SWAPPINESS" =~ ^[0-9]+$ ]] || [ $SWAPPINESS -lt 0 ] || [ $SWAPPINESS -gt 100 ]; then
                log_error "无效值，使用推荐值10" "Invalid value, using recommended value 10"
                SWAPPINESS=10
            fi
            ;;
        6)
            log_info "保持系统默认swappiness设置" "Keeping system default swappiness setting"
            SWAPPINESS=""
            ;;
        *)
            log_warning "无效选择，使用推荐值10" "Invalid choice, using recommended value 10"
            SWAPPINESS=10
            ;;
    esac
    
    # 应用设置
    if [ -n "$SWAPPINESS" ]; then
        # 检查是否已有相关配置
        if grep -q "vm.swappiness" /etc/sysctl.conf; then
            # 更新现有配置
            sed -i "s/^vm.swappiness=.*/vm.swappiness=$SWAPPINESS/" /etc/sysctl.conf
        else
            # 添加新配置
            echo "# SCP:SL 服务端虚拟内存优化" >> /etc/sysctl.conf
            echo "vm.swappiness=$SWAPPINESS" >> /etc/sysctl.conf
        fi
        
        # 立即应用
        sysctl vm.swappiness=$SWAPPINESS > /dev/null 2>&1
        log_info "已设置 vm.swappiness=$SWAPPINESS" "vm.swappiness set to $SWAPPINESS"
    fi
    
    # 询问是否设置vfs_cache_pressure
    echo ""
    echo "是否优化文件系统缓存策略？" "Optimize file system cache strategy?"
    echo "vm.vfs_cache_pressure 控制内核回收缓存的倾向：" "vm.vfs_cache_pressure controls the degree of kernel cache recycling:"
    echo "- 100: 系统默认" "- 100: System default"
    echo "- 50:  减少缓存回收，提高文件访问性能 (推荐)" "- 50:   Less cache recycling, improve file access performance (recommended)"
    echo ""
    read -p "设置 vm.vfs_cache_pressure=50 ？(Y/n): " cache_choice
    
    case $cache_choice in
        [Nn]*)
            log_info "保持默认缓存策略" "Keeping default cache strategy"
            ;;
        *)
            if grep -q "vm.vfs_cache_pressure" /etc/sysctl.conf; then
                sed -i "s/^vm.vfs_cache_pressure=.*/vm.vfs_cache_pressure=50/" /etc/sysctl.conf
            else
                echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
            fi
            sysctl vm.vfs_cache_pressure=50 > /dev/null 2>&1
            log_info "已设置 vm.vfs_cache_pressure=50" "vm.vfs_cache_pressure set to 50"
            ;;
    esac
    
    # 重新加载所有sysctl配置
    sysctl -p > /dev/null 2>&1
    
    # 显示当前内存状态
    log_success "虚拟内存设置完成！" "Virtual memory setup completed!"
    echo ""
    echo "当前内存状态：" "Current memory status:"
    free -h
    echo ""
    echo "当前系统参数：" "Current system parameters:"
    echo "- vm.swappiness: $(cat /proc/sys/vm/swappiness)" "- vm.swappiness: $(cat /proc/sys/vm/swappiness)"
    echo "- vm.vfs_cache_pressure: $(cat /proc/sys/vm/vfs_cache_pressure)" "- vm.vfs_cache_pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
}

install_prerequisites() {
    log_info "正在安装必要的软件包..." "Installing necessary packages..."

    # 更新软件包列表 / Update package list
    apt update -y

    # 安装基础软件包 / Install basic packages
    apt install -y software-properties-common bc

    # 添加multiverse仓库 / Add multiverse repository
    add-apt-repository multiverse -y

    # 添加i386架构支持 / Add i386 architecture support
    dpkg --add-architecture i386

    # 再次更新软件包列表 / Update package list again
    apt update -y

    # 安装必要的软件包 / Install required packages
    apt install -y lib32gcc-s1 steamcmd tmux curl wget gnupg ca-certificates jq

    # 验证steamcmd安装 / Verify steamcmd installation
    log_info "正在验证 SteamCMD 安装..." "Verifying SteamCMD installation..."

    # 检查steamcmd是否可用 / Check if steamcmd is available
    if ! command -v steamcmd &> /dev/null; then
        # 尝试使用绝对路径 / Try using absolute path
        if [ -f "/usr/games/steamcmd" ]; then
            log_info "SteamCMD 找到，位于 /usr/games/steamcmd" "SteamCMD found at /usr/games/steamcmd"
            # 创建符号链接到 /usr/local/bin / Create symlink to /usr/local/bin
            ln -sf /usr/games/steamcmd /usr/local/bin/steamcmd
        else
            log_error "SteamCMD 安装失败，请检查网络连接" "SteamCMD installation failed, please check network connection"
            exit 1
        fi
    fi

    # 最终验证 / Final verification
    if command -v steamcmd &> /dev/null || [ -f "/usr/games/steamcmd" ]; then
        log_success "SteamCMD 验证成功" "SteamCMD verification successful"
    else
        log_error "SteamCMD 验证失败" "SteamCMD verification failed"
        exit 1
    fi

    log_success "基础软件包安装完成" "Basic packages installation completed"
}

# 安装Mono
install_mono() {
    log_info "正在安装 Mono..." "Installing Mono..."
    
    # 添加Mono官方GPG密钥
    gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    
    # 添加Mono仓库
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list
    
    # 更新软件包列表
    apt update -y
    
    # 安装Mono
    apt install -y mono-complete
    
    log_success "Mono 安装完成" "Mono installation completed"
}

# 创建Steam用户
create_steam_user() {
    log_info "正在创建 Steam 用户..." "Creating Steam user..."
    
    # 检查steam用户是否已存在
    if id "steam" &>/dev/null; then
        log_warning "Steam 用户已存在，跳过创建" "Steam user already exists, skipping creation"
        return
    fi
    
    # 创建steam用户
    useradd -m steam
    
    # 设置密码
    echo "请为 Steam 用户设置密码:" "Please set password for Steam user:"
    while true; do
        passwd steam && break
        log_error "密码设置失败，请重试" "Password setting failed, please try again"
    done
    
    log_success "Steam 用户创建完成" "Steam user creation completed"
}

# 设置Steam用户环境 / Setup Steam user environment
setup_steam_environment() {
    log_info "正在设置 Steam 用户环境..." "Setting up Steam user environment..."

    # 切换到steam用户并设置环境 / Switch to steam user and setup environment
    sudo -u steam bash << 'EOF'
# 设置PATH环境变量 / Set PATH environment variable
if ! grep -q "/usr/games" ~/.bashrc; then
    echo 'export PATH="/usr/games:/usr/local/bin:$PATH"' >> ~/.bashrc
fi

# 设置SteamCMD相关环境变量 / Set SteamCMD related environment variables
if ! grep -q "STEAMCMD_PATH" ~/.bashrc; then
    echo 'export STEAMCMD_PATH="/usr/games/steamcmd"' >> ~/.bashrc
fi

source ~/.bashrc

# 创建必要的目录 / Create necessary directories
mkdir -p ~/steamcmd
mkdir -p ~/steamcmd/scpsl
mkdir -p ~/.config
EOF

    # 验证环境设置 / Verify environment setup
    sudo -u steam bash -c 'source ~/.bashrc && command -v steamcmd' &> /dev/null || \
    sudo -u steam bash -c 'source ~/.bashrc && [ -f "/usr/games/steamcmd" ]' || {
        log_error "Steam 用户环境设置失败" "Steam user environment setup failed"
        exit 1
    }

    log_success "Steam 用户环境设置完成" "Steam user environment setup completed"
}

# 安装SCP:SL服务端 / Install SCP:SL server
install_scpsl_server() {
    log_info "正在安装 SCP:SL 服务端..." "Installing SCP:SL server..."

    # 切换到steam用户并安装服务端 / Switch to steam user and install server
    sudo -u steam bash << 'EOF'
cd ~
source ~/.bashrc

# 检查steamcmd可用性 / Check steamcmd availability
STEAMCMD_CMD=""
if command -v steamcmd &> /dev/null; then
    STEAMCMD_CMD="steamcmd"
elif [ -f "/usr/games/steamcmd" ]; then
    STEAMCMD_CMD="/usr/games/steamcmd"
elif [ -f "/usr/local/bin/steamcmd" ]; then
    STEAMCMD_CMD="/usr/local/bin/steamcmd"
else
    echo "错误: 找不到 steamcmd 命令" "Error: steamcmd command not found"
    exit 1
fi

echo "使用 SteamCMD: $STEAMCMD_CMD" "Using SteamCMD: $STEAMCMD_CMD"

# 初始化SteamCMD并安装SCP:SL服务端 / Initialize SteamCMD and install SCP:SL server
$STEAMCMD_CMD +force_install_dir /home/steam/steamcmd/scpsl +login anonymous +app_update 996560 validate +quit

# 验证安装 / Verify installation
if [ ! -f "/home/steam/steamcmd/scpsl/LocalAdmin" ]; then
    echo "错误: SCP:SL 服务端安装失败" "Error: SCP:SL server installation failed"
    exit 1
fi
EOF

    if [ $? -eq 0 ]; then
        log_success "SCP:SL 服务端安装完成" "SCP:SL server installation completed"
    else
        log_error "SCP:SL 服务端安装失败" "SCP:SL server installation failed"
        exit 1
    fi
}

# 检测防火墙状态 / Detect firewall status
detect_firewall() {
    local firewall_type=""
    local firewall_active=false

    # 检测 ufw / Check ufw
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "Status: active"; then
            firewall_type="ufw"
            firewall_active=true
        fi
    fi

    # 检测 firewalld / Check firewalld
    if [ "$firewall_active" = false ] && command -v firewall-cmd &> /dev/null; then
        if systemctl is-active --quiet firewalld; then
            firewall_type="firewalld"
            firewall_active=true
        fi
    fi

    # 检测 iptables / Check iptables
    if [ "$firewall_active" = false ] && command -v iptables &> /dev/null; then
        if iptables -L | grep -q "Chain INPUT"; then
            # 简单检测是否有规则 / Simple check for rules
            local rule_count=$(iptables -L INPUT | wc -l)
            if [ $rule_count -gt 3 ]; then
                firewall_type="iptables"
                firewall_active=true
            fi
        fi
    fi

    echo "$firewall_type:$firewall_active"
}

# 配置防火墙端口 / Configure firewall ports
configure_firewall_ports() {
    local firewall_info=$(detect_firewall)
    local firewall_type=$(echo "$firewall_info" | cut -d: -f1)
    local firewall_active=$(echo "$firewall_info" | cut -d: -f2)

    if [ "$firewall_active" = "false" ]; then
        log_info "未检测到活动的防火墙，跳过端口配置" "No active firewall detected, skipping port configuration"
        return
    fi

    log_info "检测到活动的防火墙: $firewall_type" "Active firewall detected: $firewall_type"

    # 默认SCP:SL端口 / Default SCP:SL ports
    local default_ports="7777"

    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo ""
        echo "SCP:SL 服务端需要开放以下端口：" "SCP:SL server requires the following ports to be open:"
        echo "- 7777 (默认游戏端口)" "- 7777 (default game port)"
        echo "- 其他自定义端口（如果有）" "Other custom ports (if any)"
        echo ""
        read -p "请输入要开放的端口 (用空格分隔，默认: $default_ports): " user_ports
    else
        echo ""
        echo "SCP:SL server requires the following ports to be open:" "SCP:SL server requires the following ports to be open:"
        echo "- 7777 (default game port)" "- 7777 (default game port)"
        echo "- Other custom ports (if any)" "Other custom ports (if any)"
        echo ""
        read -p "Enter ports to open (space separated, default: $default_ports): " user_ports
    fi

    # 使用用户输入的端口或默认端口 / Use user input or default ports
    local ports_to_open="${user_ports:-$default_ports}"

    # 根据防火墙类型配置端口 / Configure ports based on firewall type
    case "$firewall_type" in
        "ufw")
            for port in $ports_to_open; do
                if [[ "$port" =~ ^[0-9]+$ ]]; then
                    ufw allow $port/tcp
                    ufw allow $port/udp
                    log_success "已开放端口 $port (TCP/UDP)" "Opened port $port (TCP/UDP)"
                fi
            done
            ;;
        "firewalld")
            for port in $ports_to_open; do
                if [[ "$port" =~ ^[0-9]+$ ]]; then
                    firewall-cmd --permanent --add-port=$port/tcp
                    firewall-cmd --permanent --add-port=$port/udp
                    log_success "已开放端口 $port (TCP/UDP)" "Opened port $port (TCP/UDP)"
                fi
            done
            firewall-cmd --reload
            ;;
        "iptables")
            for port in $ports_to_open; do
                if [[ "$port" =~ ^[0-9]+$ ]]; then
                    iptables -A INPUT -p tcp --dport $port -j ACCEPT
                    iptables -A INPUT -p udp --dport $port -j ACCEPT
                    log_success "已开放端口 $port (TCP/UDP)" "Opened port $port (TCP/UDP)"
                fi
            done
            # 保存iptables规则 / Save iptables rules
            if command -v iptables-save &> /dev/null; then
                iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
            fi
            ;;
    esac

    log_success "防火墙端口配置完成" "Firewall port configuration completed"
}

# 版本比较函数 / Version comparison function
compare_versions() {
    local version1="$1"
    local version2="$2"

    # 移除v前缀 / Remove v prefix
    version1=${version1#v}
    version2=${version2#v}

    # 使用sort进行版本比较 / Use sort for version comparison
    local higher_version=$(printf '%s\n%s\n' "$version1" "$version2" | sort -V | tail -n1)

    if [ "$higher_version" = "$version1" ]; then
        echo "1"  # version1 >= version2
    else
        echo "2"  # version2 > version1
    fi
}

# GitHub加速镜像列表 / GitHub acceleration mirror list
GITHUB_MIRRORS=(
    "https://j.1lin.dpdns.org/"
    "https://jiashu.1win.eu.org/"
    "https://j.1win.ggff.net/"
)

# 测试GitHub连接并选择最佳镜像 / Test GitHub connection and select best mirror
select_github_mirror() {
    local test_url="https://api.github.com/repos/ExSLMod-Team/EXILED/releases/latest"

    # 首先尝试直连 / First try direct connection
    if curl -s --connect-timeout 5 --max-time 10 "$test_url" >/dev/null 2>&1; then
        echo ""  # 返回空字符串表示直连可用 / Return empty string for direct connection
        return 0
    fi

    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        log_info "GitHub 直连失败，尝试使用加速镜像..." "GitHub direct connection failed, trying acceleration mirrors..."
    else
        log_info "GitHub direct connection failed, trying acceleration mirrors..." "GitHub direct connection failed, trying acceleration mirrors..."
    fi

    # 测试加速镜像 / Test acceleration mirrors
    for mirror in "${GITHUB_MIRRORS[@]}"; do
        local test_mirror_url="${mirror}${test_url}"
        if curl -s --connect-timeout 5 --max-time 10 "$test_mirror_url" >/dev/null 2>&1; then
            if [[ "$SCRIPT_LANG" == "zh" ]]; then
                log_info "找到可用镜像: $mirror" "Found available mirror: $mirror"
            else
                log_info "Found available mirror: $mirror" "Found available mirror: $mirror"
            fi
            echo "$mirror"
            return 0
        fi
    done

    # 所有镜像都失败 / All mirrors failed
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        log_warning "所有 GitHub 镜像都无法连接，将使用直连重试" "All GitHub mirrors failed, will retry with direct connection"
    else
        log_warning "All GitHub mirrors failed, will retry with direct connection" "All GitHub mirrors failed, will retry with direct connection"
    fi
    echo ""
}

# 获取最新EXILED版本 / Get latest EXILED version
get_latest_exiled_version() {
    log_info "正在检查 EXILED 最新版本..." "Checking latest EXILED version..."

    # 选择最佳GitHub镜像 / Select best GitHub mirror
    local github_mirror=$(select_github_mirror)

    # GitHub API URLs
    local repo1_api="${github_mirror}https://api.github.com/repos/ExSLMod-Team/EXILED/releases/latest"
    local repo2_api="${github_mirror}https://api.github.com/repos/ExMod-Team/EXILED/releases/latest"

    # 获取两个仓库的最新版本信息 / Get latest version info from both repositories
    local repo1_data=$(curl -s --connect-timeout 10 --max-time 30 "$repo1_api" 2>/dev/null)
    local repo2_data=$(curl -s --connect-timeout 10 --max-time 30 "$repo2_api" 2>/dev/null)

    # 检查API调用是否成功 / Check if API calls were successful
    if [ -z "$repo1_data" ] && [ -z "$repo2_data" ]; then
        log_error "无法连接到 GitHub API" "Unable to connect to GitHub API"
        return 1
    fi

    # 提取版本号 / Extract version numbers
    local repo1_version=""
    local repo2_version=""
    local repo1_download_url=""
    local repo2_download_url=""

    if [ -n "$repo1_data" ] && echo "$repo1_data" | jq -e . >/dev/null 2>&1; then
        repo1_version=$(echo "$repo1_data" | jq -r '.tag_name // empty')
        local raw_url1=$(echo "$repo1_data" | jq -r '.assets[] | select(.name == "Exiled.tar.gz") | .browser_download_url // empty')
        # 如果使用镜像，也要为下载URL添加镜像前缀 / If using mirror, add mirror prefix to download URL
        if [ -n "$github_mirror" ]; then
            repo1_download_url="${github_mirror}${raw_url1}"
        else
            repo1_download_url="$raw_url1"
        fi
    fi

    if [ -n "$repo2_data" ] && echo "$repo2_data" | jq -e . >/dev/null 2>&1; then
        repo2_version=$(echo "$repo2_data" | jq -r '.tag_name // empty')
        local raw_url2=$(echo "$repo2_data" | jq -r '.assets[] | select(.name == "Exiled.tar.gz") | .browser_download_url // empty')
        # 如果使用镜像，也要为下载URL添加镜像前缀 / If using mirror, add mirror prefix to download URL
        if [ -n "$github_mirror" ]; then
            repo2_download_url="${github_mirror}${raw_url2}"
        else
            repo2_download_url="$raw_url2"
        fi
    fi

    # 比较版本并选择最新的 / Compare versions and select the latest
    local selected_version=""
    local selected_url=""
    local selected_repo=""

    if [ -n "$repo1_version" ] && [ -n "$repo2_version" ]; then
        local comparison=$(compare_versions "$repo1_version" "$repo2_version")
        if [ "$comparison" = "1" ]; then
            selected_version="$repo1_version"
            selected_url="$repo1_download_url"
            selected_repo="ExSLMod-Team"
        else
            selected_version="$repo2_version"
            selected_url="$repo2_download_url"
            selected_repo="ExMod-Team"
        fi
    elif [ -n "$repo1_version" ]; then
        selected_version="$repo1_version"
        selected_url="$repo1_download_url"
        selected_repo="ExSLMod-Team"
    elif [ -n "$repo2_version" ]; then
        selected_version="$repo2_version"
        selected_url="$repo2_download_url"
        selected_repo="ExMod-Team"
    else
        log_error "无法获取 EXILED 版本信息" "Unable to get EXILED version information"
        return 1
    fi

    if [ -z "$selected_url" ]; then
        log_error "未找到 Exiled.tar.gz 下载链接" "Exiled.tar.gz download link not found"
        return 1
    fi

    log_info "找到最新版本: $selected_version (来源: $selected_repo)" "Found latest version: $selected_version (from: $selected_repo)"

    # 返回版本信息 / Return version information
    echo "$selected_version|$selected_url|$selected_repo"
}

# 安装EXILED / Install EXILED
install_exiled() {
    log_info "开始安装 EXILED..." "Starting EXILED installation..."

    # 获取最新版本信息 / Get latest version information
    local version_info=$(get_latest_exiled_version)
    if [ $? -ne 0 ] || [ -z "$version_info" ]; then
        log_error "获取 EXILED 版本信息失败" "Failed to get EXILED version information"
        return 1
    fi

    local version=$(echo "$version_info" | cut -d'|' -f1)
    local download_url=$(echo "$version_info" | cut -d'|' -f2)
    local repo_name=$(echo "$version_info" | cut -d'|' -f3)

    log_info "准备下载 EXILED $version..." "Preparing to download EXILED $version..."

    # 切换到steam用户进行安装 / Switch to steam user for installation
    sudo -u steam bash << EOF
cd ~

# 创建临时目录 / Create temporary directory
mkdir -p ~/temp_exiled
cd ~/temp_exiled

# 下载 Exiled.tar.gz / Download Exiled.tar.gz
echo "正在下载 EXILED $version..." "Downloading EXILED $version..."
if ! curl -L -o Exiled.tar.gz "$download_url"; then
    echo "下载失败" "Download failed"
    exit 1
fi

# 解压文件 / Extract files
echo "正在解压 EXILED..." "Extracting EXILED..."
if ! tar -xzf Exiled.tar.gz; then
    echo "解压失败" "Extraction failed"
    exit 1
fi

# 确保 ~/.config 目录存在 / Ensure ~/.config directory exists
mkdir -p ~/.config

# 移动 EXILED 文件夹到 ~/.config / Move EXILED folder to ~/.config
if [ -d "EXILED" ]; then
    if [ -d ~/.config/EXILED ]; then
        echo "备份现有 EXILED 配置..." "Backing up existing EXILED configuration..."
        mv ~/.config/EXILED ~/.config/EXILED_backup_\$(date +%Y%m%d_%H%M%S)
    fi
    mv EXILED ~/.config/
    echo "EXILED 文件夹已移动到 ~/.config/" "EXILED folder moved to ~/.config/"
else
    echo "错误: 未找到 EXILED 文件夹" "Error: EXILED folder not found"
    exit 1
fi

# 移动 SCP Secret Laboratory 文件夹到 ~/.config / Move SCP Secret Laboratory folder to ~/.config
if [ -d "SCP Secret Laboratory" ]; then
    if [ -d ~/.config/"SCP Secret Laboratory" ]; then
        echo "备份现有 SCP Secret Laboratory 配置..." "Backing up existing SCP Secret Laboratory configuration..."
        mv ~/.config/"SCP Secret Laboratory" ~/.config/"SCP Secret Laboratory_backup_\$(date +%Y%m%d_%H%M%S)"
    fi
    mv "SCP Secret Laboratory" ~/.config/
    echo "SCP Secret Laboratory 文件夹已移动到 ~/.config/" "SCP Secret Laboratory folder moved to ~/.config/"
fi

# 清理临时文件 / Clean up temporary files
cd ~
rm -rf ~/temp_exiled

echo "EXILED $version 安装完成！" "EXILED $version installation completed!"
EOF

    if [ $? -eq 0 ]; then
        log_success "EXILED $version 安装成功" "EXILED $version installation successful"
        log_info "EXILED 已安装到: /home/steam/.config/EXILED" "EXILED installed to: /home/steam/.config/EXILED"
    else
        log_error "EXILED 安装失败" "EXILED installation failed"
        return 1
    fi
}

# 创建启动脚本 / Create startup script
create_startup_script() {
    log_info "正在创建启动脚本..." "Creating startup script..."
    
    # 创建启动脚本
    sudo -u steam tee /home/steam/start_scpsl.sh << 'EOF'
#!/bin/bash

# SCP:SL 服务端启动脚本

# 获取服务端ID
SERVER_ID="${1:-scpsl}"

# 获取tmux会话名
if [ "$SERVER_ID" == "scpsl" ]; then
    SESSION_NAME="scpsl"
else
    SESSION_NAME="scpsl_$SERVER_ID"
fi

cd ~/steamcmd/scpsl

# 检查服务端文件是否存在
if [ ! -f "./LocalAdmin" ]; then
    echo "错误: LocalAdmin 文件不存在" "Error: LocalAdmin file not found"
    echo "请检查服务端安装是否成功" "Please check if server installation is successful"
    exit 1
fi

# 检查会话是否已存在
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "错误: $SESSION_NAME 会话已存在" "Error: $SESSION_NAME session already exists"
    echo "请使用 'tmux attach-session -t $SESSION_NAME' 连接到现有会话" "Please use 'tmux attach-session -t $SESSION_NAME' to connect to existing session"
    exit 1
fi

# 创建新的tmux会话并启动服务端
echo "正在启动 SCP:SL 服务端 (ID: $SERVER_ID)..." "Starting SCP:SL server (ID: $SERVER_ID)..."
echo "使用以下命令连接到服务端控制台:" "Using the following command to connect to server console:"
echo "  sudo -u steam tmux attach-session -t $SESSION_NAME" "  sudo -u steam tmux attach-session -t $SESSION_NAME"
echo ""
echo "使用以下命令分离tmux会话 (保持服务端运行):" "Using the following command to detach tmux session (keep server running):"
echo "  Ctrl+B 然后按 D" "  Ctrl+B then press D"
echo ""

tmux new-session -d -s $SESSION_NAME './LocalAdmin'
echo "SCP:SL 服务端已在后台启动" "SCP:SL server started in background"
echo "tmux 会话名称: $SESSION_NAME" "tmux session name: $SESSION_NAME"
EOF
    
    # 设置脚本权限
    chmod +x /home/steam/start_scpsl.sh
    
    log_success "启动脚本创建完成" "Startup script created successfully"
}

# 创建管理脚本
create_management_scripts() {
    log_info "正在创建管理脚本..." "Creating management script..."
    
    # 创建服务端管理脚本
    tee /usr/local/bin/scpsl-manager << 'EOF'
#!/bin/bash

# SCP:SL 服务端管理脚本

# 获取服务器ID参数，默认为scpsl
get_server_id() {
    local id="${1:-scpsl}"
    echo "$id"
}

# 获取tmux会话名
get_session_name() {
    local id="$1"
    if [ "$id" == "scpsl" ]; then
        echo "scpsl"
    else
        echo "scpsl_$id"
    fi
}

case "$1" in
    start)
        SERVER_ID=$(get_server_id "$2")
        SESSION_NAME=$(get_session_name "$SERVER_ID")
        echo "启动 SCP:SL 服务端 (ID: $SERVER_ID)..." "Starting SCP:SL server (ID: $SERVER_ID)..."
        
        # 检查是否已经运行
        if sudo -u steam tmux has-session -t $SESSION_NAME 2>/dev/null; then
            echo "服务端 $SERVER_ID 已在运行中" "Server $SERVER_ID is already running"
            exit 0
        fi
        
        # 启动服务端
        sudo -u steam bash -c "cd ~/steamcmd/scpsl && tmux new-session -d -s $SESSION_NAME './LocalAdmin'"
        echo "SCP:SL 服务端 $SERVER_ID 已在后台启动" "SCP:SL server $SERVER_ID started in background"
        echo "tmux 会话名称: $SESSION_NAME" "tmux session name: $SESSION_NAME"
        ;;
    stop)
        SERVER_ID=$(get_server_id "$2")
        SESSION_NAME=$(get_session_name "$SERVER_ID")
        echo "停止 SCP:SL 服务端 (ID: $SERVER_ID)..." "Stopping SCP:SL server (ID: $SERVER_ID)..."
        sudo -u steam tmux kill-session -t $SESSION_NAME 2>/dev/null || echo "服务端 $SERVER_ID 未运行" "Server $SERVER_ID not running"
        ;;
    restart)
        SERVER_ID=$(get_server_id "$2")
        SESSION_NAME=$(get_session_name "$SERVER_ID")
        echo "重启 SCP:SL 服务端 (ID: $SERVER_ID)..." "Restarting SCP:SL server (ID: $SERVER_ID)..."
        sudo -u steam tmux kill-session -t $SESSION_NAME 2>/dev/null || true
        sleep 2
        sudo -u steam bash -c "cd ~/steamcmd/scpsl && tmux new-session -d -s $SESSION_NAME './LocalAdmin'"
        echo "SCP:SL 服务端 $SERVER_ID 已重启" "SCP:SL server $SERVER_ID restarted"
        ;;
    status)
        if [ -z "$2" ]; then
            # 列出所有SCP:SL服务端
            echo "SCP:SL 服务端状态列表：" "SCP:SL servers status list:"
            sessions=$(sudo -u steam tmux ls 2>/dev/null | grep "^scpsl" || echo "")
            if [ -z "$sessions" ]; then
                echo "没有正在运行的SCP:SL服务端实例" "No SCP:SL server instances running"
            else
                echo "$sessions"
                echo ""
                echo "使用 'scpsl-manager status <id>' 查看特定服务端详情" "Use 'scpsl-manager status <id>' to view specific server details"
            fi
        else
            SERVER_ID=$(get_server_id "$2")
            SESSION_NAME=$(get_session_name "$SERVER_ID")
            if sudo -u steam tmux has-session -t $SESSION_NAME 2>/dev/null; then
                echo "SCP:SL 服务端 $SERVER_ID 正在运行" "SCP:SL server $SERVER_ID is running"
                echo "会话名称: $SESSION_NAME" "Session name: $SESSION_NAME"
            else
                echo "SCP:SL 服务端 $SERVER_ID 未运行" "SCP:SL server $SERVER_ID not running"
            fi
        fi
        ;;
    console)
        SERVER_ID=$(get_server_id "$2")
        SESSION_NAME=$(get_session_name "$SERVER_ID")
        echo "连接到 SCP:SL 服务端控制台 (ID: $SERVER_ID)..." "Connecting to SCP:SL server console (ID: $SERVER_ID)..."
        echo "使用 Ctrl+B 然后按 D 来分离会话" "Using Ctrl+B then D to detach session"
        
        if ! sudo -u steam tmux has-session -t $SESSION_NAME 2>/dev/null; then
            echo "错误: 服务端 $SERVER_ID 未运行" "Error: Server $SERVER_ID not running"
            exit 1
        fi
        
        sudo -u steam tmux attach-session -t $SESSION_NAME
        ;;
    update)
        echo "更新 SCP:SL 服务端..." "Updating SCP:SL server..."
        # 停止所有服务端实例
        sessions=$(sudo -u steam tmux ls 2>/dev/null | grep "^scpsl" | cut -d ':' -f1 || echo "")
        if [ -n "$sessions" ]; then
            echo "停止所有运行中的服务端实例..." "Stopping all running server instances..."
            for session in $sessions; do
                sudo -u steam tmux kill-session -t $session 2>/dev/null || true
                echo "已停止会话: $session" "Stopped session: $session"
            done
        fi
        
        sudo -u steam bash -c "cd ~ && steamcmd +force_install_dir /home/steam/steamcmd/scpsl +login anonymous +app_update 996560 validate +quit"
        echo "更新完成" "Update completed"
        ;;
    swap)
        echo "虚拟内存管理..." "Virtual memory management..."
        echo "当前内存状态：" "Current memory status:"
        free -h
        echo ""
        echo "虚拟内存文件：" "Virtual memory file:"
        swapon --show
        ;;
    setup-swap)
        echo "设置虚拟内存..." "Setting up virtual memory..."
        # 重新定义函数以供独立调用
        setup_swap() {
            # 定义日志函数
            log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
            log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
            log_warning() { echo -e "\033[1;33m[WARNING]\033[0m $1"; }
            log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
            
            # 完整的swap设置逻辑
            CURRENT_SWAP=$(free -m | awk 'NR==3{print $2}')
            if [ $CURRENT_SWAP -gt 0 ]; then
                log_info "当前虚拟内存: ${CURRENT_SWAP}MB" "Current virtual memory: ${CURRENT_SWAP}MB"
                read -p "是否要重新配置虚拟内存？(y/N): " reconfig
                if [[ ! $reconfig =~ ^[Yy] ]]; then
                    return
                fi
            fi
            
            read -p "请输入虚拟内存大小(MB，推荐2048): " SWAP_SIZE
            SWAP_SIZE=${SWAP_SIZE:-2048}
            
            if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]] || [ $SWAP_SIZE -lt 512 ]; then
                log_error "无效的大小，最小为512MB" "Invalid size, minimum 512MB"
                return
            fi
            
            SWAP_FILE="/swapfile_$(date +%s)"
            log_info "正在创建 ${SWAP_SIZE}MB 的虚拟内存文件..." "Creating ${SWAP_SIZE}MB virtual memory file..."
            
            dd if=/dev/zero of=$SWAP_FILE bs=1M count=$SWAP_SIZE status=progress
            chmod 600 $SWAP_FILE
            mkswap $SWAP_FILE
            swapon $SWAP_FILE
            
            if ! grep -q "$SWAP_FILE" /etc/fstab; then
                echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
            fi
            
            # 配置swappiness
            echo ""
            echo "配置虚拟内存使用策略：" "Configuring virtual memory usage strategy:"
            echo "1) 1  - 最少使用swap (高性能)" "1) 1  - Less use of swap (high performance)"
            echo "2) 10 - 很少使用swap (推荐)" "2) 10 - Less use of swap (recommended)"
            echo "3) 30 - 较少使用swap" "3) 30 - Less use of swap"
            echo "4) 60 - 默认策略" "4) Default strategy"
            echo "5) 自定义 (0-100)" "5) Custom (0-100)"
            read -p "选择swappiness值 (1-5): " swap_choice
            
            case $swap_choice in
                1) SWAPPINESS=1 ;;
                2) SWAPPINESS=10 ;;
                3) SWAPPINESS=30 ;;
                4) SWAPPINESS=60 ;;
                5) 
                    read -p "输入swappiness值 (0-100): " SWAPPINESS
                    if ! [[ "$SWAPPINESS" =~ ^[0-9]+$ ]] || [ $SWAPPINESS -lt 0 ] || [ $SWAPPINESS -gt 100 ]; then
                        SWAPPINESS=10
                    fi
                    ;;
                *) SWAPPINESS=10 ;;
            esac
            
            # 应用设置
            if grep -q "vm.swappiness" /etc/sysctl.conf; then
                sed -i "s/^vm.swappiness=.*/vm.swappiness=$SWAPPINESS/" /etc/sysctl.conf
            else
                echo "vm.swappiness=$SWAPPINESS" >> /etc/sysctl.conf
            fi
            sysctl vm.swappiness=$SWAPPINESS > /dev/null 2>&1
            
            log_success "虚拟内存设置完成！" "Virtual memory setup completed!"
            echo "当前参数: vm.swappiness=$(cat /proc/sys/vm/swappiness)" "Current parameters: vm.swappiness=$(cat /proc/sys/vm/swappiness)"
            free -h
        }
        setup_swap
        ;;
    firewall)
        echo "防火墙管理 / Firewall Management" "Firewall management"
        echo "当前防火墙状态 / Current firewall status:" "Current firewall status:"

        # 检测防火墙
        if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
            echo "UFW: 活动 / Active" "UFW: Active"
            ufw status
        elif command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
            echo "Firewalld: 活动 / Active" "Firewalld: Active"
            firewall-cmd --list-ports
        elif command -v iptables &> /dev/null; then
            echo "Iptables: 检测到规则 / Rules detected" "Iptables: Rules detected"
            iptables -L INPUT | grep -E "(tcp|udp)" | head -10
        else
            echo "未检测到活动防火墙 / No active firewall detected" "No active firewall detected"
        fi
        ;;
    exiled)
        case "$2" in
            install)
                echo "安装 EXILED / Installing EXILED" "Installing EXILED"
                # 重新定义安装函数
                install_exiled_standalone() {
                    echo "正在检查 EXILED 最新版本..." "Checking latest EXILED version..."

                    # 简化版本的EXILED安装
                    sudo -u steam bash << 'EXILED_EOF'
cd ~
mkdir -p ~/temp_exiled
cd ~/temp_exiled

# 测试GitHub连接并选择镜像
echo "正在测试网络连接..." "Testing network connection..."
GITHUB_MIRROR=""
TEST_URL="https://api.github.com/repos/ExSLMod-Team/EXILED/releases/latest"

# 测试直连
if ! curl -s --connect-timeout 5 --max-time 10 "$TEST_URL" >/dev/null 2>&1; then
    echo "GitHub 直连失败，尝试使用加速镜像..." "GitHub direct connection failed, trying acceleration mirrors..."
    # 测试镜像
    MIRRORS=("https://j.1lin.dpdns.org/" "https://jiashu.1win.eu.org/" "https://j.1win.ggff.net/")
    for mirror in "${MIRRORS[@]}"; do
        if curl -s --connect-timeout 5 --max-time 10 "${mirror}${TEST_URL}" >/dev/null 2>&1; then
            GITHUB_MIRROR="$mirror"
            echo "使用镜像: $mirror" "Using mirror: $mirror"
            break
        fi
    done
fi

# 获取最新版本信息
REPO1_API="${GITHUB_MIRROR}https://api.github.com/repos/ExSLMod-Team/EXILED/releases/latest"
REPO2_API="${GITHUB_MIRROR}https://api.github.com/repos/ExMod-Team/EXILED/releases/latest"

echo "正在获取版本信息..." "Getting version information..."
REPO1_DATA=$(curl -s --connect-timeout 10 --max-time 30 "$REPO1_API" 2>/dev/null)
REPO2_DATA=$(curl -s --connect-timeout 10 --max-time 30 "$REPO2_API" 2>/dev/null)

# 简单选择第一个可用的仓库
DOWNLOAD_URL=""
VERSION=""

if echo "$REPO1_DATA" | grep -q "tag_name"; then
    VERSION=$(echo "$REPO1_DATA" | grep '"tag_name"' | cut -d'"' -f4)
    RAW_DOWNLOAD_URL=$(echo "$REPO1_DATA" | grep '"browser_download_url".*Exiled.tar.gz"' | cut -d'"' -f4)
    # 如果使用镜像，为下载URL添加镜像前缀
    if [ -n "$GITHUB_MIRROR" ]; then
        DOWNLOAD_URL="${GITHUB_MIRROR}${RAW_DOWNLOAD_URL}"
    else
        DOWNLOAD_URL="$RAW_DOWNLOAD_URL"
    fi
    REPO_NAME="ExSLMod-Team"
elif echo "$REPO2_DATA" | grep -q "tag_name"; then
    VERSION=$(echo "$REPO2_DATA" | grep '"tag_name"' | cut -d'"' -f4)
    RAW_DOWNLOAD_URL=$(echo "$REPO2_DATA" | grep '"browser_download_url".*Exiled.tar.gz"' | cut -d'"' -f4)
    # 如果使用镜像，为下载URL添加镜像前缀
    if [ -n "$GITHUB_MIRROR" ]; then
        DOWNLOAD_URL="${GITHUB_MIRROR}${RAW_DOWNLOAD_URL}"
    else
        DOWNLOAD_URL="$RAW_DOWNLOAD_URL"
    fi
    REPO_NAME="ExMod-Team"
fi

if [ -z "$DOWNLOAD_URL" ]; then
    echo "错误: 无法获取下载链接" "Error: Unable to get download link"
    exit 1
fi

echo "找到版本: $VERSION (来源: $REPO_NAME)" "Found version: $VERSION (from: $REPO_NAME)"
echo "正在下载..." "Downloading..."

if curl -L -o Exiled.tar.gz "$DOWNLOAD_URL"; then
    echo "下载完成，正在解压..." "Download completed, extracting..."
    if tar -xzf Exiled.tar.gz; then
        mkdir -p ~/.config

        # 备份现有配置
        if [ -d ~/.config/EXILED ]; then
            mv ~/.config/EXILED ~/.config/EXILED_backup_$(date +%Y%m%d_%H%M%S)
        fi

        # 移动文件
        if [ -d "EXILED" ]; then
            mv EXILED ~/.config/
            echo "EXILED 安装成功！" "EXILED installation successful!"
        fi

        if [ -d "SCP Secret Laboratory" ]; then
            if [ -d ~/.config/"SCP Secret Laboratory" ]; then
                mv ~/.config/"SCP Secret Laboratory" ~/.config/"SCP Secret Laboratory_backup_$(date +%Y%m%d_%H%M%S)"
            fi
            mv "SCP Secret Laboratory" ~/.config/
            echo "SCP Secret Laboratory 配置已更新！" "SCP Secret Laboratory configuration updated!"
        fi
    else
        echo "解压失败" "Extraction failed"
        exit 1
    fi
else
    echo "下载失败" "Download failed"
    exit 1
fi

# 清理
cd ~
rm -rf ~/temp_exiled
echo "EXILED $VERSION 安装完成！" "EXILED $VERSION installation completed!"
EXILED_EOF
                }
                install_exiled_standalone
                ;;
            status)
                echo "EXILED 状态 / EXILED Status:" "EXILED status:"
                if sudo -u steam [ -d "/home/steam/.config/EXILED" ]; then
                    echo "EXILED: 已安装 / Installed" "EXILED: Installed"
                    if sudo -u steam [ -f "/home/steam/.config/EXILED/Exiled.dll" ]; then
                        echo "核心文件: 存在 / Core files: Present" "Core files: Present"
                    else
                        echo "核心文件: 缺失 / Core files: Missing" "Core files: Missing"
                    fi
                else
                    echo "EXILED: 未安装 / Not installed" "EXILED: Not installed"
                fi
                ;;
            *)
                echo "EXILED 管理 / EXILED Management" "EXILED management"
                echo "用法 / Usage: $0 exiled {install|status}" "Usage: $0 exiled {install|status}"
                echo "  install - 安装最新版本 EXILED / Install latest EXILED" "  install - Install latest EXILED"
                echo "  status  - 查看 EXILED 状态 / Check EXILED status" "  status  - Check EXILED status"
                ;;
        esac
        ;;
    *)
        echo "SCP:SL 服务端管理工具 / SCP:SL Server Management Tool" "SCP:SL Server Management Tool"
        echo "作者 / Author: 开朗的火山河123 / kldhsh123" "Author: kldhsh123"
        echo ""
        echo "用法 / Usage: $0 {start|stop|restart|status|console|update|swap|setup-swap|firewall|exiled} [server_id]" "Usage: $0 {start|stop|restart|status|console|update|swap|setup-swap|firewall|exiled} [server_id]"
        echo ""
        echo "命令说明 / Command Description:" "Command Description:"
        echo "  start      - 启动服务端 / Start server" "  start      - Start server"
        echo "  stop       - 停止服务端 / Stop server" "  stop       - Stop server"
        echo "  restart    - 重启服务端 / Restart server" "  restart    - Restart server"
        echo "  status     - 查看服务端状态 / Check server status" "  status     - Check server status"
        echo "  console    - 连接到服务端控制台 / Connect to server console" "  console    - Connect to server console"
        echo "  update     - 更新服务端 / Update server" "  update     - Update server"
        echo "  swap       - 查看虚拟内存状态 / Check swap status" "  swap       - Check swap status"
        echo "  setup-swap - 设置虚拟内存 / Setup swap" "  setup-swap - Setup swap"
        echo "  firewall   - 查看防火墙状态 / Check firewall status" "  firewall   - Check firewall status"
        echo "  exiled     - EXILED 管理 / EXILED management" "  exiled     - EXILED management"
        echo ""
        echo "选项说明 / Options:" "Options:"
        echo "  server_id  - 可选参数，指定服务端ID (默认: scpsl)" "  server_id  - Optional parameter, specify server ID (default: scpsl)"
        echo "               多服务端时使用不同ID来区分" "               Use different IDs to distinguish multiple servers"
        exit 1
        ;;
esac
EOF
    
    # 设置管理脚本权限
    chmod +x /usr/local/bin/scpsl-manager
    
    log_success "管理脚本创建完成" "Management script created successfully"
}

# 显示完成信息 / Show completion information
show_completion_info() {
    echo ""
    echo "======================================" "======================================"
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        log_success "SCP:SL 服务端安装完成!" "SCP:SL server installation completed!"
        echo "======================================" "======================================"
        echo ""
        show_author_info
        echo ""
        echo "使用以下命令管理服务端:" "Use the following commands to manage the server:"
        echo "  scpsl-manager start [id]     # 启动服务端 (可选ID)" "  scpsl-manager start [id]     # Start server (optional ID)"
        echo "  scpsl-manager stop [id]      # 停止服务端 (可选ID)" "  scpsl-manager stop [id]      # Stop server (optional ID)"
        echo "  scpsl-manager restart [id]   # 重启服务端 (可选ID)" "  scpsl-manager restart [id]   # Restart server (optional ID)"
        echo "  scpsl-manager status [id]    # 查看状态 (无ID则列出所有实例)" "  scpsl-manager status [id]    # Check status (list all instances if no ID)"
        echo "  scpsl-manager console [id]   # 连接控制台 (可选ID)" "  scpsl-manager console [id]   # Connect to console (optional ID)"
        echo "  scpsl-manager update         # 更新服务端" "  scpsl-manager update         # Update server"
        echo "  scpsl-manager swap           # 查看虚拟内存状态" "  scpsl-manager swap           # Check swap status"
        echo "  scpsl-manager setup-swap     # 设置虚拟内存" "  scpsl-manager setup-swap     # Setup swap"
        echo "  scpsl-manager firewall       # 查看防火墙状态" "  scpsl-manager firewall       # Check firewall status"
        echo "  scpsl-manager exiled         # EXILED 管理" "  scpsl-manager exiled         # EXILED management"
        echo ""
        echo "多实例管理示例 (使用不同ID):" "Multi-instance management examples (using different IDs):"
        echo "  scpsl-manager start server1    # 启动ID为server1的服务端" "  scpsl-manager start server1    # Start server with ID server1"
        echo "  scpsl-manager start server2    # 启动ID为server2的服务端" "  scpsl-manager start server2    # Start server with ID server2"
        echo "  scpsl-manager status           # 列出所有运行中的服务端" "  scpsl-manager status           # List all running servers"
        echo ""
        echo "服务端文件位置: /home/steam/steamcmd/scpsl" "Server files location: /home/steam/steamcmd/scpsl"
        echo "配置文件位置: /home/steam/.config/SCP Secret Laboratory" "Config files location: /home/steam/.config/SCP Secret Laboratory"
        echo ""
        echo "首次启动服务端:" "First time server startup:"
        echo "  scpsl-manager start" "  scpsl-manager start"
        echo ""
        echo "连接到服务端控制台 (查看日志/执行命令):" "Connect to server console (view logs/execute commands):"
        echo "  scpsl-manager console" "  scpsl-manager console"
        echo ""
        echo "注意: 使用 Ctrl+B 然后按 D 来分离 tmux 会话" "Note: Use Ctrl+B then D to detach tmux session"
        echo "这样可以保持服务端在后台运行" "This keeps the server running in background"
    else
        log_success "SCP:SL server installation completed!" "SCP:SL server installation completed!"
        echo "======================================" "======================================"
        echo ""
        show_author_info
        echo ""
        echo "Use the following commands to manage the server:" "Use the following commands to manage the server:"
        echo "  scpsl-manager start [id]     # Start server (optional ID)" "  scpsl-manager start [id]     # Start server (optional ID)"
        echo "  scpsl-manager stop [id]      # Stop server (optional ID)" "  scpsl-manager stop [id]      # Stop server (optional ID)"
        echo "  scpsl-manager restart [id]   # Restart server (optional ID)" "  scpsl-manager restart [id]   # Restart server (optional ID)"
        echo "  scpsl-manager status [id]    # Check status (list all instances if no ID)" "  scpsl-manager status [id]    # Check status (list all instances if no ID)"
        echo "  scpsl-manager console [id]   # Connect to console (optional ID)" "  scpsl-manager console [id]   # Connect to console (optional ID)"
        echo "  scpsl-manager update         # Update server" "  scpsl-manager update         # Update server"
        echo "  scpsl-manager swap           # Check swap status" "  scpsl-manager swap           # Check swap status"
        echo "  scpsl-manager setup-swap     # Setup swap" "  scpsl-manager setup-swap     # Setup swap"
        echo "  scpsl-manager firewall       # Check firewall status" "  scpsl-manager firewall       # Check firewall status"
        echo "  scpsl-manager exiled         # EXILED management" "  scpsl-manager exiled         # EXILED management"
        echo ""
        echo "Multi-instance management examples (using different IDs):" "Multi-instance management examples (using different IDs):"
        echo "  scpsl-manager start server1    # Start server with ID server1" "  scpsl-manager start server1    # Start server with ID server1"
        echo "  scpsl-manager start server2    # Start server with ID server2" "  scpsl-manager start server2    # Start server with ID server2"
        echo "  scpsl-manager status           # List all running servers" "  scpsl-manager status           # List all running servers"
        echo ""
        echo "Server files location: /home/steam/steamcmd/scpsl" "Server files location: /home/steam/steamcmd/scpsl"
        echo "Config files location: /home/steam/.config/SCP Secret Laboratory" "Config files location: /home/steam/.config/SCP Secret Laboratory"
        echo ""
        echo "First time server startup:" "First time server startup:"
        echo "  scpsl-manager start" "  scpsl-manager start"
        echo ""
        echo "Connect to server console (view logs/execute commands):" "Connect to server console (view logs/execute commands):"
        echo "  scpsl-manager console" "  scpsl-manager console"
        echo ""
        echo "Note: Use Ctrl+B then D to detach tmux session" "Note: Use Ctrl+B then D to detach tmux session"
        echo "This keeps the server running in background" "This keeps the server running in background"
    fi
    echo ""
}

# 显示语言设置调试信息
debug_language_settings() {
    echo "当前语言设置: $SCRIPT_LANG" "Current language setting: $SCRIPT_LANG"
}

# 主函数 / Main function
main() {
    # 初始化语言设置 / Initialize language settings
    detect_language
    
    # 添加调试输出
    debug_language_settings

    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo "======================================" "======================================"
        echo "SCP:SL 服务端一键部署脚本" "SCP:SL server One-Click Deployment Script"
        echo "======================================" "======================================"
    else
        echo "======================================" "======================================"
        echo "SCP:SL Server One-Click Deployment Script" "SCP:SL Server One-Click Deployment Script"
        echo "======================================" "======================================"
    fi
    echo ""

    # 显示作者信息 / Show author information
    show_author_info
    echo ""

    # 执行检查 / Perform checks
    check_root
    check_system
    check_architecture
    check_resources
    
    # 询问是否设置虚拟内存
    if [ "${NEED_SWAP_SETUP:-false}" = true ]; then
        echo ""
        if [[ "$SCRIPT_LANG" == "zh" ]]; then
            log_warning "检测到内存不足，强烈建议设置虚拟内存" "Memory less than 3GB, it's strongly recommended to set up virtual memory"
            read -p "是否现在设置虚拟内存？(Y/n): " setup_swap_choice
        else
            log_warning "Memory less than 3GB, it's strongly recommended to set up virtual memory" "Memory less than 3GB, it's strongly recommended to set up virtual memory"
            read -p "Set up virtual memory now? (Y/n): " setup_swap_choice
        fi
        case $setup_swap_choice in
            [Nn]*)
                log_info "跳过虚拟内存设置" "Skipping virtual memory setup"
                ;;
            *)
                setup_swap
                ;;
        esac
    else
        echo ""
        if [[ "$SCRIPT_LANG" == "zh" ]]; then
            read -p "是否要设置/优化虚拟内存？(y/N): " setup_swap_choice
        else
            read -p "Setup/optimize virtual memory? (y/N): " setup_swap_choice
        fi
        case $setup_swap_choice in
            [Yy]*)
                setup_swap
                ;;
            *)
                log_info "跳过虚拟内存设置" "Skipping virtual memory setup"
                ;;
        esac
    fi
    
    echo ""
    # 网络连接测试 / Network connection test
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        log_info "正在测试网络连接..." "Testing network connection..."
    else
        log_info "Testing network connection..." "Testing network connection..."
    fi

    # 测试GitHub连接
    if ! curl -s --connect-timeout 5 --max-time 10 "https://api.github.com" >/dev/null 2>&1; then
        if [[ "$SCRIPT_LANG" == "zh" ]]; then
            log_warning "GitHub 直连失败，将在需要时自动使用加速镜像" "GitHub direct connection failed, will use acceleration mirrors when needed"
            log_info "可用镜像: j.1lin.dpdns.org, jiashu.1win.eu.org, j.1win.ggff.net" "Available mirrors: j.1lin.dpdns.org, jiashu.1win.eu.org, j.1win.ggff.net"
        else
            log_warning "GitHub direct connection failed, will use acceleration mirrors when needed" "GitHub direct connection failed, will use acceleration mirrors when needed"
            log_info "Available mirrors: j.1lin.dpdns.org, jiashu.1win.eu.org, j.1win.ggff.net" "Available mirrors: j.1lin.dpdns.org, jiashu.1win.eu.org, j.1win.ggff.net"
        fi
    else
        if [[ "$SCRIPT_LANG" == "zh" ]]; then
            log_success "GitHub 连接正常" "GitHub connection is normal"
        else
            log_success "GitHub connection is normal" "GitHub connection is normal"
        fi
    fi

    echo ""
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        log_info "准备开始安装..." "Ready to start installation..."
        read -p "按 Enter 键继续，或 Ctrl+C 取消安装" 
    else
        log_info "Ready to start installation..." "Ready to start installation..."
        read -p "Press Enter to continue, or Ctrl+C to cancel installation" 
    fi
    
    # 执行安装步骤 / Execute installation steps
    install_prerequisites
    install_mono
    create_steam_user
    setup_steam_environment
    install_scpsl_server
    create_startup_script
    create_management_scripts

    # 防火墙配置 / Firewall configuration
    echo ""
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        read -p "是否要配置防火墙端口？(Y/n): " firewall_choice
    else
        read -p "Configure firewall ports? (Y/n): " firewall_choice
    fi

    case $firewall_choice in
        [Nn]*)
            log_info "跳过防火墙配置" "Skipping firewall configuration"
            ;;
        *)
            configure_firewall_ports
            ;;
    esac

    # EXILED安装选项 / EXILED installation option
    echo ""
    if [[ "$SCRIPT_LANG" == "zh" ]]; then
        echo "EXILED 是一个流行的 SCP:SL 服务端插件框架" 
        read -p "是否要安装 EXILED？(y/N): " exiled_choice
    else
        echo "EXILED is a popular SCP:SL server plugin framework" 
        read -p "Install EXILED? (y/N): " exiled_choice
    fi

    case $exiled_choice in
        [Yy]*)
            install_exiled
            ;;
        *)
            log_info "跳过 EXILED 安装" "Skipping EXILED installation" "Skipping EXILED installation"
            ;;
    esac

    # 显示完成信息 / Show completion information
    show_completion_info
}

# 运行主函数
main "$@"
