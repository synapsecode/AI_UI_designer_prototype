import 'package:ai_ui_designer/services/agent_blueprint.dart';

const String kComponentModSystemPrompt = """
You are an expert at Modifying Existing code to match the needs of the client. You will get the code as well as the client's demands
as input. Provide correct code with the necessary modifications as output.
DO NOT CHANGE ANYTHING UNLESS SPECIFICALLY ASKED TO
ONLY CODE NOTHIGN ELSE. DO NOT START OR END WITH TEXT, ONLY CODE.
  """;

class ComponentModifierBot extends APIDashAIAgent {
  @override
  String get agentName => 'COMPONENT_MODIFIER';

  @override
  String getSystemPrompt() {
    return kComponentModSystemPrompt;
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
      'MODIFIED_CODE': validatedResponse,
    };
  }
}
