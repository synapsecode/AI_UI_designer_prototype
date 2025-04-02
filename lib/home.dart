import 'package:ai_ui_designer/extensions/miscextensions.dart';
import 'package:ai_ui_designer/services/apidash_ai_service.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _jsonController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 1, 36),
      appBar: AppBar(
        title: Text('AI UI Designer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter JSON here...',
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // final res = await APIDashAIService.call_provider(
              //   provider: LLMProvider.gemini,
              //   apiKey: '.lll',
              //   systemPrompt:
              //       'You are an expert at understanding API response structures. When i provide a sample JSON response, Please give me a semantic analysis about it.',
              //   input: _jsonController.value.text,
              // );
              // print(res);

              final res = await APIDashAIService.call_ollama(
                systemPrompt:
                    'You are an expert at understanding API response structures. When i provide a sample JSON response, Please give me a semantic analysis about it.',
                input: _jsonController.value.text,
              );
              print(res);
            },
            child: Text('Generate UI'),
          ),
        ],
      ).addUniformMargin(100),
    );
  }
}
