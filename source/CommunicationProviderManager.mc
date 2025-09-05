import Toybox.Lang;
import Toybox.Application;

// Utility class for managing communication provider configuration
class CommunicationProviderManager {

    // Get the configured communication provider - implement logic to choose provider once multiple providers are available
    public static function getConfiguredProvider() as CommunicationProvider {
        return new HttpCommunicationProvider();
    }

    // Configure a HomeAssistantClient with the HTTP provider
    public static function configureClient(client as HomeAssistantClient) as Void {
        var provider = getConfiguredProvider();
        client.setCommunicationProvider(provider);
    }
}
