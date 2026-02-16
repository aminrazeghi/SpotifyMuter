#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO="aminrazeghi/SpotifyMuter"
INSTALL_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"
BINARY_NAME="spotify_muter"
SERVICE_NAME="spotify-ad-muter.service"

echo -e "${GREEN}Spotify Ad Muter - Installation Script${NC}"
echo "========================================"

# Check if running on Linux
check_platform() {
    echo -e "${YELLOW}Checking platform compatibility...${NC}"
    
    # Check OS
    OS=$(uname -s)
    if [ "$OS" != "Linux" ]; then
        echo -e "${RED}Error: This script only supports Linux${NC}"
        echo "Detected OS: $OS"
        exit 1
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ]; then
        echo -e "${RED}Error: This script only supports x86_64 (AMD64) architecture${NC}"
        echo "Detected architecture: $ARCH"
        exit 1
    fi
    
    echo -e "${GREEN}Platform check passed: Linux x86_64${NC}"
}

# Function to get latest release URL
get_latest_release_url() {
    echo -e "${YELLOW}Fetching latest release...${NC}"
    RELEASE_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
        | grep "browser_download_url.*tar.gz" \
        | grep -v "sha256" \
        | cut -d '"' -f 4)
    
    if [ -z "$RELEASE_URL" ]; then
        echo -e "${RED}Error: Could not find latest release${NC}"
        echo "Please check that:"
        echo "  1. The repository '$REPO' is correct"
        echo "  2. A release has been published"
        exit 1
    fi
    
    echo -e "${GREEN}Found release: $RELEASE_URL${NC}"
}

# Create installation directory
create_install_dir() {
    echo -e "${YELLOW}Creating installation directory...${NC}"
    mkdir -p "$INSTALL_DIR"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo -e "${YELLOW}Adding $INSTALL_DIR to PATH...${NC}"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo -e "${GREEN}Added to .bashrc (restart shell or run: source ~/.bashrc)${NC}"
    fi
}

# Download and extract binary
download_binary() {
    echo -e "${YELLOW}Downloading binary...${NC}"
    cd /tmp
    curl -L -o spotify-ad-muter.tar.gz "$RELEASE_URL"
    
    echo -e "${YELLOW}Extracting...${NC}"
    tar -xzf spotify-ad-muter.tar.gz
    
    echo -e "${YELLOW}Installing to $INSTALL_DIR...${NC}"
    mv spotify_muter "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
    
    rm spotify-ad-muter.tar.gz
    echo -e "${GREEN}Binary installed successfully!${NC}"
}

# Create systemd service
create_systemd_service() {
    echo -e "${YELLOW}Creating systemd user service...${NC}"
    mkdir -p "$SERVICE_DIR"
    
    cat > "$SERVICE_DIR/$SERVICE_NAME" <<EOF
[Unit]
Description=Spotify Ad Muter Service
After=default.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/$BINARY_NAME
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
    
    echo -e "${GREEN}Systemd service created!${NC}"
}

# Enable and start service
enable_service() {
    echo -e "${YELLOW}Enabling and starting service...${NC}"
    systemctl --user daemon-reload
    systemctl --user enable "$SERVICE_NAME"
    systemctl --user start "$SERVICE_NAME"
    
    echo -e "${GREEN}Service started!${NC}"
}

# Check service status
check_status() {
    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo "Service status:"
    systemctl --user status "$SERVICE_NAME" --no-pager || true
    echo ""
    echo -e "${YELLOW}Useful commands:${NC}"
    echo "  Check status:  systemctl --user status $SERVICE_NAME"
    echo "  View logs:     journalctl --user -u $SERVICE_NAME -f"
    echo "  Stop service:  systemctl --user stop $SERVICE_NAME"
    echo "  Start service: systemctl --user start $SERVICE_NAME"
    echo "  Disable:       systemctl --user disable $SERVICE_NAME"
}

# Main installation flow
main() {
    check_platform
    # Check if REPO is still default
    if [ "$REPO" = "YOUR_GITHUB_USERNAME/YOUR_REPO_NAME" ]; then
        echo -e "${RED}Error: Please update the REPO variable in this script${NC}"
        echo "Edit this file and set REPO to your GitHub repository (e.g., 'username/spotify-ad-muter')"
        exit 1
    fi
    
    get_latest_release_url
    create_install_dir
    download_binary
    create_systemd_service
    enable_service
    check_status
}

# Run main function
main
