import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;

class KeySequenceHandler {
    private var _sequences as Lang.Array;
    private var _currentSequence as Lang.Array;
    private var _currentSequenceIndex as Lang.Number;
    private var _activeSequenceConfig as Lang.Dictionary?;
    private var _sequenceCallback as Lang.Method?;
    private var _timeoutTimer as Timer.Timer?;

    function initialize() {
        _sequences = [];
        _currentSequence = [];
        _currentSequenceIndex = 0;
        _activeSequenceConfig = null;
    }

    function setSequences(sequences as Lang.Array) as Void {
        _sequences = sequences;
    }

    function setSequenceCallback(callback as Lang.Method) as Void {
        _sequenceCallback = callback;
    }

    function handleKeyPress(key as Lang.String) as Lang.Array {
        // If no active sequence, check if this key starts any sequence
        if (_activeSequenceConfig == null) {
            for (var i = 0; i < _sequences.size(); i++) {
                var seq = _sequences[i] as Lang.Dictionary;
                var sequence = seq["sequence"] as Lang.Array;
                if (sequence.size() > 0 && sequence[0].equals(key)) {
                    _activeSequenceConfig = seq;
                    _currentSequence = [key];
                    _currentSequenceIndex = 1;
                    scheduleSequenceTimeout();
                    return _currentSequence;
                }
            }
        } else {
            // Continue with active sequence
            var targetSequence = _activeSequenceConfig["sequence"] as Lang.Array;

            if (_currentSequenceIndex < targetSequence.size() &&
                targetSequence[_currentSequenceIndex].equals(key)) {
                // Correct key in sequence
                _currentSequence.add(key);
                _currentSequenceIndex++;

                // Check if sequence is complete
                if (_currentSequenceIndex >= targetSequence.size()) {
                    var sequenceId = _activeSequenceConfig["id"] as Lang.String;
                    var action = _activeSequenceConfig["action"] as Lang.Dictionary;

                    resetSequence();

                    if (_sequenceCallback != null) {
                        _sequenceCallback.invoke(sequenceId, action);
                    }

                    return [];
                } else {
                    scheduleSequenceTimeout();
                    return _currentSequence;
                }
            } else {
                // Wrong key, reset and check if this key starts a new sequence
                resetSequence();
                return handleKeyPress(key);
            }
        }

        return [];
    }

    function resetSequence() as Void {
        _activeSequenceConfig = null;
        _currentSequence = [];
        _currentSequenceIndex = 0;

        // Battery optimization: Stop timer immediately when sequence resets
        if (_timeoutTimer != null) {
            _timeoutTimer.stop();
            _timeoutTimer = null;
        }
    }

    function getCurrentSequence() as Lang.Array {
        return _currentSequence;
    }

    function scheduleSequenceTimeout() as Void {
        if (_timeoutTimer != null) {
            _timeoutTimer.stop();
            _timeoutTimer = null;
        }

        if (_activeSequenceConfig != null) {
            _timeoutTimer = new Timer.Timer();
            _timeoutTimer.start(method(:resetSequence), 5000, false);
        }
    }
}