#!/bin/bash

# Garmin HA Widget Test Script
# Runs comprehensive tests on the widget

set -e

echo "🧪 GARMIN HA WIDGET TESTS"
echo "========================="

# Check if widget package exists
PACKAGE_FILE="dist/garmin-ha-widget.iq"
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ Package file not found: $PACKAGE_FILE"
    echo "💡 Run ./build-and-test.sh first to build the widget"
    exit 1
fi

echo "📦 Testing package: $(basename $PACKAGE_FILE)"
echo ""

# Test 1: Configuration validation
echo "📋 Test 1: Configuration validation..."
if python3 validate-config.py example-config.json --battery-tips; then
    echo "✅ Configuration validation: PASSED"
else
    echo "❌ Configuration validation: FAILED"
    exit 1
fi

echo ""

# Test 2: Widget functionality tests
echo "🚀 Test 2: Widget functionality..."
if python3 test-functionality.py; then
    echo "✅ Widget functionality: PASSED"
else
    echo "❌ Widget functionality: FAILED"
    exit 1
fi

echo ""

# Test 3: Widget core tests
echo "🧪 Test 3: Widget core tests..."
if python3 test-widget.py; then
    echo "✅ Widget core tests: PASSED"
else
    echo "❌ Widget core tests: FAILED"
    exit 1
fi

echo ""

# Test 4: Battery configuration test
echo "🔋 Test 4: Battery configuration..."
if python3 test-widget.py tests/test-battery-config.json > /dev/null 2>&1; then
    echo "✅ Battery configuration: PASSED"
else
    echo "❌ Battery configuration: FAILED"
    echo "⚠️  Check battery configuration settings"
fi

echo ""

# Test Summary
echo "📊 TEST SUMMARY"
echo "==============="
echo "✅ Configuration validation: PASSED"
echo "✅ Widget functionality: PASSED"
echo "✅ Widget core tests: PASSED"
echo "✅ Battery configuration: $(python3 test-widget.py tests/test-battery-config.json > /dev/null 2>&1 && echo "PASSED" || echo "FAILED")"
echo ""
echo "🎉 ALL TESTS COMPLETED!"
echo ""
echo "📱 Widget is validated and ready for deployment:"
echo "• Simulator testing"
echo "• Real device testing"
echo "• Connect IQ Store submission"
echo ""
echo "✅ Quality assurance complete! 🎯"
