#!/bin/bash

# Workspace Setup Automation Script
# This script provides an interactive menu to set up your development workspace

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utils
source "$SCRIPT_DIR/scripts/utils.sh"

# Colors for menu
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Display banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    WORKSPACE SETUP AUTOMATION                ║"
    echo "║                                                              ║"
    echo "║  Automated setup for your development environment            ║"
    echo "║  • Ansible playbooks for package management                  ║"
    echo "║  • Multi-distro Linux support                                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Display main menu
show_menu() {
    echo -e "${PURPLE}Main Menu:${NC}"
    echo "1) Complete Setup (Ansible)"
    echo "2) Install Ansible only"
    echo "3) Run Ansible playbooks"
    echo "4) System Information"
    echo "5) Exit"
    echo
}

# Run complete setup
complete_setup() {
    log_info "Starting complete workspace setup..."
    
    if ! run_prerequisites; then
        log_error "Prerequisites check failed"
        return 1
    fi
    
    # Install Ansible
    log_info "Installing Ansible..."
    if "$SCRIPT_DIR/scripts/install-ansible.sh"; then
        log_success "Ansible installation completed"
    else
        log_error "Ansible installation failed"
        return 1
    fi
    
    # Run Ansible playbooks
    log_info "Running Ansible playbooks..."
    if run_ansible_playbooks; then
        log_success "Ansible playbooks completed"
    else
        log_error "Ansible playbooks failed"
        return 1
    fi
    
    log_success "Complete setup finished successfully!"
}

# Run Ansible playbooks
run_ansible_playbooks() {
    # shellcheck disable=SC2155
    local distro=$(detect_distro)
    # shellcheck disable=SC2034
    local playbook_dir="$SCRIPT_DIR/ansible/playbooks"
    
    log_info "Running Ansible playbooks for $distro..."
    
    # Change to ansible directory
    cd "$SCRIPT_DIR/ansible" || return 1
    
    # Install requirements
    if [[ -f "requirements.yml" ]]; then
        log_info "Installing Ansible requirements..."
        ansible-galaxy install -r requirements.yml
    fi
    
    # Run common playbook
    log_info "Running common playbook..."
    if ansible-playbook -i inventory/localhost.ini playbooks/common.yml --ask-become-pass; then
        log_success "Common playbook completed"
    else
        log_error "Common playbook failed"
        return 1
    fi
    
    # Run distro-specific playbook
    case $distro in
        "arch"|"manjaro")
            log_info "Running Arch-specific playbook..."
            ansible-playbook -i inventory/localhost.ini playbooks/arch.yml --ask-become-pass
            ;;
        "ubuntu"|"debian")
            log_info "Running Debian/Ubuntu-specific playbook..."
            ansible-playbook -i inventory/localhost.ini playbooks/debian.yml --ask-become-pass
            ;;
        "fedora"|"rhel"|"centos")
            log_info "Running Fedora/RHEL-specific playbook..."
            ansible-playbook -i inventory/localhost.ini playbooks/fedora.yml --ask-become-pass
            ;;
        *)
            log_warning "No specific playbook for $distro, only common packages installed"
            ;;
    esac
    
    return 0
}


# Show system information
show_system_info() {
    echo -e "${CYAN}System Information:${NC}"
    echo "Distribution: $(detect_distro)"
    echo "User: $(whoami)"
    echo "Home: $HOME"
    echo "Shell: $SHELL"
    echo "Architecture: $(uname -m)"
    echo "Kernel: $(uname -r)"
    echo
    
    echo -e "${CYAN}Installed Tools:${NC}"
    echo -n "Ansible: "
    if command -v ansible &> /dev/null; then
        echo -e "${GREEN}$(ansible --version | head -n1)${NC}"
    else
        echo -e "${RED}Not installed${NC}"
    fi
    
    echo -n "Git: "
    if command -v git &> /dev/null; then
        echo -e "${GREEN}$(git --version)${NC}"
    else
        echo -e "${RED}Not installed${NC}"
    fi
    
    echo -n "Docker: "
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}$(docker --version)${NC}"
    else
        echo -e "${RED}Not installed${NC}"
    fi
    
    echo
    read -p "Press Enter to continue..."
}

# Main menu loop
main_menu() {
    while true; do
        show_banner
        show_menu
        
        read -p "Select an option (1-5): " choice
        echo
        
        case $choice in
            1)
                if ask_confirmation "This will install Ansible and run playbooks. Continue?"; then
                    complete_setup
                fi
                ;;
            2)
                if ask_confirmation "Install Ansible? This may require sudo privileges."; then
                    "$SCRIPT_DIR/scripts/install-ansible.sh"
                fi
                ;;
            3)
                if ask_confirmation "Run Ansible playbooks? This will install packages and may require sudo privileges."; then
                    run_ansible_playbooks
                fi
                ;;
            4)
                show_system_info
                ;;
            5)
                log_info "Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid option. Please select 1-5."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Main function
main() {
    # Check if running in interactive mode
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        main_menu
    fi
}

# Run main function
main "$@"
