#!/bin/bash
# posh-tui installer
# Usage: curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/master/install.sh | bash
#        To install a specific branch: curl ... | bash -s -- -b develop

set -e

INSTALL_DIR="$HOME/.posh-tui"
VENV_DIR="$INSTALL_DIR/.venv"
BIN_DIR="$HOME/.local/bin"
BRANCH="${1:-master}"

if [ "$1" == "-b" ]; then
    BRANCH="${2:-master}"
fi

echo "Installing posh-tui..."

# Check current version
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "  Current version: $(cd "$INSTALL_DIR" && git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
else
    echo "  No previous installation found"
fi

# Clone or update the repository
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "  Updating repository to branch: $BRANCH..."
    cd "$INSTALL_DIR"
    git fetch origin
    git reset --hard "origin/$BRANCH"
else
    echo "  Cloning repository (branch: $BRANCH)..."
    rm -rf "$INSTALL_DIR"
    git clone --quiet --branch "$BRANCH" https://github.com/daveposh/posh-tui.git "$INSTALL_DIR"
fi

NEW_VERSION=$(cd "$INSTALL_DIR" && git rev-parse --short HEAD)
echo "  Installed version: $NEW_VERSION"

# Create virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "  Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Install dependencies in venv
echo "  Installing dependencies..."
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet textual

# Create launcher script
echo "  Creating launcher..."
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/posh-tui" << LAUNCHER
#!/bin/bash
exec "$VENV_DIR/bin/python" "$INSTALL_DIR/posh_tui.py" "\$@"
LAUNCHER
chmod +x "$BIN_DIR/posh-tui"

echo ""
echo "posh-tui installed successfully! (version $NEW_VERSION, branch: $BRANCH)"
echo "Run 'posh-tui' to start."
echo ""
echo "To update: run 'posh-tui update'"
echo "To install a specific branch: posh-tui update -b <branch>"
echo "To uninstall: rm -rf $INSTALL_DIR && rm $BIN_DIR/posh-tui"
