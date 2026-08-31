#!/bin/bash
# Install Keyboard Layout Switcher plugin for Omarchy
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/xdamus/Keyboard-language-plugin-Omarchy/master/install.sh)"

set -euo pipefail

PLUGIN_ID="damus.keyboard-switcher"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
REPO_URL="https://github.com/xdamus/Keyboard-language-plugin-Omarchy.git"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Keyboard Layout Switcher Installer ===${NC}"

# Check if omarchy shell config exists
if [ ! -d "$HOME/.config/omarchy" ]; then
    echo -e "${RED}Error: Omarchy config not found at ~/.config/omarchy${NC}"
    echo "Omarchy may not be installed. Install Omarchy first."
    exit 1
fi

# Check if plugin already exists
if [ -d "$PLUGIN_DIR" ]; then
    echo -e "${YELLOW}Plugin already installed at $PLUGIN_DIR${NC}"
    read -p "Update/overwrite existing installation? [y/N]: " -r
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Check for git
if ! command -v git &>/dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}Cloning repository...${NC}"
rm -rf "$PLUGIN_DIR"
git clone --depth 1 "$REPO_URL" "$PLUGIN_DIR"

echo -e "${GREEN}Making scripts executable...${NC}"
chmod +x "$PLUGIN_DIR/bin/"*

echo -e "${GREEN}Plugin installed to $PLUGIN_DIR${NC}"
echo -e "${YELLOW}Reloading shell...${NC}"

# Try to reload the shell
if command -v omarchy-restart-shell &>/dev/null; then
    omarchy-restart-shell
else
    echo -e "${YELLOW}Could not auto-reload shell. Run omarchy-restart-shell manually.${NC}"
fi

echo -e "${GREEN}✓ Installation complete!${NC}"
echo -e "Look for the 'EN' indicator in your bar to use the plugin."
