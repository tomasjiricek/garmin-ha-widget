#!/usr/bin/env python3
"""
Interactive test for key sequence logic
Simulates the widget's key sequence handling
"""

import json
import time

class KeySequenceSimulator:
    def __init__(self, config_file='../example-config.json'):
        with open(config_file, 'r') as f:
            self.config = json.load(f)

        self.sequences = {}
        for seq in self.config['sequences']:
            key_string = '-'.join(seq['keys'])
            self.sequences[key_string] = {
                'id': seq['id'],
                'action': seq['action'],
                'timeout': seq.get('timeout', 3000)
            }

        self.current_sequence = []
        self.timeout = 3.0  # seconds
        self.last_key_time = 0

    def handle_key_press(self, key):
        """Simulate key press handling"""
        current_time = time.time()

        # Check timeout
        if current_time - self.last_key_time > self.timeout:
            self.current_sequence = []

        self.current_sequence.append(key)
        self.last_key_time = current_time

        # Check if current sequence matches any configured sequence
        current_key_string = '-'.join(self.current_sequence)

        for seq_key, seq_data in self.sequences.items():
            if seq_key == current_key_string:
                print(f"🎉 Sequence completed: {seq_data['id']}")
                print(f"   Action: {seq_data['action']['action']}")
                if 'entity_id' in seq_data['action']:
                    print(f"   Entity: {seq_data['action']['entity_id']}")
                self.current_sequence = []
                return True
            elif seq_key.startswith(current_key_string):
                print(f"📝 Partial sequence: {current_key_string}")
                return False

        # No match found, reset
        print(f"❌ No matching sequence for: {current_key_string}")
        self.current_sequence = []
        return False

    def show_available_sequences(self):
        """Display all configured sequences"""
        print("\n📋 Available sequences:")
        for seq_key, seq_data in self.sequences.items():
            print(f"  {seq_key} → {seq_data['id']} ({seq_data['action']['action']})")
        print()

def main():
    print("🎮 Garmin HASSequence - Key Sequence Simulator")
    print("=" * 50)

    try:
        simulator = KeySequenceSimulator()
        simulator.show_available_sequences()

        print("Available keys: UP, DOWN, OK, BACK, LIGHT, MENU")
        print("Type key names separated by spaces, or 'quit' to exit")
        print("Example: UP DOWN OK")
        print()

        while True:
            try:
                user_input = input("Keys: ").strip().upper()

                if user_input in ['QUIT', 'Q', 'EXIT']:
                    break

                if not user_input:
                    continue

                keys = user_input.split()
                valid_keys = {'UP', 'DOWN', 'OK', 'BACK', 'LIGHT', 'MENU'}

                for key in keys:
                    if key not in valid_keys:
                        print(f"❌ Invalid key: {key}")
                        continue

                    print(f"🔘 Key pressed: {key}")
                    simulator.handle_key_press(key)
                    time.sleep(0.1)  # Small delay between keys

                print()

            except KeyboardInterrupt:
                break

        print("\n👋 Simulator finished")

    except FileNotFoundError:
        print("❌ Configuration file not found")
    except json.JSONDecodeError:
        print("❌ Invalid JSON configuration")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
