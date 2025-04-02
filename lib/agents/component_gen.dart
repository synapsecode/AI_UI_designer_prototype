import 'package:ai_ui_designer/services/agent_blueprint.dart';

const String kComponentGenSystemPrompt = """
You are an expert at converting Semantic Analysis Data and a JSON-like Intermediate Representation into Standard Flutter COmponent COde.
Make sure to smartly create the flutter component using the available contextual clues. Do include consierations for pagination and so on
if the need arises.
ONLY GIVE ME THE COMPONENT CODE
DO NOT START OR END WITH ANY TEXT. Directly give me the code only.
  """;

class ComponentGenBot extends APIDashAIAgent {
  @override
  String get agentName => 'COMPONENT_GEN';

  @override
  String getSystemPrompt() {
    return kComponentGenSystemPrompt;
  }

  @override
  Future<bool> validator(String aiResponse) async {
    //Add any specific validations here as needed
    return true;
  }

  @override
  Future outputFormatter(String validatedResponse) async {
    validatedResponse = validatedResponse
        .replaceAll('```dart', '')
        .replaceAll('```dart\n', '')
        .replaceAll('```', '');
    return {
      'COMPONENT_CODE': validatedResponse,
    };
  }
}
