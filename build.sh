#!/bin/bash

# Garmin HA Widget Build Script
# Builds widget and prepares it for local testing

set -e

echo "🔨 GARMIN HA WIDGET BUILD"
echo "========================="

# Step 1: Build the widget
echo "📦 Building widget..."
if ! ./build.sh; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully"

# Step 2: Check for package file
PACKAGE_FILE="bin/garmin-ha-widget.iq"
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ Package file not found: $PACKAGE_FILE"
    exit 1
fi

PACKAGE_SIZE=$(stat -c%s "$PACKAGE_FILE")
echo "📦 Package: $(basename $PACKAGE_FILE) (${PACKAGE_SIZE} bytes)"

# Step 3: Copy to easy access location
echo ""
echo "📂 Preparing for testing..."
cp "$PACKAGE_FILE" .
echo "✅ Copied $PACKAGE_FILE to current directory for easy access"

# Step 4: Show build completion
echo ""
echo "🎯 BUILD COMPLETE!"
echo "=================="
echo ""
echo "📦 Package: garmin-ha-widget.iq (${PACKAGE_SIZE} bytes)"
echo ""
echo "📱 TESTING OPTIONS:"
echo "1. 🖥️  Simulator: Use Connect IQ SDK simulator"
echo "2. 📱 Real Device: Copy garmin-ha-widget.iq to your watch"
echo "3. 💻 Garmin Express: Install via Garmin Express desktop app"
echo ""
echo "⚙️  CONFIGURATION REQUIRED:"
echo "• Config URL: Your JSON configuration file URL"
echo "• API Key: Your Home Assistant long-lived access token"
echo "• HA Server URL: (optional - auto-derived from config URL)"
echo ""
echo "🔗 QUICK LINKS:"
echo "• Run tests: ./test.sh"
echo "• Example config: ./example-config.json"
echo "• Validation: python3 validate-config.py your-config.json"
echo "• Store submission prep: ./prepare-submission.sh"
echo ""
echo "✅ Ready for testing! 🎯"
