import 'package:flutter/material.dart';
import '../agents/ally_agent.dart';

class ChatInterface extends StatefulWidget {
  final String userId;
  
  const ChatInterface({super.key, required this.userId});
  
  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  late AllyAgent _allyAgent;
  bool _isLoading = false;
  bool _isInitialized = false;
  String _initializationError = '';

  @override
  void initState() {
    super.initState();
    _allyAgent = AllyAgent(userId: widget.userId, context: context);
    _initializeAgent();
  }

  Future<void> _initializeAgent() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _allyAgent.initializeGemma();
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      
      // Add welcome message
      _addMessage(ChatMessage(
        text: "Hi! I'm Ally, your parenting assistant. I can help with sleep issues, behavior challenges, recipes, and managing your family's needs. What would you like help with today?",
        isUser: false,
        agent: 'ally_main',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      setState(() {
        _initializationError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || !_isInitialized) return;

    // Add user message
    _addMessage(ChatMessage(
      text: message,
      isUser: true,
      agent: _allyAgent.getCurrentAgentName(),
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Process message with current agent
      final response = await _allyAgent.processMessage(message, {});
      
      // Add agent response
      _addMessage(ChatMessage(
        text: response,
        isUser: false,
        agent: _allyAgent.getCurrentAgentName(),
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _addMessage(ChatMessage(
        text: "I encountered an error processing your message. Please try again. Error: $e",
        isUser: false,
        agent: _allyAgent.getCurrentAgentName(),
        timestamp: DateTime.now(),
        isError: true,
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _getAgentColor(message.agent),
              child: Text(
                _getAgentInitial(message.agent),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue[600] 
                    : message.isError 
                        ? Colors.red[100]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser && message.agent != 'ally_main')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _getAgentDisplayName(message.agent),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getAgentColor(message.agent),
                        ),
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Color _getAgentColor(String agent) {
    switch (agent) {
      case 'sleep_specialist':
        return Colors.purple;
      case 'behavior_specialist':
        return Colors.orange;
      case 'recipe_specialist':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getAgentInitial(String agent) {
    switch (agent) {
      case 'sleep_specialist':
        return 'S';
      case 'behavior_specialist':
        return 'B';
      case 'recipe_specialist':
        return 'R';
      default:
        return 'A';
    }
  }

  String _getAgentDisplayName(String agent) {
    switch (agent) {
      case 'sleep_specialist':
        return 'Sleep Specialist';
      case 'behavior_specialist':
        return 'Behavior Specialist';
      case 'recipe_specialist':
        return 'Recipe Specialist';
      default:
        return 'Ally';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationError.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ally - Parenting Assistant'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize Ally',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _initializationError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializationError = '';
                    });
                    _initializeAgent();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ally - Parenting Assistant'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_isInitialized)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'reset') {
                  _allyAgent.resetToMainAgent();
                  _addMessage(ChatMessage(
                    text: "Switched back to main assistant. How can I help you?",
                    isUser: false,
                    agent: 'ally_main',
                    timestamp: DateTime.now(),
                  ));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('Return to Main Assistant'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading && !_isInitialized)
            const LinearProgressIndicator(),
          Expanded(
            child: _isInitialized
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _buildMessage(_messages[index]),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing Ally...'),
                      ],
                    ),
                  ),
          ),
          if (_isLoading && _isInitialized)
            const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask Ally about sleep, behavior, recipes...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: _isInitialized && !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isInitialized && !_isLoading ? _sendMessage : null,
                  icon: const Icon(Icons.send),
                  color: Colors.blue[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String agent;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.agent,
    required this.timestamp,
    this.isError = false,
  });
}
