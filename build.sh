#!/bin/bash

# Garmin Connect IQ Widget Build Script
# Compiles the widget and prepares it for deployment

set -e

echo "🔨 GARMIN HA WIDGET BUILD"
echo "========================="

# Configuration
WIDGET_NAME="garmin-ha-widget"
OUTPUT_DIR="dist"
DEVELOPER_KEY="developer_key.der"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

echo "📦 Building widget..."

# Check if Connect IQ SDK is available
if command -v monkeyc &> /dev/null; then
    echo "✅ Connect IQ SDK found in PATH"
elif [ -d "$HOME/.Garmin/ConnectIQ/Sdks" ]; then
    # Find the latest SDK version dynamically
    SDK_PATH=$(find "$HOME/.Garmin/ConnectIQ/Sdks" -name "connectiq-sdk-*" -type d | sort -V | tail -1)
    if [ -n "$SDK_PATH" ] && [ -d "$SDK_PATH/bin" ]; then
        export PATH="$SDK_PATH/bin:$PATH"
        echo "✅ Using Connect IQ SDK: $SDK_PATH"
    else
        echo "❌ Connect IQ SDK not found in $HOME/.Garmin/ConnectIQ/Sdks"
        exit 1
    fi
else
    echo "❌ Connect IQ SDK not found. Please install from:"
    echo "   https://developer.garmin.com/connect-iq/sdk/"
    exit 1
fi

# Generate developer key if it doesn't exist
if [ ! -f "$DEVELOPER_KEY" ]; then
    echo "🔑 Generating developer key..."
    openssl genrsa -out "$DEVELOPER_KEY" 4096
fi

# Build the widget in .iq format for Connect IQ Store
echo "🛠️ Compiling widget..."
monkeyc -e -o "$OUTPUT_DIR/$WIDGET_NAME.iq" -f monkey.jungle -y "$DEVELOPER_KEY"

if [ $? -eq 0 ]; then
    PACKAGE_SIZE=$(stat -c%s "$OUTPUT_DIR/$WIDGET_NAME.iq")
    echo "✅ Build completed successfully"
    echo "📦 Package: $WIDGET_NAME.iq (${PACKAGE_SIZE} bytes)"
    
    # Copy distribution files to dist directory
    echo "📂 Preparing distribution package..."
    cp README.md "$OUTPUT_DIR/"
    cp PRIVACY-POLICY.md "$OUTPUT_DIR/"
    cp resources/drawables/launcher_icon.png "$OUTPUT_DIR/"
    
    echo "📦 Distribution package ready in $OUTPUT_DIR/"
else
    echo "❌ Build failed!"
    exit 1
fi

# Show completion info
echo ""
echo "🎯 BUILD COMPLETE!"
echo "=================="
echo ""
echo "📱 NEXT STEPS:"
echo "1. 🧪 Run tests: ./test.sh"
echo "2. 🖥️  Test in simulator: Use Connect IQ SDK"
echo "3. 📱 Install on device: Copy dist/garmin-ha-widget.iq to watch"
echo "4. 🏪 Upload to store: https://developer.garmin.com/connect-iq/publish/"
echo ""
echo "⚙️  CONFIGURATION REQUIRED:"
echo "• Config URL: Your JSON configuration file URL"
echo "• API Key: Your Home Assistant long-lived access token"
echo "• HA Server URL: (optional - auto-derived from config URL)"
echo ""
echo "🔗 QUICK LINKS:"
echo "• Example config: ./example-config.json"
echo "• Config validation: python3 validate-config.py your-config.json"
echo ""
echo "✅ Ready for testing! 🎯"
