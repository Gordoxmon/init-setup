#!/bin/bash

# Source utils
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

install_ansible() {
    local distro=$(detect_distro)
    log_info "Installing Ansible for $distro..."

    case "$distro" in
        "arch"|"manjaro")
            if ! is_package_installed "ansible"; then
                log_info "Installing Ansible via pacman..."
                echo "pacman ansible";
                sudo pacman -S --noconfirm ansible
            else
                log_info "Ansible is already installed"
            fi
            ;;
        "ubuntu"|"debian")
            if ! is_package_installed "ansible"; then
                log_info "Installing Ansible via apt..."
                sudo apt update
                sudo apt install -y software-properties-common
                sudo apt-add-repository --yes --update ppa:ansible/ansible
                sudo apt install -y ansible
            else
                log_info "Ansible is already installed"
            fi
            ;;
        "fedora"|"rhel"|"centos")
            if ! is_package_installed "ansible"; then
                log_info "Installing Ansible via dnf..."
                sudo dnf install -y ansible
            else
                log_info "Ansible is already installed"
            fi
            ;;
        *)
            log_error "Unsupported distribution: $distro"
            return 1
            ;;
    esac
    
    # Verify installation
    if command -v ansible &> /dev/null; then
        local version=$(ansible --version | head -n1)
        log_success "Ansible installed successfully: $version"
        return 0
    else
        log_error "Failed to install Ansible"
        return 1
    fi
}

install_python_deps() {
    log_info "Installing Python dependencies for Ansible..."
    
    local distro=$(detect_distro)
    
    case $distro in
        "arch"|"manjaro")
            sudo pacman -S --noconfirm python-pip python-setuptools
            ;;
        "ubuntu"|"debian")
            sudo apt install -y python3-pip python3-setuptools
            ;;
        "fedora"|"rhel"|"centos")
            sudo dnf install -y python3-pip python3-setuptools
            ;;
    esac
    
    # Install common Ansible collections
    log_info "Installing common Ansible collections..."
    ansible-galaxy collection install community.general
    ansible-galaxy collection install ansible.posix
}

setup_ansible_config() {
    log_info "Setting up Ansible configuration..."
    
    local ansible_dir="$HOME/.ansible"
    local config_file="$ansible_dir/ansible.cfg"
    
    mkdir -p "$ansible_dir"
    
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << EOF
[defaults]
inventory = ./ansible/inventory/localhost.ini
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
bin_ansible_callbacks = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
EOF
        log_success "Ansible configuration created at $config_file"
    else
        log_info "Ansible configuration already exists"
    fi
}

main() {
    log_info "Starting Ansible installation..."
    
    if ! run_prerequisites; then
        log_error "Prerequisites check failed"
        exit 1
    fi
    
    if install_ansible; then
        install_python_deps
        setup_ansible_config
        log_success "Ansible setup completed successfully"
    else
        log_error "Ansible installation failed"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
