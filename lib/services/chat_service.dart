import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ayurvedic remedies database
  final Map<String, Map<String, dynamic>> _ayurvedicRemedies = {
    'fever': {
      'name': 'Fever',
      'remedies': [
        'Drink tulsi (holy basil) tea with ginger and honey',
        'Take 1 teaspoon of turmeric powder with warm milk',
        'Apply sandalwood paste on forehead to reduce temperature',
        'Consume giloy juice twice daily',
      ],
      'precautions': [
        'Rest adequately and avoid physical exertion',
        'Stay hydrated with warm water and herbal teas',
        'Avoid cold drinks and heavy foods',
      ],
    },
    'cough': {
      'name': 'Cough & Cold',
      'remedies': [
        'Mix 1 tsp honey with 1/2 tsp ginger juice, take twice daily',
        'Drink warm water with turmeric and black pepper',
        'Chew 2-3 tulsi leaves every morning',
        'Inhale steam with eucalyptus oil',
      ],
      'precautions': [
        'Avoid cold and fried foods',
        'Keep yourself warm',
        'Get adequate sleep',
      ],
    },
    'headache': {
      'name': 'Headache',
      'remedies': [
        'Apply paste of sandalwood or rosemary oil on forehead',
        'Drink ginger tea with a pinch of cardamom',
        'Massage forehead with peppermint oil',
        'Practice deep breathing and relaxation',
      ],
      'precautions': [
        'Avoid loud noises and bright lights',
        'Stay hydrated',
        'Take breaks from screen time',
      ],
    },
    'digestion': {
      'name': 'Indigestion',
      'remedies': [
        'Drink warm water with lemon and honey in morning',
        'Chew fennel seeds after meals',
        'Take 1 tsp of ginger juice with rock salt',
        'Drink buttermilk with roasted cumin powder',
      ],
      'precautions': [
        'Avoid overeating and late dinners',
        'Eat slowly and chew properly',
        'Avoid drinking water immediately after meals',
      ],
    },
    'stress': {
      'name': 'Stress & Anxiety',
      'remedies': [
        'Practice yoga and meditation daily',
        'Drashwort arishta twice daily with warm water',
        'Massage scalp with brahmi oil',
        'Drink warm milk with ashwagandha powder at night',
      ],
      'precautions': [
        'Maintain regular sleep schedule',
        'Avoid excessive caffeine',
        'Practice deep breathing exercises',
      ],
    },
  };

  // Home remedies database
  final Map<String, Map<String, dynamic>> _homeRemedies = {
    'fever': {
      'name': 'Fever',
      'remedies': [
        'Take rest and stay hydrated with water and electrolytes',
        'Use cold compress on forehead and wrists',
        'Take paracetamol as directed (consult doctor for dosage)',
        'Drink warm soups and broths',
      ],
      'when_to_see_doctor': 'If fever persists beyond 3 days or exceeds 103°F',
    },
    'cough': {
      'name': 'Cough & Cold',
      'remedies': [
        'Gargle with warm salt water',
        'Drink warm honey lemon water',
        'Use humidifier in your room',
        'Take over-the-counter cough syrup as directed',
      ],
      'when_to_see_doctor': 'If cough persists beyond 2 weeks or breathing difficulties occur',
    },
    'headache': {
      'name': 'Headache',
      'remedies': [
        'Rest in a dark, quiet room',
        'Apply cold or warm compress to forehead',
        'Massage temples and neck muscles',
        'Stay hydrated and avoid triggers like strong smells',
      ],
      'when_to_see_doctor': 'For severe, sudden headaches or accompanied by vision changes',
    },
    'digestion': {
      'name': 'Stomach Issues',
      'remedies': [
        'Drink peppermint or chamomile tea',
        'Eat small, bland meals (BRAT diet: Bananas, Rice, Applesauce, Toast)',
        'Stay hydrated with electrolyte solutions',
        'Avoid spicy, fatty, or dairy foods',
      ],
      'when_to_see_doctor': 'If symptoms persist beyond 48 hours or severe pain occurs',
    },
  };

  // Analyze symptoms and suggest remedies
  Future<Map<String, dynamic>> analyzeSymptoms(List<String> symptoms) async {
    // Simple symptom matching - can be enhanced with ML
    final matchedConditions = <String, int>{};

    for (final symptom in symptoms) {
      for (final condition in _ayurvedicRemedies.keys) {
        if (_matchesSymptom(symptom, condition)) {
          matchedConditions[condition] = (matchedConditions[condition] ?? 0) + 1;
        }
      }
    }

    // Sort by match count
    final sortedConditions = matchedConditions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedConditions.isEmpty) {
      return {
        'suggestedCondition': 'Unknown',
        'confidence': 0,
        'ayurvedicRemedies': [],
        'homeRemedies': [],
        'message': 'No specific remedies found for your symptoms. Please consult a doctor.',
      };
    }

    final topCondition = sortedConditions.first.key;
    final confidence = (sortedConditions.first.value / symptoms.length) * 100;

    return {
      'suggestedCondition': _ayurvedicRemedies[topCondition]!['name'],
      'confidence': confidence.round(),
      'ayurvedicRemedies': _ayurvedicRemedies[topCondition]!['remedies'] ?? [],
      'ayurvedicPrecautions': _ayurvedicRemedies[topCondition]!['precautions'] ?? [],
      'homeRemedies': _homeRemedies[topCondition]?['remedies'] ?? [],
      'whenToSeeDoctor': _homeRemedies[topCondition]?['when_to_see_doctor'] ?? 'If symptoms persist or worsen',
      'message': _getRecommendationMessage(topCondition, confidence),
    };
  }

  bool _matchesSymptom(String symptom, String condition) {
    final symptomWords = symptom.toLowerCase().split(' ');
    final conditionWords = condition.toLowerCase().split(' ');
    
    for (final sWord in symptomWords) {
      for (final cWord in conditionWords) {
        if (sWord.contains(cWord) || cWord.contains(sWord)) {
          return true;
        }
      }
    }
    return false;
  }

  String _getRecommendationMessage(String condition, double confidence) {
    if (confidence > 70) {
      return 'Based on your symptoms, we recommend trying these remedies. If symptoms persist, consult a healthcare professional.';
    } else if (confidence > 40) {
      return 'Your symptoms may match this condition. These remedies might help, but monitor your symptoms closely.';
    } else {
      return 'These are general suggestions. For accurate diagnosis, please consult a doctor.';
    }
  }

  // Save chat conversation
  Future<void> saveChatConversation({
    required String userId,
    required List<Map<String, dynamic>> messages,
    required String suggestedCondition,
    required int confidence,
  }) async {
    try {
      await _firestore.collection('chat_sessions').add({
        'userId': userId,
        'messages': messages,
        'suggestedCondition': suggestedCondition,
        'confidence': confidence,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to save chat: $e');
    }
  }

  // Get chat history for user
  Stream<QuerySnapshot> getChatHistory(String userId) {
    return _firestore
        .collection('chat_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get all available symptoms for auto-suggest
  List<String> getAvailableSymptoms() {
    return _ayurvedicRemedies.keys.toList();
  }

  // Get emergency symptoms that require immediate attention
  List<String> getEmergencySymptoms() {
    return [
      'chest pain',
      'difficulty breathing',
      'severe bleeding',
      'sudden weakness',
      'loss of consciousness',
      'severe headache',
      'high fever with rash',
    ];
  }

  // Check if symptoms require emergency attention
  bool requiresEmergencyAttention(List<String> symptoms) {
    final emergencySymptoms = getEmergencySymptoms();
    for (final symptom in symptoms) {
      for (final emergency in emergencySymptoms) {
        if (symptom.toLowerCase().contains(emergency)) {
          return true;
        }
      }
    }
    return false;
  }
}