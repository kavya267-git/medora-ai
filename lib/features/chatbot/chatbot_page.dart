import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Namaste! I\'m your AI Health Assistant. I can help with:\n\n'
          '• Symptom analysis\n• Ayurvedic remedies\n• Home treatments\n• General health guidance\n\n'
          'Please describe your symptoms or health concern.',
      isBot: true,
      timestamp: DateTime.now(),
    ),
  ];
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Enhanced medical knowledge with authentic Ayurvedic remedies
  final Map<String, Map<String, dynamic>> _medicalKnowledge = {
    // Headache patterns
    'headache': {
      'condition': 'Headache (Shirashoola)',
      'description': 'Common headache that can be managed with Ayurvedic treatments',
      'homeRemedies': [
        'Rest in a quiet, dark room',
        'Apply cold compress to forehead',
        'Stay hydrated with warm water',
        'Massage temples gently with coconut oil',
        'Practice deep breathing exercises (Pranayama)'
      ],
      'ayurvedicRemedies': [
        'Apply paste of sandalwood (Chandana) on forehead - cooling effect',
        'Drink ginger (Adrak) tea with honey - improves circulation',
        'Nasya therapy: 2 drops of Anu Taila in each nostril',
        'Brahmi (Bacopa) powder with warm milk - calms nervous system',
        'Shirodhara: Gentle oil pouring on forehead (professional treatment)'
      ],
      'severity': 'mild',
      'doctorAdvice': 'Consult doctor if headache persists for more than 2 days'
    },
    
    'headache fever': {
      'condition': 'Headache with Fever (Jwara with Shirashoola)',
      'description': 'Could indicate viral infection or Pitta imbalance',
      'homeRemedies': [
        'Take complete rest',
        'Stay hydrated with electrolyte water',
        'Use lukewarm water sponge bath',
        'Light, easily digestible food (Khichdi)',
        'Keep room well-ventilated'
      ],
      'ayurvedicRemedies': [
        'Tulsi (Holy Basil) tea - natural antiviral properties',
        'Giloy (Guduchi) juice with warm water - boosts immunity',
        'Turmeric (Haridra) milk with honey - anti-inflammatory',
        'Coriander seed (Dhaniya) water - reduces fever',
        'Yashtimadhu (Licorice) tea - soothes throat and reduces fever'
      ],
      'severity': 'moderate',
      'doctorAdvice': 'Consult doctor immediately if fever is high (>101°F) or persists beyond 48 hours'
    },

    // Cold and cough
    'cold': {
      'condition': 'Common Cold (Pratishyaya)',
      'description': 'Kapha-Vata imbalance causing respiratory symptoms',
      'homeRemedies': [
        'Steam inhalation with eucalyptus oil',
        'Gargle with warm salt water',
        'Drink warm fluids frequently',
        'Rest and avoid cold foods',
        'Use humidifier in room'
      ],
      'ayurvedicRemedies': [
        'Sitopaladi Churna with honey - clears respiratory tract',
        'Talisadi Churna for cough and congestion',
        'Ginger (Adrak) and black pepper (Kali Mirch) tea',
        'Yashtimadhu (Licorice) for sore throat',
        'Vasa (Adhatoda Vasica) for productive cough'
      ],
      'severity': 'mild',
      'doctorAdvice': 'See doctor if symptoms worsen or breathing difficulty occurs'
    },

    'cough': {
      'condition': 'Cough (Kasa)',
      'description': 'Respiratory irritation that can be dry or productive',
      'homeRemedies': [
        'Honey and lemon warm water',
        'Stay hydrated with warm liquids',
        'Avoid cold drinks and ice cream',
        'Use throat lozenges',
        'Practice steam inhalation'
      ],
      'ayurvedicRemedies': [
        'Kantakari (Solanum Xanthocarpum) for dry cough',
        'Pushkarmool (Inula Racemosa) for chest congestion',
        'Lavang (Clove) with honey for throat irritation',
        'Tulsi (Holy Basil) and Ginger tea',
        'Chyawanprash daily for immunity'
      ],
      'severity': 'mild',
      'doctorAdvice': 'Consult doctor if cough persists beyond 1 week'
    },

    // Stomach issues
    'stomach pain': {
      'condition': 'Stomach Pain/Indigestion (Agnimandya)',
      'description': 'Digestive fire imbalance causing discomfort',
      'homeRemedies': [
        'Fasting or light diet (Khichdi)',
        'Warm water with lemon',
        'Avoid heavy, oily foods',
        'Practice light walking after meals',
        'Apply heating pad on stomach'
      ],
      'ayurvedicRemedies': [
        'Ajwain (Carom Seeds) water - improves digestion',
        'Hing (Asafoetida) in warm water - relieves gas',
        'Ginger (Adrak) juice with honey - kindles digestive fire',
        'Triphala Churna for regular bowel movement',
        'Jeera (Cumin) water for bloating'
      ],
      'severity': 'mild',
      'doctorAdvice': 'Consult doctor if pain is severe, persistent, or accompanied by fever/vomiting'
    },

    'diarrhea': {
      'condition': 'Diarrhea (Atisara)',
      'description': 'Loose motions due to digestive imbalance',
      'homeRemedies': [
        'ORS (Oral Rehydration Solution)',
        'Banana and apple diet',
        'Avoid dairy and spicy foods',
        'Rest and stay hydrated',
        'Eat small, frequent meals'
      ],
      'ayurvedicRemedies': [
        'Kutaja (Holarrhena Antidysenterica) - stops diarrhea',
        'Bilva (Aegle Marmelos) fruit pulp',
        'Pomegranate (Anar) juice with salt',
        'Isabgol (Psyllium Husk) with curd',
        'Musta (Cyperus Rotundus) for digestive recovery'
      ],
      'severity': 'moderate',
      'doctorAdvice': 'Seek medical help if diarrhea persists beyond 2 days or with high fever'
    },

    // Serious conditions
    'chest pain': {
      'condition': 'Chest Pain (Hridshoola)',
      'description': 'POTENTIALLY SERIOUS - Requires immediate medical attention',
      'homeRemedies': [
        'Sit down and rest immediately',
        'Loosen tight clothing',
        'Try to stay calm and breathe slowly',
        'Do not exert yourself'
      ],
      'ayurvedicRemedies': [
        'Arjuna (Terminalia Arjuna) - for heart health (long term)',
        'This requires emergency medical care first',
        'Do not rely on home remedies for acute chest pain'
      ],
      'severity': 'emergency',
      'doctorAdvice': '🚨 EMERGENCY: Chest pain could indicate heart issues. Call emergency services immediately!'
    },

    'breathing difficulty': {
      'condition': 'Breathing Difficulty (Shwasa)',
      'description': 'POTENTIALLY SERIOUS - Requires immediate medical attention',
      'homeRemedies': [
        'Sit upright in comfortable position',
        'Try to stay calm',
        'Use emergency SOS if alone',
        'Loosen clothing around neck'
      ],
      'ayurvedicRemedies': [
        'Vasa (Adhatoda Vasica) - for respiratory support (long term)',
        'Focus on getting professional help first',
        'Emergency care takes priority over home remedies'
      ],
      'severity': 'emergency',
      'doctorAdvice': '🚨 EMERGENCY: Breathing difficulty requires immediate medical attention. Use Emergency SOS!'
    },
  };

  void _sendMessage() {
    final String text = _messageController.text.trim();
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

    // Simulate AI thinking
    setState(() {
      _isLoading = true;
    });

    // Generate response after delay
    Future.delayed(const Duration(seconds: 1), () {
      _generateAIResponse(text.toLowerCase());
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _generateAIResponse(String userMessage) {
    Map<String, dynamic>? response;
    String matchedCondition = '';
    
    // Check for specific conditions
    for (final String keyword in _medicalKnowledge.keys) {
      if (userMessage.contains(keyword)) {
        response = _medicalKnowledge[keyword];
        matchedCondition = keyword;
        break;
      }
    }

    // Default response if no specific condition found
    response ??= {
      'condition': 'General Health Concern',
      'description': 'I understand you\'re asking about health concerns. Here are general wellness tips:',
      'homeRemedies': [
        'Maintain proper hydration with warm water',
        'Get adequate rest and sleep',
        'Eat balanced, seasonal meals',
        'Practice regular exercise and yoga'
      ],
      'ayurvedicRemedies': [
        'Practice daily meditation and Pranayama',
        'Follow seasonal routines (Ritucharya)',
        'Maintain digestive health with proper diet',
        'Get proper sleep before 10 PM (Brahma Muhurta)'
      ],
      'severity': 'mild',
      'doctorAdvice': 'For personalized medical advice, please consult with an Ayurvedic practitioner or healthcare professional'
    };

    final String botResponse = _formatResponse(response, userMessage, matchedCondition);
    
    setState(() {
      _messages.add(ChatMessage(
        text: botResponse,
        isBot: true,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
  }

  String _formatResponse(Map<String, dynamic> response, String userMessage, String matchedCondition) {
    final StringBuffer buffer = StringBuffer();
    
    buffer.write('Based on your description, here is some guidance:\n\n');
    
    buffer.write('📋 Condition: ${response['condition'] as String}\n');
    buffer.write('📝 Description: ${response['description'] as String}\n\n');
    
    // Add emoji based on severity
    final String severity = response['severity'] as String;
    final String severityEmoji = severity == 'emergency' ? '🚨' 
        : severity == 'moderate' ? '⚠️' : '💚';
    
    buffer.write('$severityEmoji Severity: ${severity.toUpperCase()}\n\n');
    
    buffer.write('🏠 Home Remedies:\n');
    final List<dynamic> homeRemedies = response['homeRemedies'] as List<dynamic>;
    for (final dynamic remedy in homeRemedies) {
      buffer.write('• ${remedy as String}\n');
    }
    
    buffer.write('\n🌿 Ayurvedic Remedies:\n');
    final List<dynamic> ayurvedicRemedies = response['ayurvedicRemedies'] as List<dynamic>;
    for (final dynamic remedy in ayurvedicRemedies) {
      buffer.write('• ${remedy as String}\n');
    }
    
    buffer.write('\n 👨‍⚕️ Medical Advice:\n${response['doctorAdvice'] as String}');
    
    // Add disclaimer
    buffer.write('\n\n---\n');
    buffer.write('Note: I am an AI assistant and not a medical doctor. '
        'This information is based on Ayurvedic texts and general knowledge. '
        'Always consult qualified Ayurvedic practitioners or doctors for proper diagnosis and treatment.');
    
    return buffer.toString();
  }

  void _scrollToBottom() {
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
                  text: 'Headache',
                  onTap: () => _addQuickSymptom('I have headache'),
                ),
                _QuickSymptomChip(
                  text: 'Cold',
                  onTap: () => _addQuickSymptom('I have cold'),
                ),
                _QuickSymptomChip(
                  text: 'Cough',
                  onTap: () => _addQuickSymptom('I have cough'),
                ),
                _QuickSymptomChip(
                  text: 'Fever',
                  onTap: () => _addQuickSymptom('I have fever'),
                ),
                _QuickSymptomChip(
                  text: 'Stomach Pain',
                  onTap: () => _addQuickSymptom('I have stomach pain'),
                ),
                _QuickSymptomChip(
                  text: 'Diarrhea',
                  onTap: () => _addQuickSymptom('I have diarrhea'),
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
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final message = _messages[index];
                  return ChatBubble(
                    text: message.text,
                    isBot: message.isBot,
                    timestamp: message.timestamp,
                  );
                } else {
                  // Loading indicator
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.medical_services, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 12),
                        Text('AI Health Assistant is thinking...'),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ),
                  );
                }
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
                          icon: const Icon(Icons.medical_services, size: 20),
                          onPressed: _showQuickSymptoms,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send Button
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
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

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
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
                color: isBot ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isBot ? const Color(0xFFBBF7D0) : const Color(0xFFBFDBFE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
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
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF166534),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}