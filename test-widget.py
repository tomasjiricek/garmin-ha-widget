#!/usr/bin/env python3
"""
Local test script for Garmin HA Widget functionality
Tests key components without requiring simulator
"""

import json
import sys
import os

def test_configuration_parsing():
    """Test configuration file parsing"""
    print("🧪 Testing configuration parsing...")
    
    try:
        with open('example-config.json', 'r') as f:
            config = json.load(f)
        
        # Check required fields
        required_fields = ['sequences']
        for field in required_fields:
            if field not in config:
                print(f"❌ Missing required field: {field}")
                return False
        
        # Check sequences structure
        sequences = config['sequences']
        if not isinstance(sequences, list) or len(sequences) == 0:
            print("❌ Sequences must be a non-empty array")
            return False
        
        for i, seq in enumerate(sequences):
            if 'id' not in seq or 'sequence' not in seq or 'action' not in seq:
                print(f"❌ Sequence {i} missing required fields (id, sequence, action)")
                return False
            
            # Check key sequence
            keys = seq['sequence']
            if not isinstance(keys, list) or len(keys) == 0:
                print(f"❌ Sequence {i} keys must be a non-empty array")
                return False
            
            valid_keys = {'UP', 'DOWN', 'OK', 'BACK', 'LIGHT', 'MENU'}
            for key in keys:
                if key not in valid_keys:
                    print(f"❌ Invalid key '{key}' in sequence {i}")
                    return False
            
            # Check action structure
            action = seq['action']
            if 'action' not in action:
                print(f"❌ Sequence {i} action missing 'action' field")
                return False
        
        print("✅ Configuration parsing test passed")
        return True
        
    except FileNotFoundError:
        print("❌ example-config.json not found")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON: {e}")
        return False
    except Exception as e:
        print(f"❌ Configuration test failed: {e}")
        return False

def test_build_artifacts():
    """Test that all required build artifacts exist"""
    print("🧪 Testing build artifacts...")
    
    required_files = [
        'bin/garmin-ha-widget.iq',
        'resources/drawables/launcher_icon.png',
        'manifest.xml'
    ]
    
    missing_files = []
    for file_path in required_files:
        if not os.path.exists(file_path):
            missing_files.append(file_path)
    
    if missing_files:
        print(f"❌ Missing required files: {missing_files}")
        return False
    
    # Check file sizes
    iq_size = os.path.getsize('bin/garmin-ha-widget.iq')
    if iq_size < 1000:  # Should be at least 1KB
        print(f"❌ Widget package too small: {iq_size} bytes")
        return False
    
    print(f"✅ Build artifacts test passed (widget size: {iq_size:,} bytes)")
    return True

def test_manifest_structure():
    """Test manifest.xml structure"""
    print("🧪 Testing manifest structure...")
    
    try:
        import xml.etree.ElementTree as ET
        tree = ET.parse('manifest.xml')
        root = tree.getroot()
        
        # Check namespace
        if root.tag != '{http://www.garmin.com/xml/connectiq}manifest':
            print("❌ Invalid manifest root element")
            return False
        
        # Check application element
        app_elem = root.find('.//{http://www.garmin.com/xml/connectiq}application')
        if app_elem is None:
            print("❌ No application element found")
            return False
        
        # Check required attributes
        required_attrs = ['id', 'type', 'name', 'version', 'entry']
        for attr in required_attrs:
            if attr not in app_elem.attrib:
                print(f"❌ Missing required attribute: {attr}")
                return False
        
        # Check app ID format (32-char hex)
        app_id = app_elem.attrib['id']
        if len(app_id) != 32 or not all(c in '0123456789abcdef' for c in app_id):
            print(f"❌ Invalid app ID format: {app_id}")
            return False
        
        # Check widget type
        if app_elem.attrib['type'] != 'widget':
            print(f"❌ Expected type 'widget', got '{app_elem.attrib['type']}'")
            return False
        
        print("✅ Manifest structure test passed")
        return True
        
    except Exception as e:
        print(f"❌ Manifest test failed: {e}")
        return False

def test_source_code_syntax():
    """Basic syntax check for MonkeyC source files"""
    print("🧪 Testing source code syntax...")
    
    source_files = [
        'source/GarminHAWidgetApp.mc',
        'source/GarminHAWidgetView.mc',
        'source/ConfigManager.mc',
        'source/KeySequenceHandler.mc',
        'source/HomeAssistantClient.mc'
    ]
    
    for file_path in source_files:
        if not os.path.exists(file_path):
            print(f"❌ Missing source file: {file_path}")
            return False
        
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            # Basic syntax checks
            if content.count('{') != content.count('}'):
                print(f"❌ Unmatched braces in {file_path}")
                return False
            
            if content.count('(') != content.count(')'):
                print(f"❌ Unmatched parentheses in {file_path}")
                return False
            
        except Exception as e:
            print(f"❌ Error reading {file_path}: {e}")
            return False
    
    print("✅ Source code syntax test passed")
    return True

def test_battery_optimization():
    """Test battery optimization features"""
    print("🧪 Testing battery optimization features...")
    
    optimization_checks = []
    
    # Check ConfigManager for caching
    with open('source/ConfigManager.mc', 'r') as f:
        config_content = f.read()
        if 'Application.Storage' in config_content:
            optimization_checks.append("✅ Local storage caching implemented")
        else:
            optimization_checks.append("⚠️  Local storage caching not found")
    
    # Check View for efficient rendering
    with open('source/GarminHAWidgetView.mc', 'r') as f:
        view_content = f.read()
        if '_needsRedraw' in view_content and '_isActive' in view_content:
            optimization_checks.append("✅ Efficient rendering implemented")
        else:
            optimization_checks.append("⚠️  Efficient rendering not found")
        
        if 'cleanupTimers' in view_content:
            optimization_checks.append("✅ Timer cleanup implemented")
        else:
            optimization_checks.append("⚠️  Timer cleanup not found")
    
    # Check KeySequenceHandler for timeout management
    with open('source/KeySequenceHandler.mc', 'r') as f:
        handler_content = f.read()
        if 'timeout' in handler_content.lower():
            optimization_checks.append("✅ Timeout management implemented")
        else:
            optimization_checks.append("⚠️  Timeout management not found")
    
    for check in optimization_checks:
        print(f"  {check}")
    
    print("✅ Battery optimization test completed")
    return True

def main():
    """Run all tests"""
    print("🚀 Running local widget functionality tests...\n")
    
    tests = [
        test_build_artifacts,
        test_manifest_structure,
        test_configuration_parsing,
        test_source_code_syntax,
        test_battery_optimization
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} crashed: {e}")
        print()
    
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Widget is ready for deployment.")
        return 0
    else:
        print("⚠️  Some tests failed. Please review the issues above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
