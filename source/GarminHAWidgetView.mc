import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

class GarminHAWidgetView extends WatchUi.View {

    private var _configManager as ConfigManager?;
    private var _keySequenceHandler as KeySequenceHandler?;
    private var _haClient as HomeAssistantClient?;
    private var _statusText as Lang.String;
    private var _sequenceText as Lang.String;
    private var _lastStatusText as Lang.String;
    private var _lastSequenceText as Lang.String;
    private var _needsRedraw as Lang.Boolean;
    private var _isActive as Lang.Boolean;

    function initialize() {
        View.initialize();
        _statusText = "Initializing...";
        _sequenceText = "";
        _lastStatusText = "";
        _lastSequenceText = "";
        _needsRedraw = true;
        _isActive = false;
        
        // Lazy initialization - only create when widget becomes active
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // No layout required for simple widget
    }

    function onShow() as Void {
        _isActive = true;
        initializeComponents();
        _needsRedraw = true;
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        _isActive = false;
        // Clean up timers to save battery
        cleanupTimers();
    }

    function initializeComponents() as Void {
        if (_configManager == null) {
            _configManager = new ConfigManager();
            _keySequenceHandler = new KeySequenceHandler();
            _haClient = new HomeAssistantClient();
            
            // Set up callback for sequence completion
            _keySequenceHandler.setSequenceCallback(method(:onSequenceCompleted));
            
            // Load configuration only when widget becomes active
            _configManager.loadConfig(method(:onConfigLoaded));
        }
    }

    function cleanupTimers() as Void {
        // Override in subclasses if they have timers to clean up
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        // Only redraw if something actually changed
        if (!_needsRedraw && 
            _statusText.equals(_lastStatusText) && 
            _sequenceText.equals(_lastSequenceText)) {
            return;
        }

        // Efficient drawing - clear only what's needed
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw title only once during initialization
        if (_needsRedraw) {
            dc.drawText(width / 2, 20, Graphics.FONT_SMALL, "HA Widget", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw status - only if changed
        if (!_statusText.equals(_lastStatusText)) {
            dc.drawText(width / 2, height / 2 - 10, Graphics.FONT_TINY, _statusText, Graphics.TEXT_JUSTIFY_CENTER);
            _lastStatusText = _statusText;
        }
        
        // Draw current sequence if active - only if changed
        if (!_sequenceText.equals(_lastSequenceText)) {
            if (_sequenceText.length() > 0) {
                dc.drawText(width / 2, height / 2 + 20, Graphics.FONT_XTINY, _sequenceText, Graphics.TEXT_JUSTIFY_CENTER);
            }
            _lastSequenceText = _sequenceText;
        }
        
        _needsRedraw = false;
    }

    function onConfigLoaded(success as Lang.Boolean) as Void {
        if (!_isActive) { return; } // Don't update if widget not visible
        
        if (success) {
            _statusText = "Ready";
            if (_keySequenceHandler != null) {
                _keySequenceHandler.setSequences(_configManager.getSequences());
            }
        } else {
            _statusText = "Config Error";
        }
        requestUpdateIfActive();
    }

    function onSequenceCompleted(sequenceId as Lang.String, action as Lang.Dictionary) as Void {
        if (!_isActive) { return; } // Don't process if widget not visible
        
        _statusText = "Sending...";
        _sequenceText = "";
        requestUpdateIfActive();
        
        if (_haClient != null) {
            _haClient.sendAction(action, method(:onActionResult));
        }
    }

    function onActionResult(success as Lang.Boolean) as Void {
        if (!_isActive) { return; } // Don't update if widget not visible
        
        if (success) {
            _statusText = "Action Sent";
        } else {
            _statusText = "Send Failed";
        }
        requestUpdateIfActive();
        
        // Reset status after 3 seconds (increased from 2 to reduce timer usage)
        var timer = new Timer.Timer();
        timer.start(method(:resetStatus), 3000, false);
    }

    function resetStatus() as Void {
        if (!_isActive) { return; } // Don't update if widget not visible
        
        _statusText = "Ready";
        requestUpdateIfActive();
    }

    function requestUpdateIfActive() as Void {
        if (_isActive) {
            WatchUi.requestUpdate();
        }
    }

    function updateSequenceDisplay(sequence as Lang.Array) as Void {
        if (!_isActive) { return; } // Don't update if widget not visible
        
        var newSequenceText = "";
        for (var i = 0; i < sequence.size(); i++) {
            newSequenceText += sequence[i] as Lang.String;
            if (i < sequence.size() - 1) {
                newSequenceText += "-";
            }
        }
        
        // Only update if sequence actually changed
        if (!newSequenceText.equals(_sequenceText)) {
            _sequenceText = newSequenceText;
            requestUpdateIfActive();
        }
    }

    function refreshConfig() as Void {
        if (!_isActive || _configManager == null) { return; }
        
        _statusText = "Refreshing...";
        requestUpdateIfActive();
        _configManager.refreshConfig(method(:onConfigRefreshed));
    }

    function onConfigRefreshed(success as Lang.Boolean) as Void {
        if (!_isActive) { return; }
        
        if (success) {
            _statusText = "Config Updated";
            if (_keySequenceHandler != null && _configManager != null) {
                _keySequenceHandler.setSequences(_configManager.getSequences());
            }
        } else {
            _statusText = "Refresh Failed";
        }
        requestUpdateIfActive();
        
        // Reset status after 3 seconds
        var timer = new Timer.Timer();
        timer.start(method(:resetStatus), 3000, false);
    }

    function clearCache() as Void {
        if (_configManager == null) { return; }
        
        _configManager.clearCache();
        _statusText = "Cache Cleared";
        if (_keySequenceHandler != null) {
            _keySequenceHandler.setSequences([]);
        }
        requestUpdateIfActive();
        
        // Reset status after 3 seconds
        var timer = new Timer.Timer();
        timer.start(method(:resetStatus), 3000, false);
    }

    function getKeySequenceHandler() as KeySequenceHandler? {
        return _keySequenceHandler;
    }
}

class GarminHAWidgetDelegate extends WatchUi.BehaviorDelegate {
    private var _view as GarminHAWidgetView;

    function initialize(view as GarminHAWidgetView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        var keyString = "";
        
        switch (key) {
            case WatchUi.KEY_UP:
                keyString = "UP";
                break;
            case WatchUi.KEY_DOWN:
                keyString = "DOWN";
                break;
            case WatchUi.KEY_ENTER:
                keyString = "OK";
                break;
            case WatchUi.KEY_ESC:
                // Handle BACK key for exiting widget
                keyString = "BACK";
                // Check if we're in a sequence, if not, exit the widget
                if (_view.getKeySequenceHandler() != null) {
                    var handler = _view.getKeySequenceHandler();
                    if (handler.getCurrentSequence().size() == 0) {
                        // No active sequence, exit widget
                        WatchUi.popView(WatchUi.SLIDE_DOWN);
                        return true;
                    }
                    // Has active sequence, process as normal key
                } else {
                    // No handler, exit widget
                    WatchUi.popView(WatchUi.SLIDE_DOWN);
                    return true;
                }
                break;
            case WatchUi.KEY_LIGHT:
                keyString = "LIGHT";
                break;
            case WatchUi.KEY_MENU:
                keyString = "MENU";
                break;
            default:
                return false;
        }
        
        if (_view.getKeySequenceHandler() != null) {
            var currentSequence = _view.getKeySequenceHandler().handleKeyPress(keyString);
            _view.updateSequenceDisplay(currentSequence);
        }
        
        return true;
    }

    function onMenu() as Lang.Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new GarminHAWidgetMenuDelegate(_view), WatchUi.SLIDE_UP);
        return true;
    }
}

class GarminHAWidgetMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _view as GarminHAWidgetView;

    function initialize(view as GarminHAWidgetView) {
        MenuInputDelegate.initialize();
        _view = view;
    }

    function onMenuItem(item) as Void {
        if (item == :refresh_config) {
            _view.refreshConfig();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (item == :clear_cache) {
            _view.clearCache();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (item == :settings) {
            // Settings are handled by Connect IQ app - just close menu
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }
}