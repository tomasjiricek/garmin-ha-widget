#!/bin/bash

# Garmin Connect IQ Store Deployment Script
echo "🚀 GARMIN CONNECT IQ STORE DEPLOYMENT"
echo "====================================="

# Check package
if [ -f "bin/garmin-ha-widget.prg" ]; then
    SIZE=$(stat -c%s "bin/garmin-ha-widget.prg")
    echo "✅ Package: bin/garmin-ha-widget.prg ($SIZE bytes)"
else
    echo "❌ Package not found"
    exit 1
fi

# Check icon
if [ -f "resources/drawables/launcher_icon.png" ]; then
    echo "✅ Icon: resources/drawables/launcher_icon.png"
else
    echo "❌ Icon not found"
fi

# Check docs
echo ""
echo "📋 REQUIRED DOCUMENTS:"
for file in STORE-DESCRIPTION.md PRIVACY-POLICY.md RELEASE-NOTES.md; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file"
    fi
done

# Create submission folder
echo ""
echo "📦 Creating submission package..."
mkdir -p connect-iq-submission
cp bin/garmin-ha-widget.prg connect-iq-submission/
cp resources/drawables/launcher_icon.png connect-iq-submission/ 2>/dev/null || echo "⚠️  Icon copy failed"
cp STORE-DESCRIPTION.md connect-iq-submission/
cp PRIVACY-POLICY.md connect-iq-submission/
cp RELEASE-NOTES.md connect-iq-submission/
cp example-config.json connect-iq-submission/

echo ""
echo "🎯 SUBMIT TO CONNECT IQ STORE:"
echo "1. Go to: https://developer.garmin.com/connect-iq/publish/"
echo "2. Upload: connect-iq-submission/garmin-ha-widget.prg"
echo "3. Copy description from: connect-iq-submission/STORE-DESCRIPTION.md"
echo "4. Copy privacy policy from: connect-iq-submission/PRIVACY-POLICY.md"
echo "5. Set category: Productivity"
echo "6. Add permission: Communications"
echo ""
echo "🚀 Ready for submission!"
