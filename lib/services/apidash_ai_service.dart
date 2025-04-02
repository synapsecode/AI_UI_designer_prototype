import 'dart:convert';
import 'package:ai_ui_designer/services/agent_blueprint.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_dart/ollama_dart.dart';

enum LLMProvider { chatgpt, claude, gemini }

class APIDashAIService {
  static Future<(LLMProvider provider, String key)?>
      getUserCustomAPIKey() async {
    return (LLMProvider.gemini, '...');
  }

  static Future<String?> call_ollama({
    required String systemPrompt,
    required String input,
  }) async {
    String ollamaInput = "$systemPrompt\\nInput:$input";
    final client = OllamaClient();
    final generated = await client.generateCompletion(
      request: GenerateCompletionRequest(
        model: 'llama3',
        prompt: ollamaInput,
      ),
    );
    return generated.response;
  }

  static Future<String?> call_provider({
    required LLMProvider provider,
    required String apiKey,
    required String systemPrompt,
    required String input,
  }) async {
    String combinedInput = "$systemPrompt\\nInput:$input";
    switch (provider) {
      case LLMProvider.gemini:
        {
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
      //Similar Implementations for other Providers
      default:
        return null;
    }
  }

  static Future<String?> orchestrator(APIDashAIAgent agent) async {
    final sP = agent.getSystemPrompt();
    final iP = await agent.getInput();
    final customKey = await getUserCustomAPIKey();
    //Implement any Rate limiting logic as needed
    if (customKey == null) {
      //Use local ollama implementation
      return await call_ollama(systemPrompt: sP, input: iP);
    } else {
      //Use LLMProvider implementation
      return await call_provider(
        provider: customKey.$1,
        apiKey: customKey.$2,
        systemPrompt: sP,
        input: iP,
      );
    }
  }

  static Future<dynamic> governor(APIDashAIAgent agent) async {
    int RETRY_COUNT = 0;
    List<int> backoffDelays = [200, 400, 800, 1600, 3200];
    do {
      try {
        final res = await orchestrator(agent);
        if (res == null) {
          RETRY_COUNT += 1;
        } else {
          if (await agent.validator(res)) {
            return agent.outputFormatter(res);
          } else {
            RETRY_COUNT += 1;
          }
        }
      } catch (e) {
        print(e);
      }
      // Exponential Backoff
      if (RETRY_COUNT < backoffDelays.length) {
        await Future.delayed(Duration(
          milliseconds: backoffDelays[RETRY_COUNT],
        ));
      }
      RETRY_COUNT += 1;
    } while (RETRY_COUNT < 5);
  }

  static startAgent(APIDashAIAgent agent) async {
    return await governor(agent);
  }
}
