# Garmin Home Assistant Widget

A **battery-optimized** Garmin Connect IQ widget that allows you to trigger Home Assistant actions using key sequences on your watch.

## 🔋 Battery Optimizations

The widget implements practical battery-saving features:
- **Lazy initialization** - Components load only when needed
- **Smart caching** - Configuration cached until manually cleared
- **Efficient rendering** - Only updates when content changes
- **Activity-aware processing** - No processing when widget hidden
- **Fixed 5-second timeouts** - Prevents indefinite timer drain
- **Network optimization** - Connection management and request queuing

**Expected battery impact: Minimal for typical usage**

## ✨ Features

### Core Functionality
- Load configuration from a remote JSON URL
- Listen for configurable key sequences (UP, DOWN, OK, BACK, LIGHT, MENU)
- Send authenticated actions to Home Assistant
- Configurable key sequences for Home Assistant actions
- Support for multiple sequences

### Smart Power Management
- **Intelligent Configuration Caching**: Automatically caches config locally for offline use
- **Manual Config Refresh**: Force reload configuration from the menu
- **Automatic HA URL Detection**: Derives Home Assistant URL from config URL
- **Offline Capability**: Works with cached config when network unavailable
- **Battery-Aware Networking**: Optimized HTTP headers and connection management

### User Experience
- **Visual Feedback**: Real-time sequence display and status messages
- **Menu Integration**: Easy access to refresh and cache management
- **Error Recovery**: Graceful handling of network failures with fallback to cache
- **Smart Validation**: Built-in configuration validator with battery optimization tips

## 🚀 Quick Start

1. **Build the widget**:
   ```bash
   ./build.sh
   ```

2. **Validate your config** (with battery tips):
   ```bash
   python3 tests/validate-config.py your-config.json --battery-tips
   ```

3. **Test the widget** (optional):
   ```bash
   ./test.sh
   ```

4. **Install on watch**: Copy `dist/garmin-ha-widget.iq` to your watch

5. **Configure in Garmin Connect IQ**:
   - **Config URL**: Your JSON configuration file URL *(required)*
   - **API Key**: Your Home Assistant long-lived access token *(required)*
   - **HA Server URL**: *(optional - auto-derived from config URL)*

## ⚙️ Configuration

### Battery-Optimized Example

```json
{
  "sequences": [
    {
      "id": "lights_toggle",
      "sequence": ["UP", "DOWN", "OK"],
      "action": {
        "entity": "light.living_room",
        "action": "light.toggle"
      }
    },
    {
      "id": "quick_action",
      "sequence": ["OK", "OK"],
      "action": {
        "entity": "switch.fan",
        "action": "switch.toggle"
      }
    }
  ]
}
```

### Battery Optimization Tips

✅ **Keep sequences short** (2-4 keys) - Less processing
✅ **Limit to 6-8 sequences** - Easier to memorize, better performance
✅ **Use reliable, fast servers** - Reduces network timeouts

## 📱 Usage

### Widget Menu (Press MENU button)
- **Clear Cache**: Clear cache and reload fresh configuration from remote URL
- **Settings**: Access Connect IQ configuration

### Smart Behaviors
- **Persistent Caching**: Config cached indefinitely until manually refreshed
- **Offline Mode**: Falls back to cached config if network fails
- **Auto HA URL**: Derives `https://yourdomain.com` from config URL automatically
- **Battery Aware**: Only processes when widget is visible

### Configuration Management
- First load downloads from remote URL
- Subsequent loads use cached version indefinitely
- Manual refresh available via "Clear Cache" menu option
- Cache survives watch restarts

## 🔧 Advanced Configuration

### Emergency Mode (Ultra Battery Saving)
```json
{
  "sequences": [
    {
      "id": "emergency_only",
      "sequence": ["OK"],
      "action": {
        "entity": "script.emergency_lighting",
        "action": "script.turn_on"
      }
    }
  ]
}
```

### Power User Setup
```json
{
  "sequences": [
    {
      "id": "goodnight",
      "sequence": ["MENU", "DOWN", "OK"],
      "action": {
        "entity": "scene.goodnight",
        "action": "scene.turn_on"
      }
    }
  ]
}
```

## 🛠️ Development Tools

- **`build.sh`** - Build the widget package
- **`test.sh`** - Run comprehensive tests and validation
- **`tests/validate-config.py`** - Configuration validator with battery tips
- **`STORE-SUBMISSION.md`** - Connect IQ Store submission guide

## 📊 Battery Performance

| Usage Pattern | Estimated Impact |
|---------------|------------------|
| Idle (widget installed) | Minimal |
| Light usage (1-5 sequences/day) | Low |
| Heavy usage (20+ sequences/day) | Moderate |

*Impact varies by device, network conditions, and usage patterns*

## 🎯 Supported Devices

- Fenix 5 Series (5S Plus, 5X, 5X Plus)
- Fenix 6 Series (6, 6 Pro, 6S, 6S Pro, 6X Pro)
- Fenix 7 Series (7, 7 Pro, 7 Pro No WiFi, 7S, 7S Pro, 7X, 7X Pro, 7X Pro No WiFi)

## 📚 Documentation

- **[Store Submission Guide](STORE-SUBMISSION.md)** - Connect IQ Store process
- **[Deployment Guide](DEPLOYMENT.md)** - Installation and setup instructions

## 🏪 Connect IQ Store Submission

Ready to submit to the Garmin Connect IQ Store:

```bash
# For Connect IQ Store submission
# See STORE-SUBMISSION.md for detailed steps
```

Upload the widget package `dist/garmin-ha-widget.iq` directly to: https://developer.garmin.com/connect-iq/publish/

Use the documentation files in the project root:
- `STORE-DESCRIPTION.md` for store listing
- `PRIVACY-POLICY.md` for privacy policy
- `resources/drawables/launcher_icon.png` for app icon

## 🎉 Ready for Production

This widget is **production-ready** with professional-grade optimizations:
- Robust error handling and recovery
- Efficient caching and network usage
- Comprehensive battery optimizations
- User-friendly operation and feedback

Perfect for controlling your smart home directly from your wrist! 🏠⌚