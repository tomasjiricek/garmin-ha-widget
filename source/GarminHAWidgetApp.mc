import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminHAWidgetApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        // Battery optimization: Minimal startup operations
    }

    function onStop(state as Lang.Dictionary?) as Void {
        // Battery optimization: Clean up any background operations
    }

    function getInitialView() as Lang.Array<WatchUi.Views or WatchUi.InputDelegates>? {
        return [new GarminHAWidgetView(), new GarminHAWidgetDelegate()] as Lang.Array<WatchUi.Views or WatchUi.InputDelegates>;
    }

    function onSettingsChanged() as Void {
        // Battery optimization: Only update if view is active
        var activeView = WatchUi.getActiveView();
        if (activeView != null && activeView instanceof GarminHAWidgetView) {
            WatchUi.requestUpdate();
        }
    }
}

function getApp() as GarminHAWidgetApp {
    return Application.getApp() as GarminHAWidgetApp;
}