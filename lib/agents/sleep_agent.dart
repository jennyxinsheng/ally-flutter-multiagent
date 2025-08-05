import '../core/agent_base.dart';
import '../services/knowledge_base.dart';

class SleepAgent extends AgentBase {
  @override
  String get name => 'sleep_specialist';
  
  @override
  String get description => 'I specialize in sleep issues for children. I can help with sleep problems, wake windows, and age-specific sleep guidance.';
  
  @override
  List<Tool> get tools => [
    _createSleepKnowledgeTool(),
    _createWakeWindowTool(),
    _createSleepMethodsTool(),
    _createAgeSpecificSleepTool(),
  ];
  
  Tool _createSleepKnowledgeTool() => Tool(
    name: 'sleep_knowledge_search',
    description: 'Search the sleep knowledge base for information about sleep problems and solutions',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {'type': 'string', 'description': 'The sleep-related question or problem'},
        'child_age': {'type': 'string', 'description': 'Optional age of child (e.g., "6 months", "2 years")'}
      },
      'required': ['query']
    },
    handler: _handleSleepKnowledgeSearch
  );
  
  Tool _createWakeWindowTool() => Tool(
    name: 'get_wake_windows',
    description: 'Get appropriate wake windows for a child based on their age',
    parameters: {
      'type': 'object',
      'properties': {
        'age': {'type': 'string', 'description': 'Age of the child (e.g., "6 months", "2 years")'}
      },
      'required': ['age']
    },
    handler: _handleWakeWindows
  );
  
  Tool _createSleepMethodsTool() => Tool(
    name: 'get_sleep_methods',
    description: 'Get sleep training methods and techniques',
    parameters: {
      'type': 'object',
      'properties': {
        'problem_type': {'type': 'string', 'description': 'Type of sleep problem (optional)'},
        'child_age': {'type': 'string', 'description': 'Age of child (optional)'}
      },
      'required': []
    },
    handler: _handleSleepMethods
  );
  
  Tool _createAgeSpecificSleepTool() => Tool(
    name: 'get_age_specific_sleep_info',
    description: 'Get age-specific sleep information and expectations',
    parameters: {
      'type': 'object',
      'properties': {
        'age': {'type': 'string', 'description': 'Age of the child'}
      },
      'required': ['age']
    },
    handler: _handleAgeSpecificSleep
  );
  
  Future<Map<String, dynamic>> _handleSleepKnowledgeSearch(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadSleepKnowledge();
      final query = args['query'] as String;
      final childAge = args['child_age'] as String?;
      
      final problems = knowledge['problems'] as Map<String, dynamic>;
      final concepts = knowledge['concepts'] as Map<String, dynamic>;
      
      // Search for relevant problems by symptoms or keywords
      final matchedProblems = <String, dynamic>{};
      final matchedConcepts = <String, dynamic>{};
      
      final queryLower = query.toLowerCase();
      
      // Search problems
      for (final entry in problems.entries) {
        final problem = entry.value as Map<String, dynamic>;
        final symptoms = problem['symptoms'] as List<dynamic>? ?? [];
        final definition = problem['definition'] as String? ?? '';
        
        if (definition.toLowerCase().contains(queryLower) ||
            symptoms.any((symptom) => symptom.toString().toLowerCase().contains(queryLower))) {
          matchedProblems[entry.key] = problem;
        }
      }
      
      // Search concepts
      for (final entry in concepts.entries) {
        final concept = entry.value as Map<String, dynamic>;
        final definition = concept['definition'] as String? ?? '';
        
        if (definition.toLowerCase().contains(queryLower) ||
            entry.key.toLowerCase().contains(queryLower)) {
          matchedConcepts[entry.key] = concept;
        }
      }
      
      if (matchedProblems.isEmpty && matchedConcepts.isEmpty) {
        return {
          'status': 'success',
          'message': 'I couldn\'t find specific information about "$query" in my sleep knowledge base. Could you provide more details about the sleep issue you\'re experiencing?'
        };
      }
      
      final response = StringBuffer();
      
      if (matchedProblems.isNotEmpty) {
        response.writeln('**Sleep Problems Found:**\n');
        for (final entry in matchedProblems.entries) {
          final problem = entry.value as Map<String, dynamic>;
          response.writeln('**${entry.key}**');
          response.writeln('${problem['definition']}\n');
          
          if (problem['immediate_solutions'] != null) {
            response.writeln('*Immediate solutions:*');
            for (final solution in problem['immediate_solutions'] as List) {
              response.writeln('• $solution');
            }
            response.writeln();
          }
          
          if (childAge != null && problem['age_groups'] != null) {
            final ageGroups = problem['age_groups'] as Map<String, dynamic>;
            for (final ageEntry in ageGroups.entries) {
              if (ageEntry.key.toLowerCase().contains(childAge.toLowerCase())) {
                response.writeln('*For ${ageEntry.key}:*');
                response.writeln('${ageEntry.value}\n');
              }
            }
          }
        }
      }
      
      if (matchedConcepts.isNotEmpty) {
        response.writeln('**Related Sleep Concepts:**\n');
        for (final entry in matchedConcepts.entries) {
          final concept = entry.value as Map<String, dynamic>;
          response.writeln('**${entry.key}**: ${concept['definition']}\n');
        }
      }
      
      return {
        'status': 'success',
        'message': response.toString().trim()
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error searching sleep knowledge: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> _handleWakeWindows(Map<String, dynamic> args) async {
    final age = args['age'] as String;
    
    // Basic wake window guidelines
    final wakeWindows = {
      'newborn': '45-60 minutes',
      '0-3 months': '45-90 minutes',
      '3-4 months': '75-120 minutes',
      '4-6 months': '1.5-2.5 hours',
      '6-8 months': '2-3 hours',
      '8-10 months': '2.5-3.5 hours',
      '10-14 months': '3-4 hours',
      '14-24 months': '4-6 hours',
      '2+ years': '5-6 hours (if still napping)',
    };
    
    final ageLower = age.toLowerCase();
    String? matchedWindow;
    
    for (final entry in wakeWindows.entries) {
      if (ageLower.contains(entry.key) || entry.key.contains(ageLower)) {
        matchedWindow = entry.value;
        break;
      }
    }
    
    if (matchedWindow != null) {
      return {
        'status': 'success',
        'message': 'For a $age old child, appropriate wake windows are typically $matchedWindow. Remember that these are guidelines and every child is different. Watch for your child\'s sleep cues!'
      };
    } else {
      return {
        'status': 'success',
        'message': 'I don\'t have specific wake window information for "$age". Could you provide the age in months or years? (e.g., "6 months", "2 years")'
      };
    }
  }
  
  Future<Map<String, dynamic>> _handleSleepMethods(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadSleepKnowledge();
      final concepts = knowledge['concepts'] as Map<String, dynamic>;
      
      final methods = <String>[];
      
      // Extract sleep methods from concepts
      for (final entry in concepts.entries) {
        if (entry.key.toLowerCase().contains('method') || 
            entry.key.toLowerCase().contains('training') ||
            entry.key.toLowerCase().contains('technique')) {
          final concept = entry.value as Map<String, dynamic>;
          methods.add('**${entry.key}**: ${concept['definition']}');
        }
      }
      
      if (methods.isEmpty) {
        return {
          'status': 'success',
          'message': 'Here are some general sleep training approaches:\n\n• **Gradual methods**: Slowly reducing parental intervention\n• **Check and console**: Brief check-ins without picking up\n• **Chair method**: Gradually moving further from the crib\n• **No tears methods**: Gentle approaches without crying\n\nFor specific methods, please ask about a particular sleep problem you\'re facing.'
        };
      }
      
      return {
        'status': 'success',
        'message': 'Sleep Methods and Techniques:\n\n${methods.join('\n\n')}'
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error retrieving sleep methods: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> _handleAgeSpecificSleep(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadSleepKnowledge();
      final age = args['age'] as String;
      
      // Look for age-specific information in problems
      final problems = knowledge['problems'] as Map<String, dynamic>;
      final ageInfo = <String>[];
      
      for (final entry in problems.entries) {
        final problem = entry.value as Map<String, dynamic>;
        final ageGroups = problem['age_groups'] as Map<String, dynamic>? ?? {};
        
        for (final ageEntry in ageGroups.entries) {
          if (ageEntry.key.toLowerCase().contains(age.toLowerCase())) {
            ageInfo.add('**${entry.key}** (${ageEntry.key}): ${ageEntry.value}');
          }
        }
      }
      
      if (ageInfo.isEmpty) {
        return {
          'status': 'success',
          'message': 'I don\'t have specific age-related sleep information for "$age" in my knowledge base. Could you ask about a specific sleep problem or provide the age in a different format? (e.g., "6 months", "toddler", "2 years")'
        };
      }
      
      return {
        'status': 'success',
        'message': 'Age-specific sleep information for $age:\n\n${ageInfo.join('\n\n')}'
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error retrieving age-specific sleep information: $e'
      };
    }
  }
  
  @override
  Future<String> processMessage(String message, Map<String, dynamic> context) async {
    // This would be called by the main orchestrator
    // For now, return a simple response indicating this is the sleep specialist
    return 'I\'m the sleep specialist. I can help with sleep problems, wake windows, and sleep training methods. What sleep issue would you like help with?';
  }
}
