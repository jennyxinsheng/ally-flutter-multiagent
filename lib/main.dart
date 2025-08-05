import 'package:flutter/material.dart';
import 'widgets/chat_interface.dart';

void main() {
  runApp(const AllyApp());
}

class AllyApp extends StatelessWidget {
  const AllyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ally - Parenting Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChatInterface(userId: 'default_user'),
      debugShowCheckedModeBanner: false,
    );
  }
}
