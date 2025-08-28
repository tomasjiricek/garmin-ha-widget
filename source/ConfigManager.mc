import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

class ConfigManager {
    private var _sequences as Lang.Array?;
    private var _configUrl as Lang.String?;
    private var _apiKey as Lang.String?;
    private var _haUrl as Lang.String?;
    private var _callbackOnConfigProcessed as Lang.Method?;
    private var _cachedConfig as Lang.Dictionary?;
    private var _lastConfigLoad as Lang.Number;
    private var _isLoadingConfig as Lang.Boolean;

    function initialize() {
        _sequences = [];
        _cachedConfig = null;
        _lastConfigLoad = 0;
        _isLoadingConfig = false;
        loadSettings();
    }

    function loadSettings() as Void {
        _configUrl = Application.Properties.getValue("ConfigUrl") as Lang.String;
        _apiKey = Application.Properties.getValue("ApiKey") as Lang.String;
        _haUrl = Application.Properties.getValue("HaUrl") as Lang.String;

        // Validate settings - ensure they're not empty or default values
        if (_configUrl == null || _configUrl.equals("") || _configUrl.equals("https://example.com/ha-config.json")) {
            _configUrl = null;
        }

        if (_apiKey == null || _apiKey.equals("") || _apiKey.equals("your_ha_api_key_here")) {
            _apiKey = null;
        }

        if (_haUrl == null || _haUrl.equals("") || _haUrl.equals("https://your-ha-instance.com")) {
            _haUrl = null;
            deriveHaUrlFromConfig();
        }
    }

    function deriveHaUrlFromConfig() as Void {
        if (_configUrl != null) {
            var protocolEnd = _configUrl.find("://");
            if (protocolEnd != null) {
                var domainStart = protocolEnd + 3;
                var domainPart = _configUrl.substring(domainStart, _configUrl.length());
                var pathStart = domainPart.find("/");

                if (pathStart != null) {
                    _haUrl = _configUrl.substring(0, domainStart + pathStart);
                } else {
                    // No path, use entire URL as base
                    _haUrl = _configUrl;
                }
            }
        }
    }

    private function loadCachedConfig() as Lang.Boolean {
        var cachedData = Application.Storage.getValue("cachedConfig");
        var lastLoad = Application.Storage.getValue("lastConfigLoad");

        if (cachedData != null && lastLoad != null) {
            _cachedConfig = cachedData as Lang.Dictionary;
            _lastConfigLoad = lastLoad as Lang.Number;
            return parseConfig(_cachedConfig);
        }

        return false;
    }

    private function saveCachedConfig(data as Lang.Dictionary) as Void {
        Application.Storage.setValue("cachedConfig", data);
        Application.Storage.setValue("lastConfigLoad", System.getTimer());
        _cachedConfig = data;
        _lastConfigLoad = System.getTimer();
    }

    private function requestConfig(callback as Lang.Method) as Void {
        // Prevent multiple concurrent config loads
        if (_isLoadingConfig) {
            return;
        }

        _isLoadingConfig = true;
        // Always load fresh config from server
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "Cache-Control" => "no-cache",
                "Connection" => "close" // Close connection quickly to save battery
            }
        };

        Communications.makeWebRequest(_configUrl, null, options, method(:onConfigReceived));
    }

    function loadConfig(callback as Lang.Method) as Void {
        _callbackOnConfigProcessed = callback;

        if (loadCachedConfig()) {
            _callbackOnConfigProcessed.invoke(true);
            return;
        }

        // No cached config, or the config is invalid. Clear the cache to be sure it's not used
        clearCache();

        if (_configUrl == null) {
            _callbackOnConfigProcessed.invoke(false);
            return;
        }

        requestConfig(_callbackOnConfigProcessed);
    }

    function onConfigReceived(responseCode as Lang.Number, data as Lang.Dictionary?) as Void {
        _isLoadingConfig = false;
        var success = false;

        if (responseCode == 200 && data != null) {
            var isValid = parseConfig(data);
            if (isValid) {
                saveCachedConfig(data);
            }
            success = isValid;
        } else {
            // If fresh request failed but we have cached config, use that
            if (_cachedConfig != null) {
                success = true;
            }
        }

        if (_callbackOnConfigProcessed != null) {
            _callbackOnConfigProcessed.invoke(success);
        }
    }

    private function initialConfigProcessed(success as Lang.Boolean) as Void {
        if (success) {
            // Handle successful config load
        } else {
            // Handle failed config load
        }
    }

    private function parseConfig(data as Lang.Dictionary) as Lang.Boolean {
        _sequences = [];
        try {
            var sequences = data["sequences"] as Lang.Array;
            for (var i = 0; i < sequences.size(); i++) {
                var seq = sequences[i] as Lang.Dictionary;
                if (seq.hasKey("id") && seq.hasKey("sequence") && seq.hasKey("action")) {
                    var sequence = {
                        "id" => seq["id"],
                        "sequence" => seq["sequence"],
                        "action" => seq["action"]
                    };
                    _sequences.add(sequence);
                }
            }
        } catch (ex) {
            return false;
        }

        return _sequences.size() > 0;
    }

    function getSequences() as Lang.Array {
        return _sequences != null ? _sequences : [];
    }

    function getApiKey() as Lang.String? {
        return _apiKey;
    }

    function getHaUrl() as Lang.String? {
        return _haUrl;
    }

    function getConfigUrl() as Lang.String? {
        return _configUrl;
    }

    function getCacheAge() as Lang.Number {
        if (_lastConfigLoad > 0) {
            return System.getTimer() - _lastConfigLoad;
        }
        return -1;
    }

    function clearCache() as Void {
        try {
            Application.Storage.deleteValue("cachedConfig");
            Application.Storage.deleteValue("lastConfigLoad");
        } catch (ex) {
            // No-op
        }

        initialize(); // Reload settings
    }
}