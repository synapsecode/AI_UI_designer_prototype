abstract class APIDashAIAgent {
  String get agentName;
  String getSystemPrompt();
  Future<String> getInput();
  Future<bool> validator(String aiResponse);
  Future<dynamic> outputFormatter(String validatedResponse);
}
