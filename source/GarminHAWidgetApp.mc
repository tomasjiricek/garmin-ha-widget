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

    function getInitialView() {
        var view = new GarminHAWidgetView();
        return [view, new GarminHAWidgetDelegate(view)];
    }

    function onSettingsChanged() as Void {
        // Request update when settings change
        WatchUi.requestUpdate();
    }
}

function getApp() as GarminHAWidgetApp {
    return Application.getApp() as GarminHAWidgetApp;
}