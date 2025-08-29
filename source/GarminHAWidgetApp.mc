import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminHAWidgetApp extends Application.AppBase {
    private var _configManager as ConfigManager?;

    function initialize() {
        AppBase.initialize();

        // Initialize ConfigManager at app level to make settings accessible
        // in Connect IQ mobile app before widget is opened
        _configManager = new ConfigManager();
        _configManager.loadSettings();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        // Battery optimization: Minimal startup operations
    }

    function onStop(state as Lang.Dictionary?) as Void {
        // Battery optimization: Clean up any background operations
    }

    function getInitialView() {
        var view = new GarminHAWidgetView();
        return [view, new GarminHAWidgetDelegate(view)];
    }

    function onSettingsChanged() as Void {
        // Request update when settings change
        WatchUi.requestUpdate();
    }

    function getConfigManager() as ConfigManager? {
        return _configManager;
    }
}

function getApp() as GarminHAWidgetApp {
    return Application.getApp() as GarminHAWidgetApp;
}