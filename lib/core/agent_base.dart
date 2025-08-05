import 'dart:async';

abstract class AgentBase {
  String get name;
  String get description;
  List<Tool> get tools;
  Future<String> processMessage(String message, Map<String, dynamic> context);
}

class Tool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> args) handler;

  Tool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.handler,
  });
}
