import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;


function popView() as Void {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
}

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
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // No layout required for simple widget
    }

    function onShow() as Void {
        _isActive = true;
        _initializeComponentsIfNeeded();
        _needsRedraw = true;
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        _isActive = false;
        // Cleanup any timers or ongoing operations
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
            dc.drawText(width / 2, 20, Graphics.FONT_SMALL, "HASSequence", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Draw status - only if changed
        if (!_statusText.equals(_lastStatusText)) {
            // Handle multi-line status messages
            var statusLines = [];
            var currentLine = "";
            var newlineIndex = _statusText.find("\n");
            
            if (newlineIndex != null) {
                // Has newlines, split manually
                var remaining = _statusText;
                while (remaining.length() > 0) {
                    newlineIndex = remaining.find("\n");
                    if (newlineIndex != null) {
                        currentLine = remaining.substring(0, newlineIndex);
                        remaining = remaining.substring(newlineIndex + 1, remaining.length());
                    } else {
                        currentLine = remaining;
                        remaining = "";
                    }
                    statusLines.add(currentLine);
                }
            } else {
                // No newlines, just one line
                statusLines.add(_statusText);
            }
            
            var lineHeight = 20; // Approximate line height for FONT_TINY
            var startY = height / 2 - 10 - ((statusLines.size() - 1) * lineHeight / 2);
            
            for (var i = 0; i < statusLines.size(); i++) {
                dc.drawText(width / 2, startY + (i * lineHeight), Graphics.FONT_TINY, statusLines[i], Graphics.TEXT_JUSTIFY_CENTER);
            }
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

    function onStatusUpdate(status as Lang.String) as Void {
        _requestUpdateIfActive(status, "");
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
            _requestUpdateIfActive(_statusText, newSequenceText);
        }
    }

    function clearCache() as Void {
        var reloadTimer = new Timer.Timer();
        reloadTimer.start(method(:_clearCacheAndReloadConfig), 500, false);
    }

    function getKeySequenceHandler() as KeySequenceHandler? {
        return _keySequenceHandler;
    }

    private function _resetStatus() as Void {
        _requestUpdateIfActive("Ready", "");
    }

    private function _initializeComponentsIfNeeded() as Void {
        if (_configManager == null) {
            _configManager = new ConfigManager();
            _keySequenceHandler = new KeySequenceHandler();
            _haClient = new HomeAssistantClient();

            // Set up callback for sequence completion
            _keySequenceHandler.setSequenceCallback(method(:_onSequenceCompleted));

            // Load configuration only when widget becomes active
            _configManager.loadConfig(method(:_onConfigLoaded));
        }
    }

    private function _onConfigLoaded(success as Lang.Boolean) as Void {
        if (!_isActive) { return; } // Don't update if widget not visible

        if (success) {
            _statusText = "Ready";
            if (_keySequenceHandler != null) {
                _keySequenceHandler.setSequences(_configManager.getSequences());
            }
        } else {
            _statusText = "Error:\nConfig empty or invalid";
        }
        _requestUpdateIfActive(_statusText, "");
    }

    private function _onSequenceCompleted(sequenceId as Lang.String, action as Lang.Dictionary) as Void {
        if (!_isActive) { return; } // Don't process if widget not visible

        if (_haClient != null) {
            _haClient.sendAction(action, method(:_onActionResult), method(:onStatusUpdate));
        }
    }

    private function _onActionResult(success as Lang.Boolean) as Void {
        if (!_isActive) { return; } // Don't update if widget not visible

        if (success) {
           _requestUpdateIfActive("Action sent", "");
        } else {
            _requestUpdateIfActive("Error\nSending action\nfailed", "");
        }

        var timer = new Timer.Timer();
        timer.start(method(:_resetStatus), 3000, false);
    }

    private function _requestUpdateIfActive(status as Lang.String, sequence as Lang.String) as Void {
        if (_isActive) {
            _statusText = status;
            _sequenceText = sequence;
            WatchUi.requestUpdate();
        }
    }

    private function _clearCacheAndReloadConfig() as Void {
        if (_configManager == null) {
            // Initialize config manager
            _initializeComponentsIfNeeded();
        }

        if (_configManager == null) {
            _requestUpdateIfActive("Error:\nManager not ready", "");
            return;
        }

        _configManager.clearCache();
        if (_keySequenceHandler != null) {
            _keySequenceHandler.initialize(); // Reset
        }

        _configManager.loadConfig(method(:_onConfigLoaded));
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
                        popView();
                        return true;
                    }
                } else {
                    popView();
                    return true;
                }
                break;
            // These only work in InputDelegate, not BehaviorDelegate
            // case WatchUi.KEY_LIGHT:
            //     keyString = "LIGHT";
            //     break;
            // case WatchUi.KEY_MENU:
            //     keyString = "MENU";
            //     break;
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
        WatchUi.pushView(new Rez.Menus.MainMenu(), new GarminHAWidgetMenuDelegate(_view),  WatchUi.SLIDE_RIGHT);
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
        if (item == :clear_cache) {
            popView();
            _view.clearCache();
            return;
        }
    }
}
