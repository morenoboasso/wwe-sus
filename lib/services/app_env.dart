import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static const String _geminiKeyConst = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _aiUserConst = String.fromEnvironment('AI_USER_ID', defaultValue: '');
  static const String _modelConst = String.fromEnvironment('GEMINI_MODEL', defaultValue: '');

  static String get geminiKey {
    if (_geminiKeyConst.isNotEmpty) return _geminiKeyConst;
    if (dotenv.isInitialized) {
      final value = dotenv.env['GEMINI_API_KEY'];
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  static String get aiUserId {
    if (_aiUserConst.isNotEmpty) return _aiUserConst;
    if (dotenv.isInitialized) {
      final value = dotenv.env['AI_USER_ID'];
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  static String get geminiModel {
    if (_modelConst.isNotEmpty) return _modelConst;
    if (dotenv.isInitialized) {
      final value = dotenv.env['GEMINI_MODEL'];
      if (value != null && value.isNotEmpty) return value;
    }
    return 'gemini-1.5-flash-latest';
  }
}
