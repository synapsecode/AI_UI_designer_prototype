import 'package:ai_ui_designer/agents/intermediate_rep_gen.dart';
import 'package:ai_ui_designer/agents/semantic_analyser.dart';
import 'package:ai_ui_designer/extensions/miscextensions.dart';
import 'package:ai_ui_designer/extensions/textextensions.dart';
import 'package:ai_ui_designer/pages/resp_analyser.dart';
import 'package:ai_ui_designer/services/apidash_ai_service.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _jsonController = TextEditingController();

  bool useLLMProvider = true;
  String apiKey = "";
  LLMProvider selectedProvider = LLMProvider.gemini;

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
                },
              ),
              Text("Use Custom LLM Provider instead of ollama")
                  .color(Colors.white),
            ],
          ),
          if (useLLMProvider) ...[
            SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => apiKey = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your API key",
              ),
            ),
            SizedBox(height: 16),

            /// Dropdown to select LLM Provider
            Text("Select LLM Provider",
                    style: TextStyle(fontWeight: FontWeight.bold))
                .color(Colors.white),
            DropdownButton<LLMProvider>(
              value: selectedProvider,
              isExpanded: true,
              onChanged: (LLMProvider? newValue) {
                setState(() {
                  selectedProvider = newValue!;
                });
              },
              dropdownColor: const Color.fromARGB(255, 12, 1, 23),
              items: LLMProvider.values.map((LLMProvider provider) {
                return DropdownMenuItem<LLMProvider>(
                  value: provider,
                  child: Text(provider.name.toUpperCase()).color(Colors.white),
                );
              }).toList(),
            ),
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
