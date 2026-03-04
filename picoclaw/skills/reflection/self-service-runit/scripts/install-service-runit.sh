#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME=${1:-picoclaw}
SV_DIR="/etc/sv"
LOG_DIR="/var/log"

# Detect picoclaw installation
echo "Detecting picoclaw installation..."
PICOCLAW_PATH=$(command -v picoclaw)
MISE_BIN=$(command -v mise)

if [ -n "$MISE_BIN" ] && $MISE_BIN which picoclaw &>/dev/null; then
    EXEC_CMD="$MISE_BIN exec -- picoclaw gateway"
    echo "  - Detected mise-managed picoclaw, using: $EXEC_CMD"
elif [ -n "$PICOCLAW_PATH" ]; then
    EXEC_CMD="$PICOCLAW_PATH gateway"
    echo "  - Using binary path: $PICOCLAW_PATH"
else
    echo "Error: picoclaw not found. Please install it first."
    exit 1
fi

# Create service directory
SERVICE_DIR="$SV_DIR/$SERVICE_NAME"
echo "Creating service directory: $SERVICE_DIR"
mkdir -p "$SERVICE_DIR"

# Create log directory
LOG_SERVICE_DIR="$LOG_DIR/$SERVICE_NAME"
echo "Creating log directory: $LOG_SERVICE_DIR"
mkdir -p "$LOG_SERVICE_DIR"

# Get current user
CURRENT_USER=$(whoami)
PICOCLAW_HOME="${PICOCLAW_HOME:-$HOME/.picoclaw}"

# Create run script
cat > "$SERVICE_DIR/run" <<EOF
#!/bin/sh
exec 2>&1
export PICOCLAW_HOME="$PICOCLAW_HOME"
export PICOCLAW_SERVICE_NAME="$SERVICE_NAME"
export PATH="$PICOCLAW_HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
exec chpst -u $CURRENT_USER $EXEC_CMD
EOF
chmod +x "$SERVICE_DIR/run"

# Create log run script
cat > "$LOG_SERVICE_DIR/run" <<EOF
#!/bin/sh
exec chpst -u $CURRENT_USER svlogd -tt ./main
EOF
chmod +x "$LOG_SERVICE_DIR/run"

# Install picoclaw-service plugin
PICOCLAW_HOME="${PICOCLAW_HOME:-$HOME/.picoclaw}"
PLUGINS_DIR="$PICOCLAW_HOME/plugins"
echo "Installing picoclaw-service to $PLUGINS_DIR..."
mkdir -p "$PLUGINS_DIR"
cp "$SCRIPT_DIR/bin/picoclaw-service" "$PLUGINS_DIR/"
chmod +x "$PLUGINS_DIR/picoclaw-service"

# Install picoclaw-manager if not present
MANAGER="$PICOCLAW_HOME/bin/picoclaw-manager"
if [[ ! -x "$MANAGER" ]]; then
    echo "Installing picoclaw-manager to $MANAGER..."
    mkdir -p "$PICOCLAW_HOME/bin"
    cp "$SCRIPT_DIR/bin/picoclaw-manager" "$MANAGER"
    chmod +x "$MANAGER"
else
    echo "picoclaw-manager already installed, skipping"
fi

echo ""
echo "Installation complete!"
echo "  - Service: $SERVICE_DIR"
echo "  - Log: $LOG_SERVICE_DIR"
echo ""
echo "To enable the service:"
echo "  ln -s $SERVICE_DIR /var/service/"
echo ""
echo "To start the service:"
echo "  sv start $SERVICE_NAME"
echo ""
echo "To view logs:"
echo "  tail -f $LOG_SERVICE_DIR/current"
