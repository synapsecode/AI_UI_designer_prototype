import 'package:ai_ui_designer/agents/intermediate_rep_gen.dart';
import 'package:ai_ui_designer/agents/semantic_analyser.dart';
import 'package:ai_ui_designer/extensions/miscextensions.dart';
import 'package:ai_ui_designer/extensions/textextensions.dart';
import 'package:ai_ui_designer/pages/resp_analyser.dart';
import 'package:ai_ui_designer/services/apidash_ai_service.dart';
import 'package:flutter/material.dart';

class LLMKeyStore {
  static String? API_KEY;
  static LLMProvider? provider;
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _jsonController = TextEditingController();

  bool useLLMProvider = true;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 1, 36),
      appBar: AppBar(
        title: Text('AI UI Designer'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: useLLMProvider,
                onChanged: (value) {
                  setState(() {
                    useLLMProvider = value!;
                  });
                  if (!useLLMProvider) {
                    print("Resetting LLMKeyStore");
                    LLMKeyStore.API_KEY = null;
                    LLMKeyStore.provider = null;
                  }
                },
              ),
              Text("Use Custom LLM Provider instead of ollama")
                  .color(Colors.white),
            ],
          ),
          if (useLLMProvider) ...[
            Container(
              height: 100,
              child: Row(
                children: [
                  DropdownButton<LLMProvider>(
                    value: LLMKeyStore.provider,
                    isExpanded: true,
                    onChanged: (LLMProvider? newValue) {
                      setState(() {
                        LLMKeyStore.provider = newValue!;
                      });
                    },
                    dropdownColor: const Color.fromARGB(255, 12, 1, 23),
                    items: LLMProvider.values.map((LLMProvider provider) {
                      return DropdownMenuItem<LLMProvider>(
                        value: provider,
                        child: Text(provider.name.toUpperCase())
                            .color(Colors.white),
                      );
                    }).toList(),
                  ).expanded(flex: 1),
                  SizedBox(width: 10),
                  TextField(
                    onChanged: (value) => setState(() {
                      LLMKeyStore.API_KEY = value;
                    }),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter your API key",
                    ),
                  ).expanded(flex: 7),
                ],
              ),
            ),

            /// Dropdown to select LLM Provider
          ],
          SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter JSON here...',
              ),
            ),
          ),
          SizedBox(height: 16),
          if (loading) ...[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ).center()
          ] else ...[
            ElevatedButton(
              onPressed: process,
              child: Text(
                'Generate Semantic Analysis & Intermediate Representation',
              ),
            ),
          ],
        ],
      ).addUniformMargin(100),
    );
  }

  process() async {
    setState(() {
      loading = true;
    });
    //call the semantic analyser bot & IRGen bot parallelly
    final responseSemanticAnalyserBot = ResponseSemanticAnalyser();
    final responseIRGenBot = IntermediateRepresentationGen();
    Future.wait([
      APIDashAIService.callAgent(
        responseSemanticAnalyserBot,
        query: _jsonController.value.text,
      ),
      APIDashAIService.callAgent(
        responseIRGenBot,
        query: _jsonController.value.text,
      ),
    ]).then((x) {
      final sa = x[0];
      final ir = x[1];
      if (sa == null || ir == null) {
        print('UI_GENERATION_FAILED');
        return;
      }
      setState(() {
        loading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RespAnalyser(
            intermediateRepresentation: ir['INTERMEDIATE_REPRESENTATION'],
            semanticAnalysis: sa['SEMANTIC_ANALYSIS'],
            apiResponse: _jsonController.value.text,
          ),
        ),
      );
    });
  }
}
