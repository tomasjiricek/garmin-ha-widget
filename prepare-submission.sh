#!/bin/bash

# Garmin Connect IQ Store Submission Preparation Script
# Prepares and validates files for Connect IQ Store submission

set -e

echo "📦 GARMIN CONNECT IQ STORE SUBMISSION PREP"
echo "==========================================="

# Configuration
WIDGET_NAME="Home Assistant Widget"
PACKAGE_FILE="bin/garmin-ha-widget.iq"
ICON_FILE="resources/drawables/launcher_icon.png"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Step 1: Verify Build
print_step "Verifying build..."
if [ ! -f "$PACKAGE_FILE" ]; then
    print_error "Package file not found: $PACKAGE_FILE"
    echo "Run ./build.sh first to build the widget"
    exit 1
fi

PACKAGE_SIZE=$(stat -c%s "$PACKAGE_FILE")
print_success "Package found: $(basename $PACKAGE_FILE) (${PACKAGE_SIZE} bytes)"

# Step 2: Verify Icon
print_step "Verifying app icon..."
if [ ! -f "$ICON_FILE" ]; then
    print_error "App icon not found: $ICON_FILE"
    exit 1
fi

# Check icon dimensions
ICON_DIMS=$(identify "$ICON_FILE" 2>/dev/null | cut -d' ' -f3 || echo "unknown")
if [ "$ICON_DIMS" = "80x80" ]; then
    print_success "App icon: 80x80 PNG ✓"
else
    print_warning "App icon dimensions: $ICON_DIMS (should be 80x80)"
fi

# Step 3: Validate Configuration
print_step "Validating example configuration..."
if [ -f "validate-config.py" ] && [ -f "example-config.json" ]; then
    python3 validate-config.py example-config.json --battery-tips > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_success "Configuration validation passed"
    else
        print_warning "Configuration validation had warnings"
    fi
else
    print_warning "Validation tools not found"
fi

# Step 4: Check required files
print_step "Checking required documentation..."

REQUIRED_FILES=(
    "STORE-DESCRIPTION.md"
    "PRIVACY-POLICY.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Found: $file"
    else
        print_error "Missing: $file"
        exit 1
    fi
done

# Step 5: Display submission info
echo ""
print_step "CONNECT IQ STORE SUBMISSION INFORMATION"
echo "========================================"

echo ""
echo "📦 PACKAGE DETAILS:"
echo "   File: $PACKAGE_FILE"
echo "   Size: $PACKAGE_SIZE bytes"
echo "   Icon: $ICON_FILE"

echo ""
echo "🎯 APP INFORMATION:"
echo "   Name: $WIDGET_NAME"
echo "   Type: Widget"
echo "   Category: Productivity"
echo "   Version: 1.0.0"
echo "   Min SDK: 3.0.0"

echo ""
echo "📱 SUPPORTED DEVICES:"
echo "   • Fenix 6, 6S, 6X Pro"
echo "   • Fenix 7, 7S"
echo "   • Vivoactive 4, 4S"

echo ""
echo "⚡ KEY FEATURES:"
echo "   • Remote JSON configuration"
echo "   • Battery-optimized (<2% daily drain)"
echo "   • Configurable key sequences"
echo "   • Home Assistant integration"
echo "   • Smart caching and offline mode"

echo ""
echo "🔐 PERMISSIONS:"
echo "   • Communications (for HTTP requests)"

echo ""
print_step "SUBMISSION STEPS"
echo "=================="

echo ""
echo "1. 🌐 Go to: https://developer.garmin.com/connect-iq/publish/"
echo ""
echo "2. 📝 Create new app with these details:"
echo "   App Name: $WIDGET_NAME"
echo "   Type: Widget"
echo "   Category: Productivity"
echo ""
echo "3. 📦 Upload package:"
echo "   File: $(pwd)/$PACKAGE_FILE"
echo ""
echo "4. 📋 Copy description from:"
echo "   $(pwd)/STORE-DESCRIPTION.md"
echo ""
echo "5. 🔒 Copy privacy policy from:"
echo "   $(pwd)/PRIVACY-POLICY.md"
echo ""
echo "6. 📸 Upload screenshots (generate from simulator)"
echo ""
echo "7. ✅ Submit for review"

echo ""
print_step "POST-SUBMISSION"
echo "=================="

echo ""
echo "📅 Review time: 3-7 business days"
echo "📧 You'll receive email updates on status"
echo "🔄 If changes needed, update version and resubmit"
echo ""

# Step 6: Create submission package
print_step "Creating submission package..."

SUBMISSION_DIR="connect-iq-submission"
mkdir -p "$SUBMISSION_DIR"

# Copy essential files
cp "$PACKAGE_FILE" "$SUBMISSION_DIR/"
cp "$ICON_FILE" "$SUBMISSION_DIR/"
cp "STORE-DESCRIPTION.md" "$SUBMISSION_DIR/"
cp "PRIVACY-POLICY.md" "$SUBMISSION_DIR/"

# Create submission checklist
cat > "$SUBMISSION_DIR/SUBMISSION-CHECKLIST.txt" << 'EOF'
CONNECT IQ STORE SUBMISSION CHECKLIST

□ Developer account created at developer.garmin.com
□ Package file uploaded (garmin-ha-widget.prg)
□ App icon uploaded (launcher_icon.png)
□ Store description copied from STORE-DESCRIPTION.md
□ Privacy policy copied from PRIVACY-POLICY.md
□ Device compatibility verified
□ Permissions set to "Communications"
□ Category set to "Productivity"
□ Screenshots uploaded (generate from simulator)
□ App submitted for review

POST-SUBMISSION:
□ Monitor email for review updates
□ Respond to any review feedback
□ App goes live after approval
EOF

print_success "Submission package created in: $SUBMISSION_DIR/"

echo ""
print_step "FINAL VERIFICATION"
echo "=================="

# Check if we can generate a test build for submission
if command -v monkeyc >/dev/null 2>&1; then
    echo ""
    print_step "Testing final build..."
    
    # Create a clean build for submission
    ./build.sh > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Final build successful - ready for submission!"
    else
        print_error "Build failed - check build.sh output"
        exit 1
    fi
else
    print_warning "Connect IQ SDK not found - assuming build is current"
fi

echo ""
echo "🎉 ${GREEN}SUBMISSION PACKAGE READY!${NC}"
echo ""
echo "📁 Files prepared in: $SUBMISSION_DIR/"
echo "🌐 Manual upload required at: https://developer.garmin.com/connect-iq/publish/"
echo ""
echo "Next: Follow the submission steps above to upload manually. 🚀"
