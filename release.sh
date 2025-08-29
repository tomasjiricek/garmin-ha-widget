#!/bin/bash

# Garmin Connect IQ Widget Release Script
# Creates a new release with proper versioning and git management

set -e

echo "🚀 GARMIN HASSEQUENCE WIDGET RELEASE"
echo "===================================="

# Configuration
DIST_DIR="dist"
IQ_PACKAGE="$DIST_DIR/garmin-hassequence-widget.iq"
MANIFEST_FILE="manifest.xml"

# Parse version bump argument
VERSION_BUMP=""
if [ "$1" = "--major" ]; then
    VERSION_BUMP="major"
elif [ "$1" = "--minor" ]; then
    VERSION_BUMP="minor"
elif [ "$1" = "--patch" ]; then
    VERSION_BUMP="patch"
else
    echo "❌ Invalid or missing version bump argument"
    echo "   Usage: $0 [--major|--minor|--patch]"
    exit 1
fi

echo "📦 Version bump: $VERSION_BUMP"

# Function to get current version from manifest
get_manifest_version() {
    grep -oP '<iq:application[^>]*version="\K[^"]+' "$MANIFEST_FILE"
}

# Function to increment version
increment_version() {
    local version=$1
    local bump=$2

    # Split version into components
    IFS='.' read -r major minor patch <<< "$version"

    case $bump in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
    esac

    echo "$major.$minor.$patch"
}

# Function to get latest git tag
get_latest_tag() {
    git tag --sort=-version:refname | head -n1 2>/dev/null || echo ""
}

# Function to check if file has changed since last tag
file_changed_since_tag() {
    local file=$1
    local latest_tag=$(get_latest_tag)

    if [ -z "$latest_tag" ]; then
        return 0  # No previous tag, consider as changed
    fi

    # Check if file exists in the latest tag
    if git show "$latest_tag:$file" >/dev/null 2>&1; then
        # Compare file with version in latest tag
        if git diff --quiet "$latest_tag" "$file"; then
            return 1  # No changes
        else
            return 0  # Changes found
        fi
    else
        return 0  # File didn't exist in previous tag
    fi
}

# Check if IQ package exists
if [ ! -f "$IQ_PACKAGE" ]; then
    echo "❌ IQ package not found: $IQ_PACKAGE"
    echo "   Please run ./deploy.sh first"
    exit 1
fi

# Check if IQ package has changed since last version
if ! file_changed_since_tag "$IQ_PACKAGE"; then
    echo "❌ IQ package in dist/ is the same as the previous version"
    echo "   Did you forget to run ./deploy.sh after making changes?"
    exit 1
fi

echo "✅ IQ package is newer than previous version"

# Check for uncommitted changes (excluding dist folder)
if git status --porcelain --ignore-submodules | grep -v "^?? $DIST_DIR/" | grep -q .; then
    echo "❌ You have uncommitted changes"
    echo "   Please commit or stash them before creating a release"
    echo ""
    echo "   Uncommitted files:"
    git status --porcelain --ignore-submodules | grep -v "^?? $DIST_DIR/"
    exit 1
fi

echo "✅ No uncommitted changes (excluding dist/)"

# Determine new version
LATEST_TAG=$(get_latest_tag)
if [ -n "$LATEST_TAG" ]; then
    # Increment from latest tag
    NEW_VERSION=$(increment_version "$LATEST_TAG" "$VERSION_BUMP")
    echo "📈 Incrementing from tag $LATEST_TAG → $NEW_VERSION"
else
    # Use manifest version
    MANIFEST_VERSION=$(get_manifest_version)
    NEW_VERSION="$MANIFEST_VERSION"
    echo "📋 Using manifest version: $NEW_VERSION"
fi

# Create release branch
RELEASE_BRANCH="release/$NEW_VERSION"
echo "🌿 Creating release branch: $RELEASE_BRANCH"

if git show-ref --verify --quiet "refs/heads/$RELEASE_BRANCH"; then
    echo "❌ Branch $RELEASE_BRANCH already exists"
    exit 1
fi

git checkout -b "$RELEASE_BRANCH"
echo "✅ Created and switched to branch: $RELEASE_BRANCH"

# Rename IQ package to include version
VERSIONED_IQ="$DIST_DIR/garmin-hassequence-widget-$NEW_VERSION.iq"
mv "$IQ_PACKAGE" "$VERSIONED_IQ"
echo "🏷️  Renamed IQ package: $IQ_PACKAGE → $VERSIONED_IQ"

# Update manifest version if needed
if [ -z "$LATEST_TAG" ] || [ "$NEW_VERSION" != "$LATEST_TAG" ]; then
    # Update manifest.xml with new version
    sed -i "s/version=\"[^\"]*\"/version=\"$NEW_VERSION\"/" "$MANIFEST_FILE"
    echo "📝 Updated manifest.xml version to: $NEW_VERSION"
fi

# Commit changes
COMMIT_MESSAGE="release $NEW_VERSION"
git add "$VERSIONED_IQ" "$MANIFEST_FILE"
git commit -m "$COMMIT_MESSAGE"
echo "💾 Committed changes: $COMMIT_MESSAGE"

# Create git tag
git tag "$NEW_VERSION"
echo "🏷️  Created git tag: $NEW_VERSION"

# Push branch and tag
echo "📤 Pushing branch and tag..."
git push origin "$RELEASE_BRANCH"
git push origin "$NEW_VERSION"

echo ""
echo "🎉 RELEASE COMPLETE!"
echo "==================="
echo "🏷️  Version: $NEW_VERSION"
echo "🌿 Branch: $RELEASE_BRANCH"
echo "📦 Package: $VERSIONED_IQ"
echo ""
echo "🔗 CREATE PULL REQUEST:"
echo "   https://github.com/tomasjiricek/garmin-ha-widget/compare/master...$RELEASE_BRANCH"
echo ""
echo "📋 NEXT STEPS:"
echo "1. 🖱️  Click the link above to create a PR"
echo "2. 🔍 Review the changes"
echo "3. ✅ Merge the PR to master"
echo "4. 🏪 Upload to Connect IQ Store: https://developer.garmin.com/connect-iq/publish/"
echo ""
echo "✅ Release $NEW_VERSION ready! 🚀"
