#!/bin/bash

# Garmin Connect IQ Widget Build Script

# Set variables
WIDGET_NAME="garmin-ha-widget"
OUTPUT_DIR="bin"
DEVELOPER_KEY="developer_key.der"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Check if Connect IQ SDK is available
if ! command -v monkeyc &> /dev/null; then
    echo "Error: Garmin Connect IQ SDK not found. Please install it first."
    echo "Download from: https://developer.garmin.com/connect-iq/sdk/"
    exit 1
fi

# Check if developer key exists
if [ ! -f "$DEVELOPER_KEY" ]; then
    echo "Warning: Developer key not found. Creating a dummy key for testing."
    echo "For production, generate a real key using: openssl genrsa -out developer_key.pem 4096"
    echo "Then convert to DER format: openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt"
    
    # Create a dummy key for development
    openssl genrsa -out developer_key.pem 4096 2>/dev/null
    openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt 2>/dev/null
    rm developer_key.pem
fi

# Build the widget
echo "Building $WIDGET_NAME..."
monkeyc -o $OUTPUT_DIR/$WIDGET_NAME.prg -f monkey.jungle -y $DEVELOPER_KEY

if [ $? -eq 0 ]; then
    echo "Build successful! Output: $OUTPUT_DIR/$WIDGET_NAME.prg"
    echo ""
    echo "To install on your watch:"
    echo "1. Copy $WIDGET_NAME.prg to your watch's GARMIN/Apps folder"
    echo "2. Or use Garmin Express to install the widget"
    echo ""
    echo "To configure:"
    echo "1. Open Garmin Connect IQ app"
    echo "2. Go to your device settings"
    echo "3. Find 'HA Widget' and configure:"
    echo "   - Config URL: URL to your JSON configuration file"
    echo "   - API Key: Your Home Assistant long-lived access token"
    echo "   - HA Server URL: Your Home Assistant server URL"
else
    echo "Build failed! Check the errors above."
    exit 1
fi
