import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;

class KeySequenceHandler {
    private var _sequences as Lang.Array;
    private var _currentSequence as Lang.Array;
    private var _candidateSequences as Lang.Array; // All sequences that start with initial key
    private var _activeSequence as Lang.Dictionary?;
    private var _sequenceCallback as Lang.Method?;
    private var _timeoutTimer as Timer.Timer?;

    function initialize() {
        _sequences = [];
        _currentSequence = [];
        _candidateSequences = [];
        _activeSequence = null;
    }

    function setSequences(sequences as Lang.Array) as Void {
        _sequences = sequences;
    }

    function setSequenceCallback(callback as Lang.Method) as Void {
        _sequenceCallback = callback;
    }

    function handleKeyPress(key as Lang.String) as Lang.Array {
        if (_activeSequence == null) {
            return startNewSequence(key);
        } else {
            // Continue existing sequence
            var targetSequence = _activeSequence["sequence"] as Lang.Array;

            if (_currentSequence.size() < targetSequence.size() &&
                targetSequence[_currentSequence.size()].equals(key)) {

                // Correct key - continue with current sequence
                return continueSequence(key);
            } else {
                // Wrong key - check if any other candidate sequences match
                var alternativeSequence = findMatchingCandidate(key);

                if (alternativeSequence != null) {
                    // Switch to the alternative sequence
                    _activeSequence = alternativeSequence;
                    _currentSequence.add(key);

                    // Check if the alternative sequence is now complete
                    if (_currentSequence.size() >= _activeSequence["sequence"].size()) {
                        completeSequence();
                        return [];
                    } else {
                        scheduleSequenceTimeout();
                        return _currentSequence;
                    }
                } else {
                    // No alternatives match - reset and start new sequence
                    resetSequence();
                    return startNewSequence(key);
                }
            }
        }
    }

    private function startNewSequence(key as Lang.String) as Lang.Array {
        // Start new sequence - find all sequences that start with this key
        _candidateSequences = [];

        for (var i = 0; i < _sequences.size(); i++) {
            var seq = _sequences[i] as Lang.Dictionary;
            var sequence = seq["sequence"] as Lang.Array;
            if (sequence.size() > 0 && sequence[0].equals(key)) {
                _candidateSequences.add(seq);
            }
        }

        if (_candidateSequences.size() > 0) {
            // Pick the shortest candidate as active
            _activeSequence = findShortestCandidate();
            _currentSequence = [key];
            scheduleSequenceTimeout();
            return _currentSequence;
        }

        return [];
    }

    private function continueSequence(key as Lang.String) as Lang.Array {
        _currentSequence.add(key);

        // Check if sequence is complete
        if (_currentSequence.size() >= _activeSequence["sequence"].size()) {
            completeSequence();
            return [];
        } else {
            scheduleSequenceTimeout();
            return _currentSequence;
        }
    }

    private function completeSequence() as Void {
        var sequenceId = _activeSequence["id"] as Lang.String;
        var action = _activeSequence["action"] as Lang.Dictionary;

        resetSequence();

        if (_sequenceCallback != null) {
            _sequenceCallback.invoke(sequenceId, action);
        }
    }

    private function findShortestCandidate() as Lang.Dictionary? {
        if (_candidateSequences.size() == 0) {
            return null;
        }

        var shortest = _candidateSequences[0] as Lang.Dictionary;
        var shortestLength = shortest["sequence"].size();

        for (var i = 1; i < _candidateSequences.size(); i++) {
            var candidate = _candidateSequences[i] as Lang.Dictionary;
            var candidateLength = candidate["sequence"].size();

            if (candidateLength < shortestLength) {
                shortest = candidate;
                shortestLength = candidateLength;
            }
        }

        return shortest;
    }

    private function findMatchingCandidate(key as Lang.String) as Lang.Dictionary? {
        for (var i = 0; i < _candidateSequences.size(); i++) {
            var candidate = _candidateSequences[i] as Lang.Dictionary;
            var sequence = candidate["sequence"] as Lang.Array;

            // Skip the currently active sequence
            if (candidate == _activeSequence) {
                continue;
            }

            // Check if this candidate matches at the current position
            if (_currentSequence.size() < sequence.size() &&
                sequence[_currentSequence.size()].equals(key)) {
                return candidate;
            }
        }

        return null;
    }

    function resetSequence() as Void {
        _activeSequence = null;
        _currentSequence = [];
        _candidateSequences = [];

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

        if (_activeSequence != null) {
            _timeoutTimer = new Timer.Timer();
            _timeoutTimer.start(method(:resetSequence), 5000, false);
        }
    }
}