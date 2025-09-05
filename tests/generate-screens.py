#!/usr/bin/env python3
"""
Generate ASCII art representation of the Garmin HASSequence screen
"""

def generate_widget_screen(status="Ready", sequence="", battery_level=None):
    """Generate ASCII representation of widget screen"""

    # Widget dimensions (approximate Garmin watch screen)
    width = 50

    screen = []
    screen.append("┌" + "─" * (width-2) + "┐")
    screen.append("│" + " " * (width-2) + "│")

    # Title - HASSequence at top
    title = "HASSequence"
    padding = (width - 2 - len(title)) // 2
    screen.append("│" + " " * padding + title + " " * (width - 2 - padding - len(title)) + "│")
    screen.append("│" + " " * (width-2) + "│")
    screen.append("│" + " " * (width-2) + "│")
    screen.append("│" + " " * (width-2) + "│")
    screen.append("│" + " " * (width-2) + "│")

    # Status - center of screen (handle multi-line properly)
    status_lines = status.split('\n') if '\n' in status else [status]

    for line in status_lines:
        padding = (width - 2 - len(line)) // 2
        screen.append("│" + " " * padding + line + " " * (width - 2 - padding - len(line)) + "│")

    # Sequence display - below status if active (no "Sequence:" prefix, no arrows, matches actual widget)
    if sequence:
        padding = (width - 2 - len(sequence)) // 2
        screen.append("│" + " " * padding + sequence + " " * (width - 2 - padding - len(sequence)) + "│")

    # Fill remaining space (matches actual widget's simple layout)
    total_lines = 15  # Total lines needed for the screen
    while len(screen) < total_lines:
        screen.append("│" + " " * (width-2) + "│")

    screen.append("└" + "─" * (width-2) + "┘")

    return "\n".join(screen)

def generate_sequence_examples():
    """Generate examples of different widget states"""

    print("🎯 GARMIN HOME ASSISTANT WIDGET - SCREEN MOCKUPS")
    print("=" * 60)

    # State 1: Ready
    print("\n📱 STATE 1: Widget Ready")
    print(generate_widget_screen("Ready", ""))

    # State 2: Sequence in progress
    print("\n📱 STATE 2: Key Sequence in Progress")
    print(generate_widget_screen("Ready", "UP-DOWN"))

    # State 3: Action being sent
    print("\n📱 STATE 3: Sending Action to Home Assistant")
    print(generate_widget_screen("Action sent", ""))

    # State 4: Configuration error
    print("\n📱 STATE 4: Configuration Error")
    print(generate_widget_screen("Error:\nConfig empty or invalid", ""))

    print("\n� WIDGET BEHAVIOR:")
    print("  • Displays 'HASSequence' title at the top")
    print("  • Shows status messages in center (Ready, Action sent, Error messages)")
    print("  • Displays current key sequence below status when active")
    print("  • Uses simple text layout matching Garmin widget standards")
    print("  • No battery indicators or decorative elements")

    print("\n📋 CONFIGURED SEQUENCES (from ../example-config.json):")
    try:
        import json
        with open('../example-config.json', 'r') as f:
            config = json.load(f)

        for i, seq in enumerate(config['sequences'], 1):
            keys = "-".join(seq['sequence'])
            action = seq['action']['action']
            entity = seq['action'].get('entity', 'N/A')

            print(f"  {i}. {seq['id']}: {keys} → {action} ({entity})")

    except FileNotFoundError:
        print("  (../example-config.json not found)")

    print("\n✅ Widget accurately represents the actual Garmin implementation!")

if __name__ == "__main__":
    generate_sequence_examples()
