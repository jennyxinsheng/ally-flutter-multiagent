import 'package:flutter/material.dart';
import '../core/agent_base.dart';
import '../tools/memory_tools.dart';
import '../services/routing_service.dart';
import '../services/gemma_service.dart';
import '../models/session_state.dart';
import 'sleep_agent.dart';
import 'behavior_agent.dart';
import 'recipe_agent.dart';

class AllyAgent extends AgentBase {
  final String userId;
  final BuildContext? context;
  
  late final SleepAgent sleepAgent;
  late final BehaviorAgent behaviorAgent;
  late final RecipeAgent recipeAgent;
  
  SessionState sessionState = SessionState();
  
  AllyAgent({required this.userId, this.context}) {
    sleepAgent = SleepAgent();
    behaviorAgent = BehaviorAgent();
    recipeAgent = RecipeAgent(userId: userId);
  }
  
  @override
  String get name => 'ally_main';
  
  @override
  String get description => 'I\'m Ally, your parenting assistant. I can help with sleep, behavior, recipes, and managing your family\'s needs.';
  
  @override
  List<Tool> get tools => [
    ...MemoryTools.allTools(userId),
    _createAgentTransferTool(),
  ];
  
  Tool _createAgentTransferTool() => Tool(
    name: 'transfer_to_specialist',
    description: 'Transfer the conversation to a specialist agent',
    parameters: {
      'type': 'object',
      'properties': {
        'agent_name': {
          'type': 'string', 
          'enum': ['sleep_specialist', 'behavior_specialist', 'recipe_specialist'],
          'description': 'The specialist agent to transfer to'
        },
        'reason': {'type': 'string', 'description': 'Reason for the transfer'}
      },
      'required': ['agent_name', 'reason']
    },
    handler: _handleAgentTransfer
  );
  
  Future<Map<String, dynamic>> _handleAgentTransfer(Map<String, dynamic> args) async {
    final agentName = args['agent_name'] as String;
    final reason = args['reason'] as String;
    
    if (context != null) {
      final confirmed = await RoutingService.requestAgentTransfer(
        context!,
        name,
        agentName,
        reason
      );
      
      if (confirmed) {
        sessionState.currentAgent = agentName;
        return {
          'status': 'success',
          'message': 'Transferring you to the ${RoutingService.getAgentDescription(agentName)}...',
          'agent_transfer': agentName
        };
      } else {
        return {
          'status': 'success',
          'message': 'No problem! I\'ll continue helping you here. What else can I assist with?'
        };
      }
    } else {
      // Fallback for when no context is available
      sessionState.currentAgent = agentName;
      return {
        'status': 'success',
        'message': 'Transferring you to the ${RoutingService.getAgentDescription(agentName)} for specialized help.',
        'agent_transfer': agentName
      };
    }
  }
  
  @override
  Future<String> processMessage(String message, Map<String, dynamic> context) async {
    try {
      // Record the interaction
      sessionState.interactionHistory.add(Interaction(
        message: message,
        response: '', // Will be filled after processing
        agent: sessionState.currentAgent ?? name,
        timestamp: DateTime.now(),
      ));
      
      // Check if we should route to a specialist
      final detectedDomain = RoutingService.detectDomain(message);
      
      if (detectedDomain != null && sessionState.currentAgent != detectedDomain) {
        // Suggest transfer to appropriate specialist
        final reason = _getTransferReason(detectedDomain, message);
        
        if (this.context != null) {
          final confirmed = await RoutingService.requestAgentTransfer(
            this.context!,
            sessionState.currentAgent ?? name,
            detectedDomain,
            reason
          );
          
          if (confirmed) {
            sessionState.currentAgent = detectedDomain;
            return await _routeToAgent(detectedDomain, message, context);
          }
        } else {
          // Auto-transfer when no UI context
          sessionState.currentAgent = detectedDomain;
          return await _routeToAgent(detectedDomain, message, context);
        }
      }
      
      // Process with current agent
      if (sessionState.currentAgent != null) {
        return await _routeToAgent(sessionState.currentAgent!, message, context);
      }
      
      // Default main agent response
      return await _processMainAgentMessage(message, context);
      
    } catch (e) {
      return 'I encountered an error processing your message. Please try again. Error: $e';
    }
  }
  
  Future<String> _routeToAgent(String agentName, String message, Map<String, dynamic> context) async {
    AgentBase? targetAgent;
    
    switch (agentName) {
      case 'sleep_specialist':
        targetAgent = sleepAgent;
        break;
      case 'behavior_specialist':
        targetAgent = behaviorAgent;
        break;
      case 'recipe_specialist':
        targetAgent = recipeAgent;
        break;
      default:
        return await _processMainAgentMessage(message, context);
    }
    
    // Initialize Gemma with the agent's tools
    await GemmaService.instance.updateTools(targetAgent.tools);
    
    // Process the message with the specialist agent
    return await targetAgent.processMessage(message, context);
  }
  
  Future<String> _processMainAgentMessage(String message, Map<String, dynamic> context) async {
    // Initialize Gemma with main agent tools
    await GemmaService.instance.updateTools(tools);
    
    // Use Gemma to process the message
    final response = await GemmaService.instance.processMessageSync(message);
    
    // Update interaction history
    if (sessionState.interactionHistory.isNotEmpty) {
      sessionState.interactionHistory.last.response = response;
    }
    
    return response;
  }
  
  String _getTransferReason(String agentName, String message) {
    switch (agentName) {
      case 'sleep_specialist':
        return 'Your message appears to be about sleep-related concerns. The sleep specialist can provide detailed guidance on sleep problems, wake windows, and sleep training.';
      case 'behavior_specialist':
        return 'Your message seems to involve behavioral challenges. The behavior specialist can offer brain science-based strategies for managing difficult behaviors.';
      case 'recipe_specialist':
        return 'Your message is about food, recipes, or meal planning. The recipe specialist can help with kid-friendly recipes and grocery management.';
      default:
        return 'This specialist can better assist with your specific needs.';
    }
  }
  
  Future<void> initializeGemma() async {
    if (!GemmaService.instance.isInitialized) {
      await GemmaService.instance.initialize(tools: tools);
    }
  }
  
  void resetToMainAgent() {
    sessionState.currentAgent = null;
  }
  
  String getCurrentAgentName() {
    return sessionState.currentAgent ?? name;
  }
  
  AgentBase? getCurrentAgent() {
    switch (sessionState.currentAgent) {
      case 'sleep_specialist':
        return sleepAgent;
      case 'behavior_specialist':
        return behaviorAgent;
      case 'recipe_specialist':
        return recipeAgent;
      default:
        return this;
    }
  }
}
