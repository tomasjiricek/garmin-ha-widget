# Privacy Policy - Home Assistant Widget

**Last Updated**: August 21, 2025

## Data Collection and Usage

### What We Collect
The Home Assistant Widget does **NOT** collect, store, or transmit any personal data to third parties.

### Local Data Storage
The widget stores the following data locally on your Garmin device:
- **Configuration URL**: The URL you provide to load sequence definitions
- **API Token**: Your Home Assistant long-lived access token
- **Home Assistant Server URL**: Your HA server endpoint
- **Cached Configuration**: Temporarily cached sequence definitions (expires after 1 hour)

### Network Communication
The widget makes network requests only to:
- **Your specified configuration URL**: To download sequence definitions
- **Your Home Assistant server**: To execute configured actions

### Data Security
- All sensitive data (API tokens) is stored securely on your device using Garmin's Application.Storage
- Network communications use HTTPS when available
- No data is transmitted to our servers or any third-party analytics services
- Configuration cache is automatically cleared after 1 hour

### Third-Party Services
This widget communicates with:
- **Your Configuration Server**: To load sequence definitions from your provided URL
- **Your Home Assistant Instance**: To execute smart home actions using your provided token

We have no control over and assume no responsibility for the content, privacy policies, or practices of these services.

### Data Retention
- Configuration data persists until you uninstall the widget or clear settings
- Cached data automatically expires after 1 hour
- No data is retained by us - everything stays on your device

### Changes to Privacy Policy
We may update this privacy policy from time to time. Continued use of the widget after changes constitutes acceptance of the new policy.

### Contact
For questions about this privacy policy, please contact us through our GitHub repository.

## Summary
**Your privacy is paramount. This widget operates entirely on your device and communicates only with services you explicitly configure. We collect no data about you or your usage.**
