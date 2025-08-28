#!/usr/bin/env python3
"""
Garmin Connect IQ Widget Emulator
Simulates the widget's key functionality for local testing
"""

import json
import time
import threading
from datetime import datetime

class MockConnectIQEmulator:
    def __init__(self, iq_file):
        self.iq_file = iq_file
        self.device = "fenix7"
        self.is_running = False
        self.widget_state = {
            'status': 'Initializing...',
            'sequence': '',
            'config_loaded': False,
            'sequences': []
        }

    def load_configuration(self):
        """Simulate loading configuration from example file"""
        try:
            with open('example-config.json', 'r') as f:
                config = json.load(f)

            self.widget_state['sequences'] = config['sequences']
            self.widget_state['config_loaded'] = True
            self.widget_state['status'] = 'Ready'
            print("📡 Configuration loaded successfully")
            return True
        except Exception as e:
            print(f"❌ Configuration load failed: {e}")
            self.widget_state['status'] = 'Config Error'
            return False

    def start_widget(self):
        """Start the widget emulation"""
        print(f"🚀 Starting Garmin HASSequence Emulator")
        print(f"📱 Device: {self.device}")
        print(f"📦 Package: {self.iq_file}")
        print("=" * 50)

        # Simulate widget initialization
        print("🔄 Widget initializing...")
        time.sleep(1)

        # Load configuration
        self.load_configuration()

        self.is_running = True
        print("✅ Widget started successfully!")
        self.show_widget_screen()

    def show_widget_screen(self):
        """Display the current widget screen"""
        print("\n" + "="*40)
        print("│          HASSequence                   │")
        print("│                                      │")
        print(f"│  Status: {self.widget_state['status']:<24} │")
        if self.widget_state['sequence']:
            print(f"│  Sequence: {self.widget_state['sequence']:<22} │")
        else:
            print("│                                      │")
        print("="*40)

    def handle_key_press(self, key):
        """Simulate key press handling"""
        if not self.is_running:
            return

        print(f"🔘 Key pressed: {key}")

        # Update current sequence
        if self.widget_state['sequence']:
            self.widget_state['sequence'] += f"-{key}"
        else:
            self.widget_state['sequence'] = key

        # Check for sequence matches
        for seq_config in self.widget_state['sequences']:
            expected_keys = seq_config.get('sequence', seq_config.get('keys', []))
            expected_sequence = '-'.join(expected_keys)

            if self.widget_state['sequence'] == expected_sequence:
                print(f"🎉 Sequence completed: {seq_config['id']}")
                self.execute_action(seq_config['action'])
                self.widget_state['sequence'] = ''
                return True
            elif expected_sequence.startswith(self.widget_state['sequence']):
                print(f"📝 Partial sequence: {self.widget_state['sequence']}")
                self.show_widget_screen()
                return False

        # No match found
        print("❌ No matching sequence, resetting")
        self.widget_state['sequence'] = ''
        self.show_widget_screen()
        return False

    def execute_action(self, action):
        """Simulate executing a Home Assistant action"""
        print(f"📤 Executing action: {action['action']}")
        if 'entity' in action:
            print(f"🏠 Target entity: {action['entity']}")

        # Simulate network request
        self.widget_state['status'] = 'Sending...'
        self.show_widget_screen()
        time.sleep(1)

        # Simulate success (in real widget, this would be actual HTTP request)
        self.widget_state['status'] = 'Action Sent'
        self.show_widget_screen()

        # Reset after 3 seconds
        threading.Timer(3.0, self.reset_status).start()

    def reset_status(self):
        """Reset status to ready"""
        self.widget_state['status'] = 'Ready'
        self.show_widget_screen()

    def show_available_sequences(self):
        """Show all configured sequences"""
        print("\n📋 Available Key Sequences:")
        for i, seq in enumerate(self.widget_state['sequences'], 1):
            keys = seq.get('sequence', seq.get('keys', []))
            sequence_str = ' → '.join(keys)
            print(f"  {i}. {seq['id']}: {sequence_str}")
            print(f"     Action: {seq['action']['action']}")
            if 'entity' in seq['action']:
                print(f"     Entity: {seq['action']['entity']}")
            print()

    def interactive_mode(self):
        """Run interactive key input mode"""
        print("\n🎮 Interactive Mode - Enter key presses")
        print("Available keys: UP, DOWN, OK, BACK, LIGHT, MENU")
        print("Commands: 'sequences' to show all, 'quit' to exit")
        print()

        while self.is_running:
            try:
                user_input = input("Key (or command): ").strip().upper()

                if user_input in ['QUIT', 'Q', 'EXIT']:
                    break
                elif user_input == 'SEQUENCES':
                    self.show_available_sequences()
                    continue
                elif user_input == 'STATUS':
                    self.show_widget_screen()
                    continue
                elif user_input in ['UP', 'DOWN', 'OK', 'BACK', 'LIGHT', 'MENU']:
                    self.handle_key_press(user_input)
                elif user_input:
                    print(f"❌ Invalid key: {user_input}")

            except KeyboardInterrupt:
                break

        print("\n👋 Widget emulator stopped")

def main():
    import os
    """Main emulator function"""
    print("🎯 Garmin Connect IQ Widget Emulator")
    print(f"⏰ Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Check if package exists
    iq_file = os.path.join('dist', 'garmin-ha-widget.iq')
    try:
        if not os.path.exists(iq_file):
            print("❌ Widget package not found. Please build the widget first.")
            return

        package_size = os.path.getsize(iq_file)
        print(f"📦 Package found: {package_size:,} bytes")

    except Exception as e:
        print(f"❌ Error checking package: {e}")
        return

    # Start emulator
    emulator = MockConnectIQEmulator(iq_file)
    emulator.start_widget()

    # Show sequences
    if emulator.widget_state['config_loaded']:
        emulator.show_available_sequences()

    # Run interactive mode
    emulator.interactive_mode()

if __name__ == "__main__":
    main()
