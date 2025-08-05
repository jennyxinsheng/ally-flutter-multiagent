import 'package:flutter/material.dart';

class RoutingService {
  static Future<bool> requestAgentTransfer(
    BuildContext context,
    String fromAgent, 
    String toAgent, 
    String reason
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agent Transfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('I\'d like to transfer you to the $toAgent for better assistance.'),
              const SizedBox(height: 8),
              Text('Reason: $reason'),
              const SizedBox(height: 16),
              const Text('Would you like to proceed with this transfer?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay Here'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
  
  static String? detectDomain(String message) {
    final messageLower = message.toLowerCase();
    
    // Sleep-related keywords
    final sleepKeywords = [
      'sleep', 'nap', 'bedtime', 'wake', 'night', 'tired', 'drowsy',
      'insomnia', 'nightmare', 'dream', 'rest', 'sleepy', 'awake',
      'wake window', 'sleep training', 'sleep schedule', 'sleep regression'
    ];
    
    // Behavior-related keywords
    final behaviorKeywords = [
      'tantrum', 'meltdown', 'aggressive', 'hitting', 'biting', 'defiant',
      'behavior', 'discipline', 'timeout', 'consequence', 'angry', 'upset',
      'crying', 'screaming', 'throwing', 'kicking', 'stubborn', 'disobedient',
      'emotional', 'regulation', 'feelings', 'mood', 'attitude'
    ];
    
    // Recipe/food-related keywords
    final recipeKeywords = [
      'recipe', 'cook', 'meal', 'food', 'eat', 'hungry', 'dinner', 'lunch',
      'breakfast', 'snack', 'grocery', 'ingredient', 'nutrition', 'picky eater',
      'meal plan', 'cooking', 'kitchen', 'prepare', 'bake', 'healthy eating'
    ];
    
    // Check for sleep domain
    if (sleepKeywords.any((keyword) => messageLower.contains(keyword))) {
      return 'sleep_specialist';
    }
    
    // Check for behavior domain
    if (behaviorKeywords.any((keyword) => messageLower.contains(keyword))) {
      return 'behavior_specialist';
    }
    
    // Check for recipe domain
    if (recipeKeywords.any((keyword) => messageLower.contains(keyword))) {
      return 'recipe_specialist';
    }
    
    // No specific domain detected, stay with main agent
    return null;
  }
  
  static String getAgentDescription(String agentName) {
    switch (agentName) {
      case 'sleep_specialist':
        return 'sleep specialist who can help with sleep problems, wake windows, and sleep training';
      case 'behavior_specialist':
        return 'behavior specialist who can provide guidance on tantrums, discipline, and emotional regulation';
      case 'recipe_specialist':
        return 'recipe specialist who can suggest meals, manage grocery lists, and provide nutrition advice';
      default:
        return 'specialist';
    }
  }
}
