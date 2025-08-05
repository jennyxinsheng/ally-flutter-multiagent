import 'package:json_annotation/json_annotation.dart';

part 'session_state.g.dart';

@JsonSerializable()
class SessionState {
  String? userName;
  List<Child> children;
  List<Interaction> interactionHistory;
  Map<String, dynamic> notes;
  String? currentAgent;
  
  SessionState({
    this.userName,
    this.children = const [],
    this.interactionHistory = const [],
    this.notes = const {},
    this.currentAgent,
  });
  
  factory SessionState.fromJson(Map<String, dynamic> json) => _$SessionStateFromJson(json);
  Map<String, dynamic> toJson() => _$SessionStateToJson(this);
}

@JsonSerializable()
class Child {
  String name;
  String? age;
  Map<String, dynamic> preferences;
  
  Child({
    required this.name,
    this.age,
    this.preferences = const {},
  });
  
  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);
  Map<String, dynamic> toJson() => _$ChildToJson(this);
}

@JsonSerializable()
class Interaction {
  String message;
  String response;
  String agent;
  DateTime timestamp;
  
  Interaction({
    required this.message,
    required this.response,
    required this.agent,
    required this.timestamp,
  });
  
  factory Interaction.fromJson(Map<String, dynamic> json) => _$InteractionFromJson(json);
  Map<String, dynamic> toJson() => _$InteractionToJson(this);
}
