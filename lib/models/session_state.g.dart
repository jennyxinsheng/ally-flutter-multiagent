// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionState _$SessionStateFromJson(Map<String, dynamic> json) => SessionState(
  userName: json['userName'] as String?,
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => Child.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  interactionHistory:
      (json['interactionHistory'] as List<dynamic>?)
          ?.map((e) => Interaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  notes: json['notes'] as Map<String, dynamic>? ?? const {},
  currentAgent: json['currentAgent'] as String?,
);

Map<String, dynamic> _$SessionStateToJson(SessionState instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'children': instance.children,
      'interactionHistory': instance.interactionHistory,
      'notes': instance.notes,
      'currentAgent': instance.currentAgent,
    };

Child _$ChildFromJson(Map<String, dynamic> json) => Child(
  name: json['name'] as String,
  age: json['age'] as String?,
  preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ChildToJson(Child instance) => <String, dynamic>{
  'name': instance.name,
  'age': instance.age,
  'preferences': instance.preferences,
};

Interaction _$InteractionFromJson(Map<String, dynamic> json) => Interaction(
  message: json['message'] as String,
  response: json['response'] as String,
  agent: json['agent'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$InteractionToJson(Interaction instance) =>
    <String, dynamic>{
      'message': instance.message,
      'response': instance.response,
      'agent': instance.agent,
      'timestamp': instance.timestamp.toIso8601String(),
    };
