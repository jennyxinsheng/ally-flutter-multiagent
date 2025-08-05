import '../core/agent_base.dart';
import '../services/knowledge_base.dart';

class BehaviorAgent extends AgentBase {
  @override
  String get name => 'behavior_specialist';
  
  @override
  String get description => 'I specialize in child behavior guidance using brain science. I can help with tantrums, aggression, defiance, and other behavioral challenges.';
  
  @override
  List<Tool> get tools => [
    _createBehaviorGuidanceTool(),
    _createBehaviorScriptsTool(),
    _createRedFlagsTool(),
    _createBehaviorSearchTool(),
    _createImmediateStrategesTool(),
  ];
  
  Tool _createBehaviorGuidanceTool() => Tool(
    name: 'get_behavior_guidance',
    description: 'Get comprehensive guidance for a specific behavior issue',
    parameters: {
      'type': 'object',
      'properties': {
        'behavior': {'type': 'string', 'description': 'The behavior issue (e.g., tantrums, aggression, defiance)'},
        'child_age': {'type': 'string', 'description': 'Age of the child (optional)'}
      },
      'required': ['behavior']
    },
    handler: _handleBehaviorGuidance
  );
  
  Tool _createBehaviorScriptsTool() => Tool(
    name: 'get_behavior_scripts',
    description: 'Get specific scripts and phrases for handling behavior situations',
    parameters: {
      'type': 'object',
      'properties': {
        'behavior': {'type': 'string', 'description': 'The behavior situation'},
        'scenario': {'type': 'string', 'description': 'Specific scenario (optional)'}
      },
      'required': ['behavior']
    },
    handler: _handleBehaviorScripts
  );
  
  Tool _createRedFlagsTool() => Tool(
    name: 'get_red_flags',
    description: 'Get information about when to seek professional help for behavior issues',
    parameters: {
      'type': 'object',
      'properties': {
        'behavior': {'type': 'string', 'description': 'The behavior of concern'},
        'child_age': {'type': 'string', 'description': 'Age of the child (optional)'}
      },
      'required': ['behavior']
    },
    handler: _handleRedFlags
  );
  
  Tool _createBehaviorSearchTool() => Tool(
    name: 'search_behavior_knowledge',
    description: 'Search the behavior knowledge base for specific information',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {'type': 'string', 'description': 'Search query for behavior information'}
      },
      'required': ['query']
    },
    handler: _handleBehaviorSearch
  );
  
  Tool _createImmediateStrategesTool() => Tool(
    name: 'get_immediate_strategies',
    description: 'Get immediate strategies for handling a behavior situation right now',
    parameters: {
      'type': 'object',
      'properties': {
        'behavior': {'type': 'string', 'description': 'The behavior happening now'},
        'intensity': {'type': 'string', 'description': 'Intensity level (mild, moderate, severe) - optional'}
      },
      'required': ['behavior']
    },
    handler: _handleImmediateStrategies
  );
  
  Future<Map<String, dynamic>> _handleBehaviorGuidance(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadBehaviorKnowledge();
      final behavior = args['behavior'] as String;
      final childAge = args['child_age'] as String?;
      
      final categories = knowledge['behavioral_categories'] as Map<String, dynamic>;
      
      // Find matching behavior category
      Map<String, dynamic>? matchedCategory;
      String? categoryName;
      
      for (final entry in categories.entries) {
        final category = entry.value as Map<String, dynamic>;
        final definition = category['definition'] as String? ?? '';
        final manifestations = category['common_manifestations'] as List<dynamic>? ?? [];
        
        if (entry.key.toLowerCase().contains(behavior.toLowerCase()) ||
            definition.toLowerCase().contains(behavior.toLowerCase()) ||
            manifestations.any((m) => m.toString().toLowerCase().contains(behavior.toLowerCase()))) {
          matchedCategory = category;
          categoryName = entry.key;
          break;
        }
      }
      
      if (matchedCategory == null) {
        return {
          'status': 'success',
          'message': 'I couldn\'t find specific guidance for "$behavior" in my knowledge base. Could you try describing the behavior differently? For example: tantrums, aggression, defiance, or anxiety.'
        };
      }
      
      final response = StringBuffer();
      response.writeln('**$categoryName Guidance**\n');
      response.writeln('${matchedCategory['definition']}\n');
      
      if (matchedCategory['common_manifestations'] != null) {
        response.writeln('**Common signs:**');
        for (final manifestation in matchedCategory['common_manifestations'] as List) {
          response.writeln('• $manifestation');
        }
        response.writeln();
      }
      
      if (matchedCategory['immediate_strategies'] != null) {
        response.writeln('**Immediate strategies:**');
        for (final strategy in matchedCategory['immediate_strategies'] as List) {
          response.writeln('• $strategy');
        }
        response.writeln();
      }
      
      if (matchedCategory['preventative_strategies'] != null) {
        response.writeln('**Prevention strategies:**');
        for (final strategy in matchedCategory['preventative_strategies'] as List) {
          response.writeln('• $strategy');
        }
        response.writeln();
      }
      
      // Add age-specific information if available and requested
      if (childAge != null && matchedCategory['age_specific_behaviors'] != null) {
        final ageSpecific = matchedCategory['age_specific_behaviors'] as Map<String, dynamic>;
        for (final ageEntry in ageSpecific.entries) {
          if (ageEntry.key.toLowerCase().contains(childAge.toLowerCase())) {
            response.writeln('**For ${ageEntry.key}:**');
            response.writeln('${ageEntry.value}\n');
          }
        }
      }
      
      if (matchedCategory['red_flags'] != null) {
        response.writeln('**⚠️ Seek professional help if:**');
        for (final flag in matchedCategory['red_flags'] as List) {
          response.writeln('• $flag');
        }
      }
      
      return {
        'status': 'success',
        'message': response.toString().trim()
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error retrieving behavior guidance: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> _handleBehaviorScripts(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadBehaviorKnowledge();
      final behavior = args['behavior'] as String;
      
      final scripts = knowledge['scripts'] as Map<String, dynamic>? ?? {};
      final matchedScripts = <String>[];
      
      for (final entry in scripts.entries) {
        if (entry.key.toLowerCase().contains(behavior.toLowerCase())) {
          final scriptData = entry.value as Map<String, dynamic>;
          matchedScripts.add('**${entry.key}**:\n"${scriptData['script']}"');
          
          if (scriptData['context'] != null) {
            matchedScripts.add('*When to use: ${scriptData['context']}*');
          }
        }
      }
      
      if (matchedScripts.isEmpty) {
        return {
          'status': 'success',
          'message': 'Here are some general behavior scripts:\n\n**Validation**: "I can see you\'re feeling [emotion]. That\'s hard."\n\n**Setting boundaries**: "I won\'t let you [behavior]. I\'m here to keep you safe."\n\n**Offering choices**: "You can [option 1] or [option 2]. You choose."\n\nFor specific scripts, please ask about a particular behavior situation.'
        };
      }
      
      return {
        'status': 'success',
        'message': 'Behavior Scripts:\n\n${matchedScripts.join('\n\n')}'
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error retrieving behavior scripts: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> _handleRedFlags(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadBehaviorKnowledge();
      final behavior = args['behavior'] as String;
      
      final categories = knowledge['behavioral_categories'] as Map<String, dynamic>;
      final redFlags = <String>[];
      
      for (final entry in categories.entries) {
        final category = entry.value as Map<String, dynamic>;
        if (entry.key.toLowerCase().contains(behavior.toLowerCase()) ||
            (category['definition'] as String? ?? '').toLowerCase().contains(behavior.toLowerCase())) {
          
          if (category['red_flags'] != null) {
            redFlags.add('**${entry.key} - Seek help if:**');
            for (final flag in category['red_flags'] as List) {
              redFlags.add('• $flag');
            }
          }
        }
      }
      
      if (redFlags.isEmpty) {
        return {
          'status': 'success',
          'message': 'General red flags for seeking professional help:\n\n• Behavior is significantly impacting daily life\n• Safety concerns for child or others\n• Behavior persists despite consistent strategies\n• Regression in previously mastered skills\n• Extreme intensity or frequency of behaviors\n• Your parental instinct says something isn\'t right\n\nTrust your instincts - you know your child best!'
        };
      }
      
      return {
        'status': 'success',
        'message': redFlags.join('\n')
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error retrieving red flag information: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> _handleBehaviorSearch(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadBehaviorKnowledge();
      final query = args['query'] as String;
      final queryLower = query.toLowerCase();
      
      final results = <String>[];
      final categories = knowledge['behavioral_categories'] as Map<String, dynamic>;
      
      for (final entry in categories.entries) {
        final category = entry.value as Map<String, dynamic>;
        final definition = category['definition'] as String? ?? '';
        
        if (entry.key.toLowerCase().contains(queryLower) ||
            definition.toLowerCase().contains(queryLower)) {
          results.add('**${entry.key}**: $definition');
        }
      }
      
      if (results.isEmpty) {
        return {
          'status': 'success',
          'message': 'No specific results found for "$query". Try searching for terms like: tantrums, aggression, defiance, anxiety, or describe the specific behavior you\'re seeing.'
        };
      }
      
      return {
        'status': 'success',
        'message': 'Search results for "$query":\n\n${results.join('\n\n')}'
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error searching behavior knowledge: $e'
      };
    }
  }
  
  Future<Map<String, dynamic>> _handleImmediateStrategies(Map<String, dynamic> args) async {
    try {
      final knowledge = await KnowledgeBase.loadBehaviorKnowledge();
      final behavior = args['behavior'] as String;
      
      final categories = knowledge['behavioral_categories'] as Map<String, dynamic>;
      
      for (final entry in categories.entries) {
        final category = entry.value as Map<String, dynamic>;
        if (entry.key.toLowerCase().contains(behavior.toLowerCase()) ||
            (category['definition'] as String? ?? '').toLowerCase().contains(behavior.toLowerCase())) {
          
          if (category['immediate_strategies'] != null) {
            final strategies = category['immediate_strategies'] as List;
            final response = StringBuffer();
            response.writeln('**Immediate strategies for ${entry.key}:**\n');
            
            for (final strategy in strategies) {
              response.writeln('• $strategy');
            }
            
            response.writeln('\n**Remember**: Stay calm, validate feelings, and prioritize safety.');
            
            return {
              'status': 'success',
              'message': response.toString().trim()
            };
          }
        }
      }
      
      return {
        'status': 'success',
        'message': 'General immediate strategies:\n\n• Stay calm and breathe\n• Get down to child\'s eye level\n• Validate their feelings: "I see you\'re upset"\n• Offer comfort if they want it\n• Keep everyone safe\n• Use simple, clear language\n• Avoid reasoning during intense moments\n\nWhat specific behavior are you dealing with right now?'
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error retrieving immediate strategies: $e'
      };
    }
  }
  
  @override
  Future<String> processMessage(String message, Map<String, dynamic> context) async {
    return 'I\'m the behavior specialist. I can help with tantrums, aggression, defiance, and other behavioral challenges using brain science-based approaches. What behavior issue would you like guidance on?';
  }
}
