#!/usr/bin/env python3
"""
Enhanced Interactive Widget Testing
Comprehensive local testing for Garmin HASSequence
"""

import json
import os
import sys
from datetime import datetime

class GarminWidgetTester:
    def __init__(self):
        self.widget_state = {
            'current_sequence': [],
            'status': 'Ready',
            'sequences': [],
            'config_loaded': False
        }
        self.sequence_timeout = 2000  # Default timeout in ms

    def load_configuration(self):
        """Load and validate configuration"""
        try:
            with open('../example-config.json', 'r') as f:
                config = json.load(f)

            self.widget_state['sequences'] = config['sequences']
            self.widget_state['config_loaded'] = True
            print("✅ Configuration loaded successfully")
            return True
        except Exception as e:
            print(f"❌ Configuration load failed: {e}")
            return False

    def display_widget_screen(self):
        """Display current widget state"""
        print("\n" + "="*50)
        print("│               GARMIN HA WIDGET               │")
        print("│                                              │")
        print(f"│  Status: {self.widget_state['status']:<31} │")

        if self.widget_state['current_sequence']:
            sequence_display = " → ".join(self.widget_state['current_sequence'])
            print(f"│  Sequence: {sequence_display:<29} │")
        else:
            print("│                                              │")

        print("│                                              │")
        print("="*50)

    def find_matching_sequences(self, current_keys):
        """Find sequences that match or partially match current keys"""
        matches = []
        partial_matches = []

        for seq_config in self.widget_state['sequences']:
            expected_keys = seq_config['sequence']

            if len(current_keys) <= len(expected_keys):
                # Check if current keys match the beginning of this sequence
                if expected_keys[:len(current_keys)] == current_keys:
                    if len(current_keys) == len(expected_keys):
                        matches.append(seq_config)
                    else:
                        partial_matches.append(seq_config)

        return matches, partial_matches

    def handle_key_press(self, key):
        """Process a key press"""
        print(f"\n🔘 Key pressed: {key}")

        # Add key to current sequence
        self.widget_state['current_sequence'].append(key)

        # Check for matches
        matches, partial_matches = self.find_matching_sequences(self.widget_state['current_sequence'])

        if matches:
            # Complete sequence found
            sequence_config = matches[0]
            print(f"🎉 Sequence completed: {sequence_config['id']}")
            self.execute_action(sequence_config)
            self.widget_state['current_sequence'] = []

        elif partial_matches:
            # Partial match, continue sequence
            next_keys = []
            for seq in partial_matches:
                next_key = seq['sequence'][len(self.widget_state['current_sequence'])]
                if next_key not in next_keys:
                    next_keys.append(next_key)

            print(f"📝 Partial match. Next keys: {', '.join(next_keys)}")

        else:
            # No match, reset
            print("❌ No matching sequence found, resetting")
            self.widget_state['current_sequence'] = []

        self.display_widget_screen()

    def execute_action(self, sequence_config):
        """Simulate executing a Home Assistant action"""
        action = sequence_config['action']
        print(f"\n📤 Executing Home Assistant Action:")
        print(f"   🏠 Entity: {action.get('entity', 'N/A')}")
        print(f"   🔧 Action: {action.get('action', 'N/A')}")

        # Simulate network request
        self.widget_state['status'] = 'Sending...'
        self.display_widget_screen()

        # Simulate success
        import time
        time.sleep(0.5)
        self.widget_state['status'] = 'Action Sent'
        self.display_widget_screen()

        # Reset after delay
        time.sleep(1)
        self.widget_state['status'] = 'Ready'

    def show_available_sequences(self):
        """Display all configured sequences"""
        print("\n📋 AVAILABLE KEY SEQUENCES:")
        print("-" * 50)

        for i, seq in enumerate(self.widget_state['sequences'], 1):
            keys = " → ".join(seq['sequence'])
            timeout = seq.get('timeout', 1000)
            action_type = seq['action']['action']
            entity = seq['action'].get('entity', 'N/A')

            # Battery efficiency indicator
            battery_icon = "🟢"  # Good
            if timeout < 1500 or len(seq['sequence']) > 4:
                battery_icon = "🟡"  # Okay
            if timeout < 1000 or len(seq['sequence']) > 6:
                battery_icon = "🔴"  # Poor

            print(f"{i:2}. {battery_icon} {seq['id']}")
            print(f"     Keys: {keys}")
            print(f"     Timeout: {timeout}ms")
            print(f"     Action: {action_type} → {entity}")
            print()

    def show_battery_info(self):
        """Show battery optimization info"""
        print("\n🔋 BATTERY OPTIMIZATION STATUS:")
        print("-" * 50)

        total_sequences = len(self.widget_state['sequences'])
        efficient_count = 0

        for seq in self.widget_state['sequences']:
            timeout = seq.get('timeout', 1000)
            key_count = len(seq['sequence'])

            if timeout >= 1500 and key_count <= 4:
                efficient_count += 1

        efficiency_percent = (efficient_count / total_sequences * 100) if total_sequences > 0 else 0

        print(f"Total sequences: {total_sequences}")
        print(f"Battery efficient: {efficient_count} ({efficiency_percent:.0f}%)")

        if efficiency_percent >= 80:
            print("✅ Excellent battery optimization!")
        elif efficiency_percent >= 60:
            print("🟡 Good battery optimization")
        else:
            print("🔴 Consider optimizing for better battery life")

        print("\nRecommendations:")
        print("- Use timeouts ≥ 1500ms")
        print("- Keep sequences ≤ 4 keys")
        print("- Limit total sequences to 6-8")

    def run_interactive_test(self):
        """Run interactive testing mode"""
        print("🎯 GARMIN HA WIDGET - INTERACTIVE TESTER")
        print(f"⏰ Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 50)

        # Check widget package
        if os.path.exists('../bin/garmin-hassequence-widget.iq'):
            size = os.path.getsize('../bin/garmin-hassequence-widget.iq')
            print(f"📦 Widget package: {size:,} bytes")
        else:
            print("❌ Widget package not found!")
            return

        # Load configuration
        if not self.load_configuration():
            return

        self.display_widget_screen()
        self.show_available_sequences()

        print("\n🎮 INTERACTIVE MODE")
        print("Commands:")
        print("  - Enter key names: UP, DOWN, OK, BACK, LIGHT, MENU")
        print("  - 'sequences' - Show all sequences")
        print("  - 'battery' - Show battery optimization info")
        print("  - 'reset' - Clear current sequence")
        print("  - 'quit' - Exit")
        print()

        while True:
            try:
                user_input = input("🔘 Enter key or command: ").strip().upper()

                if user_input in ['QUIT', 'Q', 'EXIT']:
                    print("\n👋 Testing completed!")
                    break
                elif user_input == 'SEQUENCES':
                    self.show_available_sequences()
                elif user_input == 'BATTERY':
                    self.show_battery_info()
                elif user_input == 'RESET':
                    self.widget_state['current_sequence'] = []
                    print("🔄 Sequence reset")
                    self.display_widget_screen()
                elif user_input == 'STATUS':
                    self.display_widget_screen()
                elif user_input in ['UP', 'DOWN', 'OK', 'BACK', 'LIGHT', 'MENU']:
                    self.handle_key_press(user_input)
                elif user_input:
                    print(f"❌ Invalid command: {user_input}")
                    print("Valid keys: UP, DOWN, OK, BACK, LIGHT, MENU")

            except KeyboardInterrupt:
                print("\n\n👋 Testing interrupted!")
                break
            except EOFError:
                print("\n\n👋 Testing completed!")
                break

def main():
    """Main testing function"""
    tester = GarminWidgetTester()
    tester.run_interactive_test()

if __name__ == "__main__":
    main()
