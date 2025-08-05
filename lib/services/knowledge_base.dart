import 'dart:convert';
import 'package:flutter/services.dart';

class KnowledgeBase {
  static Map<String, dynamic>? _sleepKnowledge;
  static Map<String, dynamic>? _behaviorKnowledge;
  
  static Future<Map<String, dynamic>> loadSleepKnowledge() async {
    if (_sleepKnowledge == null) {
      final jsonString = await rootBundle.loadString('assets/knowledge/sleep_knowledge_graph.json');
      _sleepKnowledge = json.decode(jsonString);
    }
    return _sleepKnowledge!;
  }
  
  static Future<Map<String, dynamic>> loadBehaviorKnowledge() async {
    if (_behaviorKnowledge == null) {
      final jsonString = await rootBundle.loadString('assets/knowledge/behavior_knowledge_base.json');
      _behaviorKnowledge = json.decode(jsonString);
    }
    return _behaviorKnowledge!;
  }
}
