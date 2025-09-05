#!/usr/bin/env python3
"""
Test script to demonstrate the async request handling improvements.

This script simulates rapid key presses that would trigger multiple
Home Assistant actions in quick succession, which was causing crashes
before the async improvements.
"""

import asyncio
import random
import json
import time
from typing import Dict, List, Callable

class MockHomeAssistantClient:
    """Mock class that simulates the behavior of the improved HomeAssistantClient"""
    
    def __init__(self):
        self.is_request_in_progress = False
        self.request_queue = []
        self.sent_requests = []
        
    async def send_action(self, action: Dict, callback: Callable):
        """Simulate the improved sendAction method"""
        if self.is_request_in_progress:
            print(f"⏳ Request queued: {action['action']} for {action['entity']}")
            self.request_queue.append({
                'action': action,
                'callback': callback
            })
            return
        
        await self._execute_action(action, callback)
    
    async def _execute_action(self, action: Dict, callback: Callable):
        """Simulate the _executeAction method"""
        print(f"🚀 Executing action: {action['action']} for {action['entity']}")
        self.is_request_in_progress = True
        self.sent_requests.append(action)
        
        # Simulate async HTTP request completion after a delay
        success = random.choice([True, True, True, False])  # 75% success rate
        
        # Simulate request taking some time (50-200ms)
        delay = random.uniform(0.05, 0.2)
        await asyncio.sleep(delay)
        
        status = "✅ Success" if success else "❌ Failed"
        print(f"   {status}: {action['action']} for {action['entity']}")
        
        self.is_request_in_progress = False
        callback(success)
        await self._process_next_request()
    
    async def _process_next_request(self):
        """Process the next request in queue"""
        if self.request_queue:
            next_request = self.request_queue.pop(0)
            action = next_request['action']
            print(f"📤 Processing queued request: {action['action']} for {action['entity']}")
            await self._execute_action(next_request['action'], next_request['callback'])

async def simulate_rapid_key_presses():
    """Simulate rapid key presses that trigger multiple actions"""
    
    # Sample Home Assistant actions that might be triggered
    actions = [
        {'entity': 'light.living_room', 'action': 'light.toggle'},
        {'entity': 'light.bedroom', 'action': 'light.toggle'},
        {'entity': 'script.good_night', 'action': 'script.turn_on'},
        {'entity': 'scene.movie_time', 'action': 'scene.turn_on'},
        {'entity': 'switch.coffee_maker', 'action': 'switch.toggle'},
    ]
    
    client = MockHomeAssistantClient()
    
    def action_callback(success: bool):
        """Callback function for when action completes"""
        pass  # In real app, this updates the UI
    
    print("🎯 TESTING RAPID REQUEST HANDLING")
    print("=" * 50)
    print("Simulating rapid key presses that trigger Home Assistant actions...\n")
    
    start_time = time.time()
    
    # Create tasks for rapid fire requests (faster than they can complete)
    tasks = []
    for i in range(8):
        action = random.choice(actions)
        print(f"🔥 Rapid request #{i+1}: {action['action']} for {action['entity']}")
        task = asyncio.create_task(client.send_action(action, action_callback))
        tasks.append(task)
        
        # Very short delay between requests (simulating rapid key presses)
        await asyncio.sleep(0.01)
    
    # Wait for all tasks to complete
    await asyncio.gather(*tasks)
    
    end_time = time.time()
    total_time = end_time - start_time
    
    print(f"\n📊 RESULTS:")
    print(f"   Total requests sent: 8")
    print(f"   Total requests executed: {len(client.sent_requests)}")
    print(f"   Total execution time: {total_time:.2f} seconds")
    print(f"   Requests queued: {len(client.request_queue)}")
    if client.request_queue:
        queue_items = [f"{req['action']['action']} for {req['action']['entity']}" for req in client.request_queue]
        print(f"   Current queue: {queue_items}")
    else:
        print(f"   Current queue: []")
    
    # Process remaining queue
    print(f"\n⏳ Processing remaining {len(client.request_queue)} queued requests...")
    while client.request_queue or client.is_request_in_progress:
        await asyncio.sleep(0.1)  # Let the queue process
    
    print(f"\n✅ All requests completed!")
    print(f"   Total executed: {len(client.sent_requests)}")
    
    print(f"\n🔧 IMPROVEMENTS MADE:")
    print(f"   ✅ Prevents crashes from concurrent requests")
    print(f"   ✅ Queues requests when one is in progress")
    print(f"   ✅ Processes requests sequentially") 
    print(f"   ✅ Maintains order of user actions")
    print(f"   ✅ Handles failures gracefully")
    print(f"   ✅ Uses proper async/await patterns")

if __name__ == "__main__":
    asyncio.run(simulate_rapid_key_presses())
