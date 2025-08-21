import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

class ConfigManager {
    private var _sequences as Lang.Array?;
    private var _configUrl as Lang.String?;
    private var _apiKey as Lang.String?;
    private var _haUrl as Lang.String?;
    private var _callback as Lang.Method?;
    private var _cachedConfig as Lang.Dictionary?;
    private var _lastConfigLoad as Lang.Number;

    function initialize() {
        _sequences = [];
        _cachedConfig = null;
        _lastConfigLoad = 0;
        loadSettings();
        loadCachedConfig();
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
            // Try to derive from config URL if available
            deriveHaUrlFromConfig();
        }
    }

    function deriveHaUrlFromConfig() as Void {
        if (_configUrl != null && !_configUrl.equals("") && !_configUrl.equals("https://example.com/ha-config.json")) {
            var protocolEnd = _configUrl.find("://");
            if (protocolEnd != null) {
                var domainStart = protocolEnd + 3;
                var pathStart = _configUrl.find("/");
                // Check if the slash is after the domain part
                if (pathStart != null && pathStart > domainStart) {
                    _haUrl = _configUrl.substring(0, pathStart);
                } else {
                    // No path found after domain, use the whole URL
                    _haUrl = _configUrl;
                }
            }
        }
    }

    function loadCachedConfig() as Void {
        var cachedData = Application.Storage.getValue("cachedConfig");
        var lastLoad = Application.Storage.getValue("lastConfigLoad");
        
        if (cachedData != null && lastLoad != null) {
            _cachedConfig = cachedData as Lang.Dictionary;
            _lastConfigLoad = lastLoad as Lang.Number;
            parseConfig(_cachedConfig);
        }
    }

    function saveCachedConfig(data as Lang.Dictionary) as Void {
        Application.Storage.setValue("cachedConfig", data);
        Application.Storage.setValue("lastConfigLoad", System.getTimer());
        _cachedConfig = data;
        _lastConfigLoad = System.getTimer();
    }

    function loadConfig(callback as Lang.Method) as Void {
        _callback = callback;
        
        if (_configUrl == null || _configUrl.equals("https://example.com/ha-config.json")) {
            // Use cached config if available
            if (_cachedConfig != null) {
                _callback.invoke(true);
                return;
            }
            _callback.invoke(false);
            return;
        }

        // Use cached config if available
        if (_cachedConfig != null) {
            _callback.invoke(true);
            return;
        }

        // No cache available, load fresh
        loadFreshConfig();
    }

    function refreshConfig(callback as Lang.Method) as Void {
        _callback = callback;
        
        if (_configUrl == null || _configUrl.equals("https://example.com/ha-config.json")) {
            _callback.invoke(false);
            return;
        }

        // Always load fresh when refreshing
        loadFreshConfig();
    }

    function loadFreshConfig() as Void {
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

    function onConfigReceived(responseCode as Lang.Number, data as Lang.Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            parseConfig(data);
            saveCachedConfig(data);
            _callback.invoke(true);
        } else {
            // If fresh request failed but we have cached config, use that
            if (_cachedConfig != null) {
                _callback.invoke(true);
            } else {
                _callback.invoke(false);
            }
        }
    }

    function parseConfig(data as Lang.Dictionary) as Void {
        _sequences = [];
        
        if (data.hasKey("sequences")) {
            var sequences = data["sequences"] as Lang.Array;
            for (var i = 0; i < sequences.size(); i++) {
                var seq = sequences[i] as Lang.Dictionary;
                if (seq.hasKey("id") && seq.hasKey("sequence") && seq.hasKey("action")) {
                    var sequence = {
                        "id" => seq["id"],
                        "timeout" => seq.hasKey("timeout") ? seq["timeout"] : 1000,
                        "sequence" => seq["sequence"],
                        "action" => seq["action"]
                    };
                    _sequences.add(sequence);
                }
            }
        }
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

    function hasCache() as Lang.Boolean {
        return _cachedConfig != null;
    }

    function getCacheAge() as Lang.Number {
        if (_lastConfigLoad > 0) {
            return System.getTimer() - _lastConfigLoad;
        }
        return -1;
    }

    function clearCache() as Void {
        Application.Storage.deleteValue("cachedConfig");
        Application.Storage.deleteValue("lastConfigLoad");
        _cachedConfig = null;
        _lastConfigLoad = 0;
        _sequences = [];
    }
}