#!/bin/bash

# Garmin Connect IQ Widget Deploy Script
# Prepares distribution package in dist/ folder

set -e

echo "🚀 GARMIN HASSEQUENCE WIDGET DEPLOY"
echo "==================================="

# Configuration
DIST_DIR="dist"
IQ_FILENAME="garmin-hassequence-widget.iq"
SOURCE_IQ="bin/$IQ_FILENAME"

# Create dist directory
mkdir -p "$DIST_DIR"

echo "📦 Preparing distribution package..."

# Ensure we're on develop branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "❌ You must be on the 'develop' branch to deploy"
    echo "   Current branch: $CURRENT_BRANCH"
    echo "   Expected branch: develop"
    echo ""
    echo "   To switch to develop branch:"
    echo "   git checkout develop"
    echo ""
    echo "   To see all branches:"
    echo "   git branch -a"
    exit 1
fi

echo "✅ On develop branch - ready to deploy"

# Check if source IQ file exists
if [ ! -f "$SOURCE_IQ" ]; then
    echo "❌ Source IQ file not found: $SOURCE_IQ"
    echo "   Please run ./build.sh first"
    exit 1
fi

# Define files to deploy (source_path:target_filename)
FILES_TO_DEPLOY=(
    "$SOURCE_IQ:$IQ_FILENAME"
    "README.md:README.md"
    "PRIVACY-POLICY.md:PRIVACY-POLICY.md"
    "resources/drawables/launcher_icon.png:launcher_icon.png"
)

# Copy files to dist directory
echo "📋 Copying files to $DIST_DIR/..."

for file_pair in "${FILES_TO_DEPLOY[@]}"; do
    IFS=':' read -r source target_filename <<< "$file_pair"
    cp "$source" "$DIST_DIR/$target_filename"
    echo "✅ Copied: $source → $DIST_DIR/$target_filename"
done

# Show package info
PACKAGE_SIZE=$(stat -c%s "$DIST_DIR/$IQ_FILENAME")

# Generate dynamic file list for summary
DOCUMENTATION_FILES=()
RESOURCE_FILES=()

for file_pair in "${FILES_TO_DEPLOY[@]}"; do
    IFS=':' read -r source target_filename <<< "$file_pair"
    if [[ "$target_filename" == *.md ]]; then
        DOCUMENTATION_FILES+=("$target_filename")
    elif [[ "$target_filename" == *.png ]]; then
        RESOURCE_FILES+=("$target_filename")
    fi
done

echo ""
echo "📦 DISTRIBUTION PACKAGE READY!"
echo "================================"
echo "📁 Location: $DIST_DIR/"
echo "📱 IQ Package: $IQ_FILENAME (${PACKAGE_SIZE} bytes)"

if [ ${#DOCUMENTATION_FILES[@]} -gt 0 ]; then
    echo "📄 Documentation: $(IFS=', '; echo "${DOCUMENTATION_FILES[*]}")"
fi

if [ ${#RESOURCE_FILES[@]} -gt 0 ]; then
    echo "🖼️  Resources: $(IFS=', '; echo "${RESOURCE_FILES[*]}")"
fi

echo ""
echo "🎯 NEXT STEPS:"
echo "1. 🧪 Test the package on your device"
echo "2. 🚀 Create release: ./release.sh [--major|--minor|--patch]"
echo ""
echo "✅ Deploy complete! 🎉"
