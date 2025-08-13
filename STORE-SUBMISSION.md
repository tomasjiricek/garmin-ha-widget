# Connect IQ Store Submission Guide

## 📋 Pre-Submission Checklist

### 1. Install Connect IQ SDK
```bash
# Download from: https://developer.garmin.com/connect-iq/sdk/
# Install and add to PATH
export PATH=$PATH:/path/to/connectiq-sdk-linux/bin
```

### 2. Build Package
```bash
cd /path/to/garmin-ha-widget
./build.sh
# This creates: bin/garmin-ha-widget.iq
```

### 3. Test Thoroughly
- Use Connect IQ Simulator for all supported devices
- Test on real hardware
- Validate configuration loading and key sequences

## 🏪 Store Submission Steps

### 1. Create Developer Account
- Go to: https://developer.garmin.com/
- Sign up for Connect IQ developer account
- Complete profile and agreements

### 2. Access Store Portal
- Navigate to: https://developer.garmin.com/connect-iq/publish/
- Click "Submit New App"

### 3. Fill App Information

#### Basic Details
- **App Name**: Home Assistant Widget
- **App Type**: Widget
- **Category**: Productivity
- **Short Description**: Control Home Assistant with key sequences on your Garmin watch
- **Long Description**: [See STORE-DESCRIPTION.md]

#### Technical Details
- **Package File**: Upload `bin/garmin-ha-widget.prg`
- **Min SDK Version**: 3.0.0
- **Supported Devices**: 
  - Fenix 6, 6S, 6X Pro
  - Fenix 7, 7S
  - Vivoactive 4, 4S
  - Venu, Venu 2, 2S
  - Forerunner 745, 945

#### Permissions
- **Communications**: Required for HTTP requests to Home Assistant

### 4. Upload Assets

#### App Icon
- **Size**: 80x80 pixels
- **Format**: PNG with transparency
- **Content**: Home Assistant logo or house icon

#### Screenshots
- **Required**: One per supported device series
- **Size**: Device-specific screen resolution
- **Content**: Widget showing configuration and key sequence

### 5. Privacy & Compliance

#### Data Usage
- Network requests to user-configured URLs
- Storage of API tokens locally on device
- No data collection or analytics

#### Privacy Policy
- [See PRIVACY-POLICY.md]

### 6. Submit for Review
- Review all information
- Submit for Garmin review process
- Typical review time: 3-7 business days

## 📸 Required Screenshots

Generate screenshots showing:
1. Widget on watch face
2. Configuration screen
3. Key sequence in progress
4. Home Assistant action triggered

## 🔄 Post-Submission

### If Approved
- App goes live on Connect IQ Store
- Users can install via Garmin Connect IQ app

### If Changes Needed
- Address review feedback
- Increment version number
- Re-submit updated package

## 📞 Support

- **Developer Support**: https://developer.garmin.com/connect-iq/support/
- **Store Guidelines**: https://developer.garmin.com/connect-iq/overview/
