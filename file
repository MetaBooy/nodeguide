#!/bin/bash

# ===============================================
# 🚀 Script: Rust Environment Setup
# 🧑 Maintainer: metabooy
# ===============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ -n "${ZSH_VERSION}" && "${ZSH_EVAL_CONTEXT}" == "toplevel" ]]; then
    echo -e "${RED}❌ This script must be sourced! Use:${NC}"
    echo -e "source ${(q-)0}\n"
    exit 1
fi

error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }
warn() { echo -e "${YELLOW}⚠️ [WARN]${NC} $1"; }
info() { echo -e "${BLUE}ℹ️ [INFO]${NC} $1"; }
success() { echo -e "${GREEN}✅ [SUCCESS]${NC} $1"; }
task() { echo -e "${MAGENTA}🔧 [TASK]${NC} $1"; }

run_with_spinner() {
    local msg="$1"
    shift
    local spin_chars='🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛'
    local pid delay=0.1

    "$@" >/dev/null 2>&1 &
    pid=$!

    printf "${MAGENTA}🔧 [TASK]${NC} %s...  " "$msg"
    while kill -0 $pid 2>/dev/null; do
        for i in {0..11}; do
            printf "\b${spin_chars:$i:1}"
            sleep 0.1
        done
    done

    wait $pid
    local exit_status=$?
    printf "\r\033[K"
    return $exit_status
}

setup_environment() {
    export RUSTUP_HOME="${HOME}/.rustup"
    export CARGO_HOME="${HOME}/.cargo"
    export PATH="${CARGO_HOME}/bin:${PATH}"
    
    if [[ -f "${CARGO_HOME}/env" ]]; then
        source "${CARGO_HOME}/env"
    fi
}

install_dependencies() {
    task "Checking system dependencies"
    if command -v apt &>/dev/null; then
        run_with_spinner "Updating package lists" sudo apt update &&
        run_with_spinner "Installing build essentials" sudo apt install -y build-essential curl libssl-dev pkg-config
    elif command -v dnf &>/dev/null; then
        run_with_spinner "Installing development tools" sudo dnf groupinstall -y "Development Tools" &&
        run_with_spinner "Installing system dependencies" sudo dnf install -y curl openssl-devel
    elif command -v yum &>/dev/null; then
        run_with_spinner "Installing development tools" sudo yum groupinstall -y "Development Tools" &&
        run_with_spinner "Installing system dependencies" sudo yum install -y curl openssl-devel
    elif command -v pacman &>/dev/null; then
        run_with_spinner "Updating system" sudo pacman -Syu --noconfirm &&
        run_with_spinner "Installing base-devel" sudo pacman -S --noconfirm base-devel curl openssl
    else
        error "Unsupported package manager"
        return 1
    fi
}

force_update_path() {
    local shell_rc=("${HOME}/.bashrc" "${HOME}/.zshrc" "${HOME}/.profile")
    local env_line="[[ -f \"${CARGO_HOME}/env\" ]] && source \"${CARGO_HOME}/env\""
    
    for rc in "${shell_rc[@]}"; do
        if [[ -f "${rc}" ]] && ! grep -qF "${env_line}" "${rc}"; then
            echo -e "\n# Added by Rust setup script\n${env_line}" >> "${rc}"
        fi
    done
}

manage_rust() {
    if command -v rustup &>/dev/null; then
        task "Updating Rust toolchain"
        if run_with_spinner "Checking for updates" rustup update; then
            success "Rust toolchain updated"
        else
            error "Failed to update Rust toolchain"
            return 1
        fi
    else
        task "Installing Rust"
        run_with_spinner "Downloading rustup" curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init &&
        run_with_spinner "Installing rustup" sh /tmp/rustup-init -y --no-modify-path &&
        rm -f /tmp/rustup-init
    fi
}

verify_rust() {
    task "Verifying installation"
    if command -v rustc &>/dev/null && command -v cargo &>/dev/null; then
        success "Rust components verified:"
        echo -e "${CYAN}Rustc: $(rustc --version)${NC}"
        echo -e "${CYAN}Cargo: $(cargo --version)${NC}"
    else
        error "Rust installation verification failed"
        return 1
    fi
}

main() {
    echo -e "${CYAN}metabooy${NC}"
    setup_environment
    install_dependencies || return 1
    manage_rust || return 1
    setup_environment  # Re-set environment after installation
    force_update_path
    verify_rust || return 1
    success "Rust is ready to use! Current PATH: ${BLUE}${CARGO_HOME}/bin${NC}"
}

main
