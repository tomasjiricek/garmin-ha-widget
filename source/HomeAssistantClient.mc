import Toybox.Lang;
import Toybox.Application;

class HomeAssistantClient {
    private var _configManager as ConfigManager;
    private var _callback as Lang.Method?;
    private var _statusCallback as Lang.Method?;
    private var _isRequestInProgress as Lang.Boolean;
    private var _requestQueue as Lang.Array;
    private var _communicationProvider as CommunicationProvider;

    function initialize() {
        _configManager = new ConfigManager();
        _configManager.loadSettings();
        _isRequestInProgress = false;
        _requestQueue = [];

        // Use CommunicationProviderManager to get the configured provider
        _communicationProvider = CommunicationProviderManager.getConfiguredProvider();
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

    // Method to switch communication provider at runtime
    function setCommunicationProvider(provider as CommunicationProvider) as Void {
        _communicationProvider = provider;
    }

    // Get current communication provider type
    function getCommunicationProviderType() as Lang.String {
        return _communicationProvider.getProviderType();
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

        // Use the communication provider to send the action
        _communicationProvider.sendAction(action, haUrl, apiKey, _statusCallback, method(:onActionResponse));
    }

    function onActionResponse(success as Lang.Boolean) as Void {
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