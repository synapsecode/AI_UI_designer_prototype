import 'dart:io';

class APIDashOllamaService {
  static Future<bool> checkAvailability() async {
    try {
      final result =
          await Process.run('curl', ['http://localhost:11434/api/tags']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}
