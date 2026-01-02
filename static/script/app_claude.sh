#!/bin/bash

echo "Installing Claude CLI..."

# Detect OS
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)

echo "Detected OS: $OS_TYPE"
echo "Architecture: $ARCH_TYPE"

# Installation directory
INSTALL_DIR="/usr/local/bin"
TEMP_DIR="/tmp/claude-install"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect architecture
get_arch() {
    case "$ARCH_TYPE" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Detect OS type
get_os() {
    case "$OS_TYPE" in
        Darwin*)
            echo "darwin"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Download function
download_file() {
    local url=$1
    local output=$2

    if command_exists curl; then
        curl -L -o "$output" "$url"
    elif command_exists wget; then
        wget -O "$output" "$url"
    else
        echo "Error: Neither curl nor wget found. Please install one of them."
        exit 1
    fi
}

# Install for macOS
install_macos() {
    echo "Installing Claude CLI for macOS..."

    if command_exists brew; then
        echo "Homebrew detected. Installing via brew..."
        brew tap anthropics/claude 2>/dev/null || true
        brew install claude
    else
        echo "Homebrew not found. Downloading binary..."
        install_binary
    fi
}

# Install binary directly
install_binary() {
    local os=$(get_os)
    local arch=$(get_arch)

    if [ "$os" = "unsupported" ] || [ "$arch" = "unsupported" ]; then
        echo "Error: Unsupported OS ($OS_TYPE) or architecture ($ARCH_TYPE)"
        exit 1
    fi

    # Create temp directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Construct download URL
    # Note: Update this URL with the actual Claude CLI release URL
    local binary_name="claude"
    if [ "$os" = "windows" ]; then
        binary_name="claude.exe"
    fi

    local download_url="https://github.com/anthropics/anthropic-cli/releases/latest/download/claude-${os}-${arch}"
    if [ "$os" = "windows" ]; then
        download_url="${download_url}.exe"
    fi

    echo "Downloading from: $download_url"

    # Download binary
    if ! download_file "$download_url" "$binary_name"; then
        echo "Error: Failed to download Claude CLI binary."
        echo ""
        echo "Alternative installation methods:"
        echo "  - macOS: brew install anthropics/claude/claude"
        echo "  - Any OS with Node.js: npm install -g @anthropic-ai/claude-cli"
        echo "  - Manual: Visit https://github.com/anthropics/anthropic-cli/releases"
        exit 1
    fi

    # Make binary executable
    chmod +x "$binary_name"

    # Install to system directory
    echo "Installing to $INSTALL_DIR (may require sudo)..."
    if [ -w "$INSTALL_DIR" ]; then
        mv "$binary_name" "$INSTALL_DIR/claude"
    else
        sudo mv "$binary_name" "$INSTALL_DIR/claude"
    fi

    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

# Install for Linux
install_linux() {
    echo "Installing Claude CLI for Linux..."
    install_binary
}

# Install for Windows (WSL or Git Bash)
install_windows() {
    echo "Installing Claude CLI for Windows..."
    echo "Note: Running on Windows Subsystem for Linux (WSL) or Git Bash"

    # For WSL, use Linux binary
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "WSL detected, installing Linux binary..."
        install_binary
    else
        install_binary
    fi
}

# Main installation logic
main() {
    case "$OS_TYPE" in
        Darwin*)
            install_macos
            ;;
        Linux*)
            install_linux
            ;;
        CYGWIN*|MINGW*|MSYS*)
            install_windows
            ;;
        *)
            echo "Unsupported operating system: $OS_TYPE"
            echo "Trying binary installation..."
            install_binary
            ;;
    esac

    # Verify installation
    echo ""
    echo "Verifying installation..."
    if command_exists claude; then
        echo "✓ Claude CLI installed successfully!"
        claude --version 2>/dev/null || echo "Version: Latest"
        echo ""
        echo "To get started, run: claude auth login"
    else
        echo "✗ Installation may have failed. Please check the error messages above."
        echo ""
        echo "Alternative installation:"
        echo "  1. Visit: https://github.com/anthropics/anthropic-cli/releases"
        echo "  2. Download the binary for your OS and architecture"
        echo "  3. Move it to /usr/local/bin/claude and make it executable"
        exit 1
    fi
}

main
