import 'dart:async';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import '../core/agent_base.dart' as core;

class GemmaService {
  static GemmaService? _instance;
  static GemmaService get instance => _instance ??= GemmaService._();
  
  GemmaService._();
  
  InferenceModel? _model;
  InferenceChat? _chat;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize({List<core.Tool>? tools}) async {
    if (_isInitialized) return;
    
    try {
      // Initialize the model with Gemma IT model
      _model = await FlutterGemmaPlugin.instance.createModel(
        modelType: ModelType.gemmaIt,
        maxTokens: 4096,
      );
      
      // Create chat with tools if provided
      _chat = await _model!.createChat(
        tools: tools != null ? _convertToolsToGemmaFormat(tools) : [],
        supportsFunctionCalls: tools != null && tools.isNotEmpty,
      );
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Gemma model: $e');
    }
  }
  
  Future<void> updateTools(List<core.Tool> tools) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemma service not initialized');
    }
    
    // Create new chat with updated tools
    _chat = await _model!.createChat(
      tools: _convertToolsToGemmaFormat(tools),
      supportsFunctionCalls: tools.isNotEmpty,
    );
  }
  
  Stream<ModelResponse> processMessage(String message) async* {
    if (!_isInitialized || _chat == null) {
      throw Exception('Gemma service not initialized');
    }
    
    await _chat!.addQuery(Message.text(text: message, isUser: true));
    
    await for (final response in _chat!.generateChatResponseAsync()) {
      yield response;
    }
  }
  
  Future<String> processMessageSync(String message) async {
    if (!_isInitialized || _chat == null) {
      throw Exception('Gemma service not initialized');
    }
    
    await _chat!.addQuery(Message.text(text: message, isUser: true));
    final response = await _chat!.generateChatResponse();
    
    if (response is TextResponse) {
      return response.token;
    } else if (response is FunctionCallResponse) {
      return 'Function call: ${response.name}(${response.args})';
    }
    
    return 'Unknown response type';
  }
  
  List<Tool> _convertToolsToGemmaFormat(List<core.Tool> tools) {
    return tools.map((tool) => Tool(
      name: tool.name,
      description: tool.description,
      parameters: tool.parameters,
    )).toList();
  }
  
  void dispose() {
    _chat = null;
    _model = null;
    _isInitialized = false;
  }
}
