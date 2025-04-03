import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ollama_dart/ollama_dart.dart';

class APIDashOllamaService {
  static Future<String?> ollama(
    String systemPrompt,
    String input, [
    String model = 'llama3',
  ]) async {
    //check Ollama Avaiability
    final result =
        await Process.run('curl', ['http://localhost:11434/api/tags']);
    if (result.exitCode != 0) {
      print('OLLAMA_NOT_ACTIVE');
      return null;
    }

    final inpS = input == '' ? '' : '\nProvided Inputs:$input';
    final client = OllamaClient();
    final generated = await client.generateCompletion(
      request: GenerateCompletionRequest(
        model: model,
        prompt: "$systemPrompt$inpS",
      ),
    );
    return generated.response;
  }
  //Future ollama enhancements can go here
}

class APIDashCustomLLMService {
  static Future<String?> gemini(
    String systemPrompt,
    String input,
    String apiKey,
  ) async {
    final inpS = input == '' ? '' : '\nProvided Inputs:$input';
    String combinedInput = "$systemPrompt$inpS";
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            "parts": [
              {"text": combinedInput}
            ]
          }
        ]
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    } else {
      print("GEMINI_ERROR: ${response.statusCode}");
      return null;
    }
  }

  static Future<String?> claude(
    String systemPrompt,
    String input,
    String apiKey,
  ) async {
    //IMPL PENDING
    return null;
  }

  static Future<String?> chatgpt(
    String systemPrompt,
    String input,
    String apiKey,
  ) async {
    //IMPL PENDING
    return null;
  }

  //Other Custom LLM Solutions
}
