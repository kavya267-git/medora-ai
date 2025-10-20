import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello! I\'m your AI health assistant. How can I help you today?',
      isBot: true,
      timestamp: DateTime.now(),
    ),
  ];
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isBot: false,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response after delay
    Future.delayed(const Duration(seconds: 1), () {
      _addBotResponse(text);
    });
  }

  void _addBotResponse(String userMessage) {
    String response = _generateResponse(userMessage.toLowerCase());
    
    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isBot: true,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
  }

  String _generateResponse(String message) {
    if (message.contains('headache') && message.contains('fever')) {
      return 'For headache with fever, I suggest:\n\n• Rest in a quiet, dark room\n• Stay hydrated with water\n• Take paracetamol if needed\n• Use a cool compress on forehead\n\nIf fever persists beyond 48 hours or is very high, please consult a doctor.';
    } else if (message.contains('cough') || message.contains('cold')) {
      return 'For cough and cold symptoms:\n\n• Drink warm fluids like herbal tea\n• Use honey and lemon for sore throat\n• Get plenty of rest\n• Use steam inhalation\n• Consider over-the-counter cough syrup\n\nIf symptoms worsen or include breathing difficulty, seek medical help.';
    } else if (message.contains('stomach') || message.contains('pain')) {
      return 'For stomach pain:\n\n• Drink clear fluids\n• Avoid solid foods initially\n• Use a heating pad\n• Try ginger tea\n• Rest and avoid strenuous activity\n\nIf pain is severe, persistent, or accompanied by fever/vomiting, see a doctor immediately.';
    } else if (message.contains('emergency') || message.contains('help')) {
      return '🚨 This sounds serious! Please use the Emergency SOS feature immediately or call your local emergency number. Your safety is the top priority.';
    } else {
      return 'I understand you\'re asking about "$message". For accurate medical advice, I recommend:\n\n1. Consulting with a healthcare professional\n2. Using our Emergency SOS if this is urgent\n3. Providing more specific symptoms for better guidance\n\nRemember, I\'m an AI assistant and cannot replace professional medical advice.';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showQuickSymptoms() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickSymptomChip(
                  text: 'Fever & Headache',
                  onTap: () => _addQuickSymptom('I have fever and headache'),
                ),
                _QuickSymptomChip(
                  text: 'Cough & Cold',
                  onTap: () => _addQuickSymptom('I have cough and cold'),
                ),
                _QuickSymptomChip(
                  text: 'Stomach Pain',
                  onTap: () => _addQuickSymptom('I have stomach pain'),
                ),
                _QuickSymptomChip(
                  text: 'Body Aches',
                  onTap: () => _addQuickSymptom('I have body aches'),
                ),
                _QuickSymptomChip(
                  text: 'Sore Throat',
                  onTap: () => _addQuickSymptom('I have sore throat'),
                ),
                _QuickSymptomChip(
                  text: 'Difficulty Breathing',
                  onTap: () => _addQuickSymptom('I have difficulty breathing'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addQuickSymptom(String symptom) {
    Navigator.pop(context);
    _messageController.text = symptom;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: _showQuickSymptoms,
            tooltip: 'Quick Symptoms',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  text: message.text,
                  isBot: message.isBot,
                  timestamp: message.timestamp,
                );
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Message Input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Describe your symptoms...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            maxLines: null,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file, size: 20),
                          onPressed: () {
                            // TODO: Add file attachment
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isBot,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBot ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isBot 
                      ? Colors.green[100]! 
                      : Colors.blue[100]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isBot) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.blue, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class _QuickSymptomChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickSymptomChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.green[800],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}