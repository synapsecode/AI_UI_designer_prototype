import 'package:ai_ui_designer/agents/component_gen.dart';
import 'package:ai_ui_designer/extensions/miscextensions.dart';
import 'package:ai_ui_designer/extensions/textextensions.dart';
import 'package:ai_ui_designer/home.dart';
import 'package:ai_ui_designer/pages/ui_preview.dart';
import 'package:ai_ui_designer/services/apidash_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RespAnalyser extends StatefulWidget {
  final String semanticAnalysis;
  final String intermediateRepresentation;
  final String apiResponse;
  const RespAnalyser({
    super.key,
    required this.semanticAnalysis,
    required this.intermediateRepresentation,
    required this.apiResponse,
  });

  @override
  State<RespAnalyser> createState() => _RespAnalyserState();
}

class _RespAnalyserState extends State<RespAnalyser> {
  double panelWidthRatio = 0.5;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 1, 36),
      appBar: AppBar(
        title: Text('Semantic Analysis & Intermediate Representation'),
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  /// Left Panel - Semantic Input
                  Container(
                    width: constraints.maxWidth * panelWidthRatio,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Semantic Analysis Output",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16))
                            .color(Colors.white),
                        SizedBox(height: 10),
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            style: TextStyle(color: Colors.white),
                            readOnly: true,
                            controller: TextEditingController(
                                text: widget.semanticAnalysis),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Resizable Divider
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        panelWidthRatio +=
                            details.primaryDelta! / constraints.maxWidth;
                        panelWidthRatio = panelWidthRatio.clamp(0.3, 0.7);
                      });
                    },
                    child: Container(
                      height: double.infinity,
                      color: const Color.fromARGB(255, 27, 27, 27),
                      child: Icons.drag_indicator_sharp
                          .toIcon(color: Colors.white),
                    ),
                  ),

                  /// Right Panel - JSON Output
                  Container(
                    width: constraints.maxWidth * (1 - panelWidthRatio),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Intermediate Representation (JSON)",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.copy, color: Colors.white),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: widget.intermediateRepresentation));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Copied to clipboard!")));
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(155, 34, 34, 34),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                widget.intermediateRepresentation,
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontFamily: "monospace",
                                ),
                              ).limitSize(double.infinity),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).expanded(),
                ],
              );
            },
          ).expanded(),
          if (loading) ...[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ).center().addUniformMargin(20)
          ] else ...[
            Container(
              height: 80,
              child: ElevatedButton(
                onPressed: process,
                child: Text("PROCEED TO UI GENERATION"),
              ).addUniformMargin(20),
            ),
          ],
        ],
      ),
    );
  }

  process() async {
    setState(() {
      loading = true;
    });
    final componentGenBot = ComponentGenBot();
    final ans = await APIDashAIService.callAgent(
      componentGenBot,
      variables: {
        'VAR_RAW_API_RESPONSE': widget.apiResponse,
        'VAR_INTERMEDIATE_REPR': widget.intermediateRepresentation,
        'VAR_SEMANTIC_ANALYSIS': widget.semanticAnalysis,
      },
    );
    setState(() {
      loading = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UIPreviewer(
          generatedCode: ans['COMPONENT_CODE'],
        ),
      ),
    );
  }
}
