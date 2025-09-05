#!/usr/bin/env python3
"""
Garmin HASSequence Configuration Validator

This script validates your JSON configuration file for syntax and structure.
Usage: python3 validate-config.py <config-file.json>
"""

import json
import sys
import argparse
from typing import Dict, List, Any

def validate_sequence(seq: Dict[str, Any], index: int) -> List[str]:
    """Validate a single sequence configuration."""
    errors = []
    warnings = []

    # Check required fields
    required_fields = ['id', 'sequence', 'action']
    for field in required_fields:
        if field not in seq:
            errors.append(f"Sequence {index}: Missing required field '{field}'")

    # Validate ID
    if 'id' in seq:
        if not isinstance(seq['id'], str) or not seq['id'].strip():
            errors.append(f"Sequence {index}: 'id' must be a non-empty string")

    # Validate timeout with battery optimization recommendations
    if 'timeout' in seq:
        if not isinstance(seq['timeout'], int) or seq['timeout'] < 100:
            errors.append(f"Sequence {index}: 'timeout' must be an integer >= 100ms")
        elif seq['timeout'] < 1000:
            warnings.append(f"Sequence {index}: Timeout {seq['timeout']}ms is quite short. Consider >= 1500ms for better battery life")
        elif seq['timeout'] > 10000:
            warnings.append(f"Sequence {index}: Timeout {seq['timeout']}ms is very long. Users might find it frustrating")
    else:
        warnings.append(f"Sequence {index}: No timeout specified, will use default 1000ms. Consider explicit timeout >= 1500ms for battery optimization")

    # Validate sequence array with battery considerations
    if 'sequence' in seq:
        if not isinstance(seq['sequence'], list) or len(seq['sequence']) == 0:
            errors.append(f"Sequence {index}: 'sequence' must be a non-empty array")
        else:
            valid_keys = ['UP', 'DOWN', 'OK', 'BACK', 'LIGHT', 'MENU']
            for i, key in enumerate(seq['sequence']):
                if key not in valid_keys:
                    errors.append(f"Sequence {index}: Invalid key '{key}' at position {i}. Valid keys: {valid_keys}")

            # Battery optimization recommendations
            seq_length = len(seq['sequence'])
            if seq_length > 5:
                warnings.append(f"Sequence {index}: {seq_length} keys is quite long. Shorter sequences (2-4 keys) are more battery efficient")
            elif seq_length <= 2:
                # This is good for battery
                pass

    # Validate action
    if 'action' in seq:
        action = seq['action']
        if not isinstance(action, dict):
            errors.append(f"Sequence {index}: 'action' must be an object")
        else:
            if 'entity' not in action:
                errors.append(f"Sequence {index}: action missing 'entity' field")
            if 'action' not in action:
                errors.append(f"Sequence {index}: action missing 'action' field")

            # Validate action format (domain.service)
            if 'action' in action:
                action_str = action['action']
                if not isinstance(action_str, str) or '.' not in action_str:
                    errors.append(f"Sequence {index}: action 'action' must be in format 'domain.service'")
                else:
                    parts = action_str.split('.')
                    if len(parts) != 2:
                        errors.append(f"Sequence {index}: action 'action' must be in format 'domain.service'")

    return errors, warnings

def validate_config(config: Dict[str, Any]) -> tuple[List[str], List[str]]:
    """Validate the entire configuration."""
    errors = []
    warnings = []

    # Check for sequences array
    if 'sequences' not in config:
        errors.append("Configuration missing 'sequences' array")
        return errors, warnings

    sequences = config['sequences']
    if not isinstance(sequences, list):
        errors.append("'sequences' must be an array")
        return errors, warnings

    if len(sequences) == 0:
        errors.append("'sequences' array cannot be empty")
        return errors, warnings

    # Battery optimization: Warn about too many sequences
    if len(sequences) > 10:
        warnings.append(f"You have {len(sequences)} sequences. Consider reducing to 6-8 for better battery life and easier memorization")

    # Validate each sequence
    sequence_ids = set()
    total_warnings = []
    for i, seq in enumerate(sequences):
        seq_errors, seq_warnings = validate_sequence(seq, i)
        errors.extend(seq_errors)
        total_warnings.extend(seq_warnings)

        # Check for duplicate IDs
        if 'id' in seq:
            if seq['id'] in sequence_ids:
                errors.append(f"Sequence {i}: Duplicate ID '{seq['id']}'")
            sequence_ids.add(seq['id'])

    warnings.extend(total_warnings)
    return errors, warnings

def main():
    parser = argparse.ArgumentParser(description='Validate Garmin HASSequence configuration')
    parser.add_argument('config_file', help='Path to JSON configuration file')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show detailed information')
    parser.add_argument('--battery-tips', '-b', action='store_true', help='Show battery optimization tips')

    args = parser.parse_args()

    try:
        with open(args.config_file, 'r') as f:
            config = json.load(f)
    except FileNotFoundError:
        print(f"Error: File '{args.config_file}' not found")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in '{args.config_file}': {e}")
        sys.exit(1)

    errors, warnings = validate_config(config)

    if errors:
        print(f"❌ Validation failed with {len(errors)} error(s):")
        for error in errors:
            print(f"  • {error}")
        sys.exit(1)
    else:
        print("✅ Configuration is valid!")

        if warnings:
            print(f"\n⚠️  {len(warnings)} warning(s) for optimization:")
            for warning in warnings:
                print(f"  • {warning}")

        if args.verbose:
            sequences = config['sequences']
            print(f"\nFound {len(sequences)} sequence(s):")
            for i, seq in enumerate(sequences):
                timeout = seq.get('timeout', 1000)
                sequence = ' → '.join(seq['sequence'])
                action = f"{seq['action']['action']} on {seq['action']['entity']}"

                # Battery efficiency indicator
                battery_rating = "🟢" # Good
                if timeout < 1500 or len(seq['sequence']) > 4:
                    battery_rating = "🟡" # Okay
                if timeout < 1000 or len(seq['sequence']) > 6:
                    battery_rating = "🔴" # Poor

                print(f"  {i+1}. {battery_rating} {seq['id']}: {sequence} ({timeout}ms) → {action}")

        if args.battery_tips:
            print_battery_tips(config)

def print_battery_tips(config: Dict[str, Any]) -> None:
    """Print battery optimization recommendations."""
    print("\n🔋 Battery Optimization Tips:")

    sequences = config.get('sequences', [])

    # Analyze current config
    short_timeouts = [s for s in sequences if s.get('timeout', 1000) < 1500]
    long_sequences = [s for s in sequences if len(s.get('sequence', [])) > 4]

    if not short_timeouts and not long_sequences and len(sequences) <= 8:
        print("  ✅ Your configuration is already well-optimized for battery life!")
        return

    if short_timeouts:
        print(f"  • Consider increasing timeout for {len(short_timeouts)} sequence(s) to >= 1500ms")
        for seq in short_timeouts[:3]:  # Show first 3
            print(f"    - '{seq['id']}' currently {seq.get('timeout', 1000)}ms")

    if long_sequences:
        print(f"  • Consider shortening {len(long_sequences)} sequence(s) to <= 4 keys")
        for seq in long_sequences[:3]:  # Show first 3
            print(f"    - '{seq['id']}' currently {len(seq.get('sequence', []))} keys")

    if len(sequences) > 8:
        print(f"  • Consider reducing from {len(sequences)} to 6-8 sequences for better performance")

    print("\n  Optimal battery configuration:")
    print("    - Timeouts: 1500-3000ms")
    print("    - Sequences: 2-4 keys each")
    print("    - Total sequences: 6-8 maximum")
    print("    - Use simple key combinations (UP, DOWN, OK)")

if __name__ == '__main__':
    main()
