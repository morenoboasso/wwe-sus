import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'app_env.dart';

class GeminiService {
  bool get isConfigured => AppEnv.geminiKey.isNotEmpty;

  Future<String> generateContent(String prompt) async {
    if (!isConfigured) return '';

    final primary = AppEnv.geminiModel;
    final response = await _request(primary, prompt);
    final text = _extractText(response.body);
    if (text.isNotEmpty) return text;

    if (response.statusCode == 404) {
      final fallbacks = [
        'gemini-1.5-flash-latest',
        'gemini-1.5-flash-002',
      ].where((model) => model != primary).toList();

      for (final model in fallbacks) {
        final retry = await _request(model, prompt);
        final retryText = _extractText(retry.body);
        if (retryText.isNotEmpty) return retryText;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('[AI] Gemini error ${response.statusCode}: ${response.body}');
    }
    return '';
  }

  Future<_GeminiResponse> _request(String model, String prompt) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
      {'key': AppEnv.geminiKey},
    );

    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 80
        }
      }),
    );

    return _GeminiResponse(response.statusCode, response.body);
  }

  String _extractText(String body) {
    if (body.isEmpty) return '';
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      final content = candidates?.isNotEmpty == true ? candidates!.first['content'] : null;
      final parts = content is Map<String, dynamic> ? content['parts'] as List? : null;
      final text = parts?.isNotEmpty == true ? parts!.first['text'] : null;
      return text?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}

class _GeminiResponse {
  const _GeminiResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}
