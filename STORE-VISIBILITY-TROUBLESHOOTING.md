# 🔍 Finding Your Published Test Widget in Connect IQ Store

## Issue: Widget Published for Testing but Not Visible

Your widget is published for testing but you can't find it in the Connect IQ Store. Here are the steps to locate it:

### 1. **Check Your Developer Account**
- Go to: https://developer.garmin.com/connect-iq/publish/
- Log in with your developer account
- Look for your "Home Assistant Widget" in the app list
- Check its status (should show "In Testing" or similar)

### 2. **Access Test Version Through Direct Link**
When apps are in testing, they often have a specific test URL:
- In your developer dashboard, look for a "Test" or "Preview" link
- This gives you a direct link to share with testers
- The app might not appear in general store browsing during testing

### 3. **Check Device-Specific Store**
- Open **Garmin Connect IQ app** on your phone
- Go to **My Device** → **Connect IQ Apps**
- Search for "Home Assistant" or "HA Widget"
- Make sure your phone is connected to your Fenix 6X Solar

### 4. **Verify App Store Settings**
In your developer dashboard, check:
- **Visibility**: Set to "Public" for testing
- **Device Compatibility**: Ensure Fenix 6X is listed
- **App Status**: Should be "Published for Testing" or "Beta"

### 5. **Common Testing Phase Issues**

#### App Not Visible During Beta
- Beta/test apps often don't appear in general store search
- They require direct links or specific access
- Check your developer dashboard for a "Share Test Link"

#### Device Compatibility Display
- Your Fenix 6X Solar should be covered by `fenix6xpro` device ID
- Store might show it as "fēnix® 6X Pro / 6X Sapphire / 6X Pro Solar"
- If you don't see this exact device listed, the store might be filtering it out

### 6. **Troubleshooting Steps**

1. **Check App Store URL**:
   - Get the direct app link from your developer dashboard
   - Try opening it directly on your phone

2. **Verify Store Cache**:
   - Close and reopen Garmin Connect IQ app
   - Sometimes store listings take time to propagate

3. **Test with Different Search Terms**:
   - Search for "Home Assistant"
   - Search for "HA Widget" 
   - Browse by category: "Productivity"

4. **Check Regional Availability**:
   - Some test apps have regional restrictions
   - Verify in your developer settings

### 7. **Direct Installation Method**
If you still can't find it in the store:

1. **Get the direct .iq file** from your developer dashboard
2. **Install via Garmin Express**:
   - Connect your Fenix 6X Solar to computer
   - Open Garmin Express
   - Go to Connect IQ Apps
   - Install from file: `garmin-ha-widget.iq`

### 8. **Contact Developer Support**
If none of the above work:
- Submit a support ticket to Garmin Developer Support
- Include your app ID: `e434efa2b3cd447ca404ca32f2e787ca`
- Mention it's published for testing but not visible

## Current Widget Details for Reference:
- **App Name**: HA Widget (from strings.xml)
- **App ID**: e434efa2b3cd447ca404ca32f2e787ca
- **Type**: Widget
- **Category**: Productivity
- **Devices**: Fenix 6/7, Vivoactive 4 series
- **Your Device**: Fenix 6X Solar (covered by fenix6xpro)

The most likely issue is that test/beta apps require direct access and don't appear in general store browsing.
