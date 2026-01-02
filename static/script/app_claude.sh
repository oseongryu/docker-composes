#!/bin/bash

echo "Installing Claude CLI..."

# Detect OS
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)

echo "Detected OS: $OS_TYPE"
echo "Architecture: $ARCH_TYPE"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install for macOS
install_macos() {
    echo "Installing Claude CLI for macOS..."

    if command_exists brew; then
        echo "Homebrew detected. Installing via brew..."
        brew tap anthropics/claude
        brew install claude
    else
        echo "Homebrew not found. Installing via npm..."
        install_via_npm
    fi
}

# Install for Linux
install_linux() {
    echo "Installing Claude CLI for Linux..."

    # Check if running on specific architecture
    if [ "$ARCH_TYPE" = "aarch64" ] || [ "$ARCH_TYPE" = "arm64" ]; then
        echo "ARM64 architecture detected"
    else
        echo "AMD64/x86_64 architecture detected"
    fi

    install_via_npm
}

# Install for Windows (WSL or Git Bash)
install_windows() {
    echo "Installing Claude CLI for Windows..."
    echo "Note: Running on Windows Subsystem for Linux (WSL) or Git Bash"

    install_via_npm
}

# Install via npm (cross-platform)
install_via_npm() {
    if command_exists npm; then
        echo "npm detected. Installing Claude CLI globally..."
        npm install -g @anthropic-ai/claude-cli
    elif command_exists node; then
        echo "Node.js detected but npm not found. Please install npm first."
        exit 1
    else
        echo "Error: Node.js and npm are required but not installed."
        echo ""
        echo "Please install Node.js first:"
        echo "  - macOS: brew install node"
        echo "  - Linux (Ubuntu/Debian): sudo apt install -y nodejs npm"
        echo "  - Linux (RHEL/CentOS): sudo yum install -y nodejs npm"
        echo "  - Windows: Download from https://nodejs.org/"
        exit 1
    fi
}

# Main installation logic
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
        echo "Trying generic npm installation..."
        install_via_npm
        ;;
esac

# Verify installation
echo ""
echo "Verifying installation..."
if command_exists claude; then
    echo "✓ Claude CLI installed successfully!"
    echo "Version: $(claude --version)"
    echo ""
    echo "To get started, run: claude auth login"
else
    echo "✗ Installation may have failed. Please check the error messages above."
    exit 1
fi
