import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatResponse {
  const AiChatResponse({
    required this.text,
    required this.isEmergency,
  });

  final String text;
  final bool isEmergency;
}

class AIService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _apiEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  static const String _systemPrompt =
      'You are a medical AI assistant specialized in stroke and muscle '
      'atrophy patients. Ask about symptoms clearly, evaluate severity '
      '(mild/moderate/severe), give practical advice, never diagnose, '
      'always recommend consulting the doctor. In emergencies tell the '
      'patient to call ambulance immediately. Reply in the same language '
      'the patient uses.';

  Future<AiChatResponse> sendMessage(String message) async {
    final isEmergency = _detectEmergency(message);

    if (_apiKey.isEmpty) {
      return AiChatResponse(
        text: 'Groq API key is missing. Run the app with --dart-define=GROQ_API_KEY=your_key.',
        isEmergency: isEmergency,
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = jsonResponse['choices'] as List<dynamic>;
        
        if (choices.isNotEmpty) {
          final message = choices[0]['message']['content'] as String;
          return AiChatResponse(
            text: message.trim(),
            isEmergency: isEmergency,
          );
        }
      }

      return AiChatResponse(
        text: 'I could not generate a response. Please consult your doctor.',
        isEmergency: isEmergency,
      );
    } catch (e) {
      return AiChatResponse(
        text: 'Error communicating with AI service. Please consult your doctor.',
        isEmergency: isEmergency,
      );
    }
  }

  bool _detectEmergency(String message) {
    final normalized = message.toLowerCase().replaceAll("can't", 'cant');
    const keywords = <String>[
      'شلل',
      'تنميل مفاجئ',
      'صعوبة كلام',
      'صداع شديد مفاجئ',
      'فقدان وعي',
      'اغماء',
      'عمى مفاجئ',
      'دوخة شديدة',
      'تشنج',
      'paralysis',
      'sudden numbness',
      'cant speak',
      'severe headache',
      'unconscious',
      'seizure',
    ];

    return keywords.any((keyword) => normalized.contains(keyword));
  }
}
