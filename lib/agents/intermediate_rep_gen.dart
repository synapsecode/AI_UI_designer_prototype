import 'package:ai_ui_designer/services/agent_blueprint.dart';

const String kIntermediateRepGenSystemPrompt = """
You are an expert at converting API Responses into a JSON schema tree.
When you get a given JSON response, I want you to breakit down and recombine it in the form of a UI schema like
[{
    "type": "column",
    "elements": [
      {
        "type": "row",
        "elements": [
          {
            "type": "image",
            "src": "<https://reqres.in/img/faces/7-image.jpg>",
            "shape": "circle",
            "width": "60",
            "height": "60"
          },
          {
            "type": "column",
            "elements": [
              {
                "type": "text",
                "data": "Michael Lawson",
                "font": "segoe-ui",
                "color": "blue"
              },
              {
                "type": "text",
                "data": "michael.lawson@reqres.in",
                "font": "segoe-ui",
                "color": "gray"
              }
            ]
          }
        ]
      },
      ....
  }]

  make sure to only return VALID JSON and keep it inline with the input.
  DO NOT START OR END THE RESPONSE WITH ANYTHING ELSE. I WANT PURE JSON OUTPUT
  """;

class IntermediateRepresentationGen extends APIDashAIAgent {
  @override
  String get agentName => 'INTERMEDIATE_REP_GEN';

  @override
  String getSystemPrompt() {
    return kIntermediateRepGenSystemPrompt;
  }

  @override
  Future<bool> validator(String aiResponse) async {
    //Add any specific validations here as needed
    return true;
  }

  @override
  Future outputFormatter(String validatedResponse) async {
    validatedResponse = validatedResponse
        .replaceAll('```json', '')
        .replaceAll('```json\n', '')
        .replaceAll('```', '');
    return {
      'INTERMEDIATE_REPRESENTATION': validatedResponse,
    };
  }
}
