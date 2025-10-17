#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
    elif [[ -f /etc/arch-release ]]; then
        DISTRO="arch"
        DISTRO_VERSION=""
    elif [[ -f /etc/debian_version ]]; then
        DISTRO="debian"
        DISTRO_VERSION=$(cat /etc/debian_version)
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO="rhel"
        DISTRO_VERSION=$(cat /etc/redhat-release | grep -oE '[0-9]+' | head -1)
    else
        DISTRO="unknown"
        DISTRO_VERSION=""
    fi
    
    echo "$DISTRO"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Check if sudo is available
check_sudo() {
    if ! command -v sudo &> /dev/null; then
        log_error "sudo is not installed or not available"
        exit 1
    fi
    
    if ! sudo -n true 2>/dev/null; then
        log_warning "sudo requires password. You may be prompted for your password."
    fi
}

# Check internet connectivity
check_internet() {
    log_info "Checking internet connectivity..."
    if ping -c 1 8.8.8.8 &> /dev/null; then
        log_success "Internet connection is available"
        return 0
    else
        log_error "No internet connection available"
        return 1
    fi
}

# Check available disk space (minimum 2GB)
check_disk_space() {
    log_info "Checking available disk space..."
    local available_space=$(df / | awk 'NR==2 {print $4}')
    local required_space=2097152 # 2GB in KB
    
    if [[ $available_space -gt $required_space ]]; then
        log_success "Sufficient disk space available ($(($available_space / 1024 / 1024))GB)"
        return 0
    else
        log_error "Insufficient disk space. Required: 2GB, Available: $(($available_space / 1024 / 1024))GB"
        return 1
    fi
}

# Install package based on distribution
install_package() {
    local package=$1
    local distro=$(detect_distro)
    
    case $distro in
        "arch"|"manjaro")
            sudo pacman -S --noconfirm "$package"
            ;;
        "ubuntu"|"debian")
            sudo apt update && sudo apt install -y "$package"
            ;;
        "fedora"|"rhel"|"centos")
            sudo dnf install -y "$package"
            ;;
        *)
            log_error "Unsupported distribution: $distro"
            return 1
            ;;
    esac
}

# Check if package is installed
is_package_installed() {
    local package=$1
    local distro=$(detect_distro)
    
    case $distro in
        "arch"|"manjaro")
            pacman -Q "$package" &> /dev/null
            ;;
        "ubuntu"|"debian")
            dpkg -l "$package" &> /dev/null
            ;;
        "fedora"|"rhel"|"centos")
            rpm -q "$package" &> /dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Run all prerequisite checks
run_prerequisites() {
    log_info "Running prerequisite checks..."
    
    check_root
    check_sudo
    check_internet
    check_disk_space
    
    log_success "All prerequisite checks passed"
}

# Create backup of important files
create_backup() {
    local file=$1
    local backup_dir="$HOME/.init-setup-backups"
    
    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        local backup_file="$backup_dir/$(basename "$file").$(date +%Y%m%d_%H%M%S).bak"
        cp "$file" "$backup_file"
        log_info "Backup created: $backup_file"
    fi
}

# Ask for user confirmation
ask_confirmation() {
    local message=$1
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}
