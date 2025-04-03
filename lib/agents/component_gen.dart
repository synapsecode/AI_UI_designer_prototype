// import 'package:ai_ui_designer/services/agent_blueprint.dart';

// //We can use Variables as so: :VARIABLE:
// const String kComponentGenSystemPrompt =
//     """For the input Raw API Response: ```json
// :VAR_RAW_API_RESPONSE:
// ```

// You are an expert component writing agent specialized in the Flutter framework with the dart programming language.
// You are provided with a JSON UI Schema called INTERMEDIATE_REPRESENTATION.

// INTERMEDIATE_REPRESENTATION: ```json
// :VAR_INTERMEDIATE_REPR:
// ```

// You are also provided with a detailed text based Semantic analysis of what the UI is and how it should be, speicified by SEMANTIC_ANALYSIS

// SEMANTIC_ANALYSIS: ```plaintext
// :VAR_SEMANTIC_ANALYSIS:
// ```

// Use all of this data to create a nice and good looking flutter component.

// OUTPUT FORMAT:
// Since this code needs to be executed in the next step of the pipeline we need to add a Runner stub
// For example, If you have generated a Widget named Test that accepts a Map as input then your output should be something like:
// ```
// class Test extends Stateful Widget {
//   ...
// }

// class Runner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final data = :VAR_RAW_API_RESPONSE:;
//     return Test(data: data);
//   }
// }
// ```
// The Raw API Response must be passed as is to the target component
// This is done so that it can be executed in the next step

// OUTPUT RULES:
// 1. ALWAYS OUTPUT VALID & EXECUTABLE CODE ONLY
// 2. Do NOT INCLUDE ANY LEADING OR TRAILING TEXT. OUTPUT THE FLUTTER CODE ONLY enclosed in triple backticks(```)
// 3. DO NOT INCLUDE ANY flutter packages
// """;

// class ComponentGenBot extends APIDashAIAgent {
//   @override
//   String get agentName => 'COMPONENT_GEN';

//   @override
//   String getSystemPrompt() {
//     return kComponentGenSystemPrompt;
//   }

//   @override
//   Future<bool> validator(String aiResponse) async {
//     /*Potential Rules:
//     - Leading & Trailing Text
//     - Multiple Imports
//     - Incorrect Runner formatting & more
//     */

//     //Add any specific validations here as needed
//     return true;
//   }

//   @override
//   Future outputFormatter(String validatedResponse) async {
//     validatedResponse = validatedResponse
//         .replaceAll('```dart', '')
//         .replaceAll('```dart\n', '')
//         .replaceAll('```', '');
//     return {
//       'COMPONENT_CODE': validatedResponse,
//     };
//   }
// }
