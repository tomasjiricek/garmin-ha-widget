import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;

class HomeAssistantClient {
    private var _configManager as ConfigManager;
    private var _callback as Lang.Method?;
    private var _statusCallback as Lang.Method?;
    private var _isRequestInProgress as Lang.Boolean;
    private var _requestQueue as Lang.Array;

    function initialize() {
        _configManager = new ConfigManager();
        _configManager.loadSettings();
        _isRequestInProgress = false;
        _requestQueue = [];
    }

    function sendAction(action as Lang.Dictionary, callback as Lang.Method, statusCallback as Lang.Method?) as Void {
        // Queue the request
        _requestQueue.add({
            "action" => action,
            "callback" => callback,
            "statusCallback" => statusCallback
        });

        if (!_isRequestInProgress) {
            _processNextRequest();
        }
    }

    function _executeAction(action as Lang.Dictionary, callback as Lang.Method, statusCallback as Lang.Method) as Void {
        _callback = callback;
        _statusCallback = statusCallback;
        _isRequestInProgress = true;

        var apiKey = _configManager.getApiKey();
        var haUrl = _configManager.getHaUrl();

        if (haUrl == null) {
            _isRequestInProgress = false;
            if (_callback != null) {
                var callbackMethod = _callback;
                _callback = null;
                _statusCallback = null;
                callbackMethod.invoke(false);
            }
            _processNextRequest();
            return;
        }

        if (apiKey == null) {
            _isRequestInProgress = false;
            if (_callback != null) {
                var callbackMethod = _callback;
                _callback = null;
                _statusCallback = null;
                callbackMethod.invoke(false);
            }
            _processNextRequest();
            return;
        }

        var entity = action["entity"] as Lang.String;
        var actionType = action["action"] as Lang.String;

        // Parse action type (e.g., "script.turn_on" -> domain: "script", service: "turn_on")
        var dotIndex = actionType.find(".");
        if (dotIndex == null) {
            _isRequestInProgress = false;
            if (_callback != null) {
                var callbackMethod = _callback;
                _callback = null;
                _statusCallback = null;
                callbackMethod.invoke(false);
            }
            _processNextRequest();
            return;
        }

        var domain = actionType.substring(0, dotIndex);
        var service = actionType.substring(dotIndex + 1, actionType.length());

        var url = haUrl + "/api/services/" + domain + "/" + service;

        var payload = {
            "entity_id" => entity
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "Authorization" => "Bearer " + apiKey,
                "Connection" => "close", // Close connection quickly to save battery
                "User-Agent" => "GarminHAWidget/1.0" // Identify requests for potential server optimizations
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :timeout => 5 // 5 second timeout for battery optimization
        };

        _statusCallback.invoke("Sending...");
        Communications.makeWebRequest(url, payload, options, method(:onActionResponse));
    }

    function onActionResponse(responseCode as Lang.Number, data as Lang.Dictionary?) as Void {
        var success = (responseCode >= 200 && responseCode < 300);
        _isRequestInProgress = false;

        if (_callback != null) {
            var callbackMethod = _callback;
            _callback = null; // Clear callback before invoking to prevent issues
            _statusCallback = null; // Clear status callback too
            callbackMethod.invoke(success);
        }

        // Process next request in queue if any
        _processNextRequest();
    }

    function _processNextRequest() as Void {
        if (_requestQueue.size() > 0) {
            var nextRequest = _requestQueue[0] as Lang.Dictionary;
            _requestQueue = _requestQueue.slice(1, _requestQueue.size());

            var action = nextRequest["action"] as Lang.Dictionary;
            var callback = nextRequest["callback"] as Lang.Method;
            var statusCallback = nextRequest["statusCallback"] as Lang.Method?;

            _executeAction(action, callback, statusCallback);
        }
    }
}