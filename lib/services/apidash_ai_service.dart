import 'package:ai_ui_designer/services/agent_blueprint.dart';
import 'package:ai_ui_designer/services/llm_services.dart';

enum LLMProvider { chatgpt, claude, gemini }

typedef TCustomAPIKEY = (LLMProvider provider, String key);

class APIDashAIService {
  static Future<TCustomAPIKEY?> _getUserCustomAPIKey() async {
    return null;
    // return (LLMProvider.gemini, '...');
  }

  static Future<String?> _call_ollama({
    required String systemPrompt,
    required String input,
  }) async {
    return await APIDashOllamaService.ollama(systemPrompt, input);
  }

  static Future<String?> _call_provider({
    required LLMProvider provider,
    required String apiKey,
    required String systemPrompt,
    required String input,
  }) async {
    switch (provider) {
      case LLMProvider.gemini:
        return await APIDashCustomLLMService.gemini(
            systemPrompt, input, apiKey);
      case LLMProvider.chatgpt:
        return await APIDashCustomLLMService.chatgpt(
            systemPrompt, input, apiKey);
      case LLMProvider.claude:
        return await APIDashCustomLLMService.claude(
            systemPrompt, input, apiKey);
      default:
        print('PROVIDER_UNIMPLEMENTED');
        return null;
    }
  }

  static Future<String?> _orchestrator(
      APIDashAIAgent agent, String input) async {
    final sP = agent.getSystemPrompt();
    final customKey = await _getUserCustomAPIKey();
    //Implement any Rate limiting logic as needed
    if (customKey == null) {
      //Use local ollama implementation
      return await _call_ollama(systemPrompt: sP, input: input);
    } else {
      //Use LLMProvider implementation
      return await _call_provider(
        provider: customKey.$1,
        apiKey: customKey.$2,
        systemPrompt: sP,
        input: input,
      );
    }
  }

  static Future<dynamic> _governor(APIDashAIAgent agent, String input) async {
    int RETRY_COUNT = 0;
    List<int> backoffDelays = [200, 400, 800, 1600, 3200];
    do {
      try {
        final res = await _orchestrator(agent, input);
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

  static Future<dynamic> callAgent(APIDashAIAgent agent, String input) async {
    return await _governor(agent, input);
  }
}
