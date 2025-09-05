import Toybox.Lang;

// Base interface for communication providers
class CommunicationProvider {

    function initialize() {
        // Base initialization
    }

    // Method to send an action to Home Assistant
    // action: Dictionary containing entity and action type
    // haUrl: String - Home Assistant URL
    // apiKey: String - API key for authentication
    // statusCallback: Method to call with status updates
    // responseCallback: Method to call when request completes (receives success boolean)
    function sendAction(action as Lang.Dictionary, haUrl as Lang.String, apiKey as Lang.String, statusCallback as Lang.Method, responseCallback as Lang.Method) as Void {
        // Override in subclasses
        throw new Lang.InvalidValueException("sendAction must be implemented by subclass");
    }

    // Get the name/type of this communication provider
    function getProviderType() as Lang.String {
        return "base";
    }
}
