#!/bin/bash

echo "Installing Claude Code..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if curl is available
if ! command_exists curl; then
    echo "Error: curl is not installed. Please install curl first."
    echo "  Ubuntu/Debian: sudo apt-get install curl"
    echo "  CentOS/RHEL: sudo yum install curl"
    exit 1
fi

# Run official Claude Code installation script
echo "Running official Claude Code installation script..."
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation
echo ""
echo "Verifying installation..."
if command_exists claude; then
    echo "✓ Claude Code installed successfully!"
    claude --version 2>/dev/null || echo "Installation complete"
    echo ""
    echo "To get started, run: claude"
else
    echo "✗ Installation may have failed. Please check the error messages above."
    echo ""
    echo "Alternative installation methods:"
    echo "  - npm: npm install -g @anthropic-ai/claude-code"
    echo "  - Manual: curl -fsSL https://claude.ai/install.sh | bash"
    exit 1
fi
