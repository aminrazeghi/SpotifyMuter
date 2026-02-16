#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"
BINARY_NAME="spotify_muter"
SERVICE_NAME="spotify-ad-muter.service"

echo -e "${YELLOW}Spotify Ad Muter - Uninstallation Script${NC}"
echo "=========================================="

# Stop and disable service
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo -e "${YELLOW}Stopping service...${NC}"
    systemctl --user stop "$SERVICE_NAME"
fi

if systemctl --user is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo -e "${YELLOW}Disabling service...${NC}"
    systemctl --user disable "$SERVICE_NAME"
fi

# Remove service file
if [ -f "$SERVICE_DIR/$SERVICE_NAME" ]; then
    echo -e "${YELLOW}Removing service file...${NC}"
    rm "$SERVICE_DIR/$SERVICE_NAME"
    systemctl --user daemon-reload
fi

# Remove binary
if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
    echo -e "${YELLOW}Removing binary...${NC}"
    rm "$INSTALL_DIR/$BINARY_NAME"
fi

echo -e "${GREEN}Uninstallation complete!${NC}"
echo ""
echo "Note: $INSTALL_DIR is still in your PATH (.bashrc)"
echo "You can manually remove it if no longer needed."
