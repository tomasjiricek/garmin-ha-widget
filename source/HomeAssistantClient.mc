import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;

class HomeAssistantClient {
    private var _configManager as ConfigManager;
    private var _callback as Lang.Method?;
    private var _isRequestInProgress as Lang.Boolean;
    private var _requestQueue as Lang.Array;

    function initialize() {
        _configManager = new ConfigManager();
        _configManager.loadSettings();
        _isRequestInProgress = false;
        _requestQueue = [];
    }

    function sendAction(action as Lang.Dictionary, callback as Lang.Method) as Void {
        // Queue the request if another is in progress
        if (_isRequestInProgress) {
            _requestQueue.add({
                "action" => action,
                "callback" => callback
            });
            return;
        }
        
        _executeAction(action, callback);
    }

    function _executeAction(action as Lang.Dictionary, callback as Lang.Method) as Void {
        _callback = callback;
        _isRequestInProgress = true;
        
        var apiKey = _configManager.getApiKey();
        var haUrl = _configManager.getHaUrl();
        
        // If no HA URL configured, try to derive from config URL
        if (haUrl == null || haUrl.equals("https://your-ha-instance.com")) {
            var configUrl = _configManager.getConfigUrl();
            if (configUrl != null && !configUrl.equals("https://example.com/ha-config.json")) {
                haUrl = deriveHaUrlFromConfigUrl(configUrl);
            }
        }
        
        if (apiKey == null || haUrl == null || 
            apiKey.equals("your_ha_api_key_here") || 
            haUrl.equals("https://your-ha-instance.com")) {
            _isRequestInProgress = false;
            _callback.invoke(false);
            _processNextRequest();
            return;
        }

        var entity = action["entity"] as Lang.String;
        var actionType = action["action"] as Lang.String;
        
        // Parse action type (e.g., "script.turn_on" -> domain: "script", service: "turn_on")
        var dotIndex = actionType.find(".");
        if (dotIndex == null) {
            _isRequestInProgress = false;
            _callback.invoke(false);
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
            }
        };

        // Battery optimization: Use shorter timeout for quicker failures
        Communications.makeWebRequest(url, payload, options, method(:onActionResponse));
    }

    function onActionResponse(responseCode as Lang.Number, data as Lang.Dictionary?) as Void {
        var success = (responseCode >= 200 && responseCode < 300);
        _isRequestInProgress = false;
        
        if (_callback != null) {
            _callback.invoke(success);
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
            
            _executeAction(action, callback);
        }
    }

    function deriveHaUrlFromConfigUrl(configUrl as Lang.String) as Lang.String? {
        var protocolEnd = configUrl.find("://");
        if (protocolEnd != null) {
            var domainStart = protocolEnd + 3;
            var pathStart = configUrl.find("/");
            if (pathStart != null && pathStart > domainStart) {
                return configUrl.substring(0, pathStart);
            } else {
                // No path, use entire URL as base
                return configUrl;
            }
        }
        return null;
    }
}