# Deployment Guide

This guide will help you build and deploy the Garmin Home Assistant Widget to your watch.

## Prerequisites

1. **Garmin Connect IQ SDK**: Download from [developer.garmin.com](https://developer.garmin.com/connect-iq/sdk/)
2. **Compatible Garmin Watch**: Fenix 6/7
3. **Home Assistant Server**: With API access enabled
4. **Web Server**: To host your configuration JSON file

## Step 1: Setup Development Environment

1. Install the Connect IQ SDK following Garmin's instructions
2. Ensure `monkeyc` command is available in your PATH
3. Clone or download this widget source code

## Step 2: Build the Widget

```bash
cd garmin-ha-widget
chmod +x build.sh
./build.sh
```

The build script will:
- Check for SDK installation
- Generate a developer key if needed
- Compile the widget to `dist/garmin-ha-widget.iq`
- Copy distribution files (README, Privacy Policy, icon) to dist folder

## Step 2a: Test the Widget (Optional)

```bash
./test.sh
```

This runs comprehensive validation and tests to ensure everything works correctly.

## Step 3: Prepare Configuration

1. **Create your JSON config file** based on `example-config.json`
2. **Host it publicly** (GitHub Gist, your web server, etc.)
3. **Note the URL** - you'll need this for setup

Example minimal config:
```json
{
  "sequences": [
    {
      "id": "lights",
      "timeout": 1500,
      "sequence": ["UP", "DOWN", "OK"],
      "action": {
        "entity": "light.living_room",
        "action": "light.toggle"
      }
    }
  ]
}
```

## Step 4: Install on Watch

### Method A: Direct Copy
1. Connect watch to computer via USB
2. Copy `dist/garmin-ha-widget.iq` to `GARMIN/Apps/` folder on watch
3. Safely eject watch

### Method B: Garmin Express
1. Open Garmin Express
2. Go to Connect IQ Apps
3. Add downloaded `.iq` file

## Step 5: Configure Widget

1. Open **Garmin Connect IQ** mobile app
2. Go to **My Device** → **Connect IQ Apps**
3. Find **HA Widget** and tap **Settings**
4. Configure:
   - **Config URL**: Your JSON config file URL
   - **API Key**: Your Home Assistant long-lived access token
   - **HA Server URL**: *(Optional)* Your HA server URL

### Getting Home Assistant API Key

1. In Home Assistant, go to your profile (bottom left)
2. Scroll down to "Long-lived access tokens"
3. Click "Create Token"
4. Name it "Garmin Widget" 
5. Copy the generated token

## Step 6: Test

1. Open the widget on your watch
2. Should show "Ready" status
3. Try a key sequence from your config
4. Check Home Assistant for the triggered action

## Troubleshooting

### Widget shows "Config Error"
- Check your Config URL is accessible
- Verify JSON syntax
- Try "Refresh Config" from menu

### Widget shows "Send Failed"
- Check API Key is correct
- Verify HA Server URL
- Ensure Home Assistant API is accessible
- Check entity IDs exist in your HA

### No response to key presses
- Ensure you're pressing the exact sequence
- Check timeout values aren't too short
- Try "Clear Cache" and "Refresh Config"

## Advanced Configuration

### Custom Timeouts
Each sequence can have its own timeout:
```json
{
  "id": "quick_sequence",
  "timeout": 800,
  "sequence": ["UP", "OK"]
}
```

### Multiple Actions
You can create multiple sequences for different actions:
- Short sequences for frequently used actions
- Longer sequences for important/dangerous actions
- Different timeouts based on urgency

### Security Considerations
- Use HTTPS for your config URL
- Keep your API key secure
- Consider using a dedicated HA user with limited permissions
- Regularly rotate your API tokens

## Updating Configuration

1. Update your hosted JSON file
2. On watch: Menu → "Refresh Config"
3. New sequences will be available immediately

No need to rebuild or reinstall the widget!
