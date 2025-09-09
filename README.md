# Garmin Home Assistant Widget

Control your smart home from your Garmin watch using button sequences.

## What it does

Press button combinations on your watch to trigger Home Assistant actions. Configure sequences like UP-DOWN-OK to toggle lights or LIGHT-LIGHT to lock doors.

## Setup

1. Build: `./build.sh`
2. Install `bin/garmin-hassequence-widget.iq` on your watch
3. Configure in Connect IQ app:
   - Config URL: Your JSON config file URL
   - API Token: Home Assistant long-lived access token

## Configuration

Host a JSON file with your sequences:

```json
{
  "sequences": [
    {
      "id": "lights",
      "sequence": ["UP", "DOWN", "OK"],
      "action": {
        "entity": "light.living_room",
        "action": "light.toggle"
      }
    }
  ]
}
```

## Usage

Open widget → Press sequences → Actions trigger in Home Assistant

Available buttons: UP, DOWN, OK, BACK, LIGHT, MENU

## Supported Devices

Fenix 5/6/7 series watches

## Development

### Build Scripts

- `./build.sh` - Compile the widget and create `.iq` package
- `./deploy.sh` - Prepare distribution package in `dist/` folder
- `./release.sh [--major|--minor|--patch]` - Create versioned release with git tags

### Build Process

1. **Build**: `./build.sh`
   - Compiles widget using Connect IQ SDK
   - Generates developer key if needed
   - Creates `bin/garmin-hassequence-widget.iq`

2. **Deploy**: `./deploy.sh`
   - Copies IQ package to `dist/` folder
   - Includes documentation and resources
   - Prepares distribution package

3. **Release**: `./release.sh [--major|--minor|--patch]`
   - Creates versioned release branch
   - Updates manifest version
   - Creates git tags and pushes to GitHub
   - Renames package with version number

### Requirements

- Garmin Connect IQ SDK
- OpenSSL (for developer key generation)
- Git (for release management)

### Development Workflow

This project uses Git Flow branching strategy:

- **`develop`** - Default branch for ongoing development
- **`release/x.x.x`** - Release branches created from develop
- **`master`** - Production/stable branch (updated via PR from release branches)

**Release Process:**
1. Develop features on `develop` branch
2. Run `./release.sh --patch` (or --minor/--major) from `develop`
3. Script creates `release/x.x.x` branch and PR to `master`
4. Review and merge PR to `master` (production branch)
5. Upload to Connect IQ Store

```
┌─────────────┐
│   develop   │ ←── feature branches
│ (default)   │
└─────────────┘
       │
       ▼ create release
┌─────────────────┐
│ release/x.x.x   │
│ (from develop)  │
└─────────────────┘
       │
       ▼ PR
┌─────────────┐
│   master    │
│ (production)│
└─────────────┘
```

**Important:** Always run `./release.sh` from the `develop` branch. The script will validate this and exit with helpful error messages if you're on the wrong branch.