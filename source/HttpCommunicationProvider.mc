import Toybox.Communications;
import Toybox.Lang;

// HTTP implementation of communication provider
class HttpCommunicationProvider extends CommunicationProvider {
    private var _responseCallback as Lang.Method?;

    function initialize() {
        CommunicationProvider.initialize();
        _responseCallback = null;
    }

    function sendAction(action as Lang.Dictionary, haUrl as Lang.String, apiKey as Lang.String, statusCallback as Lang.Method, responseCallback as Lang.Method) as Void {
        _responseCallback = responseCallback;

        var entity = action["entity"] as Lang.String;
        var actionType = action["action"] as Lang.String;

        // Parse action type (e.g., "script.turn_on" -> domain: "script", service: "turn_on")
        var dotIndex = actionType.find(".");
        if (dotIndex == null) {
            if (_responseCallback != null) {
                var callback = _responseCallback;
                _responseCallback = null;
                callback.invoke(false);
            }
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

        statusCallback.invoke("Sending...");
        Communications.makeWebRequest(url, payload, options, method(:onResponse));
    }

    function onResponse(responseCode as Lang.Number, data as Lang.Dictionary?) as Void {
        var success = (responseCode >= 200 && responseCode < 300);

        if (_responseCallback != null) {
            var callback = _responseCallback;
            _responseCallback = null;
            callback.invoke(success);
        }
    }

    function getProviderType() as Lang.String {
        return "http";
    }
}
