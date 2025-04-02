import 'package:ai_ui_designer/agents/component_gen.dart';
import 'package:ai_ui_designer/agents/component_modifier.dart';
import 'package:ai_ui_designer/extensions/miscextensions.dart';
import 'package:ai_ui_designer/extensions/textextensions.dart';
import 'package:ai_ui_designer/home.dart';
import 'package:ai_ui_designer/services/apidash_ai_service.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_eval/flutter_eval.dart';

class UIPreviewer extends StatefulWidget {
  final String generatedCode;
  const UIPreviewer({
    super.key,
    required this.generatedCode,
  });

  @override
  State<UIPreviewer> createState() => _UIPreviewerState();
}

class _UIPreviewerState extends State<UIPreviewer> {
  TextEditingController modificationC = TextEditingController();
  double panelWidthRatio = 0.5;
  bool loading = false;

  String generatedCode = "";

  @override
  void initState() {
    super.initState();
    generatedCode = widget.generatedCode;
    _compileAndRun(sampleCode, 'Sample Preview!');
  }

  Widget? previewWidget = SizedBox();

  String sampleCode = '''
    import 'package:flutter/material.dart';
    
    class PreviewWidget extends StatelessWidget {
      final String text;
      PreviewWidget(this.text);
      
      @override
      Widget build(BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.green,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        );
      }
    }
  ''';

  void _compileAndRun(String code, String argument) {
    try {
      // Step 1: Set up the compiler
      final compiler = Compiler();
      compiler.addPlugin(flutterEvalPlugin); // Add Flutter support

      // Step 2: Compile the code
      final program = compiler.compile({
        'example': {
          'main.dart': code,
        }
      });

      // Step 3: Set up the runtime
      final runtime = Runtime.ofProgram(program);
      runtime.addPlugin(flutterEvalPlugin); // Enable Flutter widget execution

      // Step 4: Execute the code and get the widget
      final result = runtime.executeLib(
        'package:example/main.dart',
        'PreviewWidget.',
        [$String(argument)], // Pass arguments to the constructor
      ) as $Value;

      setState(() {
        previewWidget = result.$value as Widget;
      });
    } catch (e) {
      setState(() {
        previewWidget = null;
        print('ERROR => $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 1, 36),
      appBar: AppBar(
        title: Text('UI Previewer & Modifier'),
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  /// Left Panel - UI Preview
                  Container(
                    width: constraints.maxWidth * panelWidthRatio,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("UI Preview",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16))
                            .color(Colors.white),
                        SizedBox(height: 10),
                        Stack(
                          children: [
                            Container(
                              color: Colors.grey,
                              child: previewWidget,
                            ),
                          ],
                        ).expanded()
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

                  /// Right Panel - Code
                  Container(
                    width: constraints.maxWidth * (1 - panelWidthRatio),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Generated Code",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.copy, color: Colors.white),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: widget.generatedCode));
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
                                generatedCode,
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
          TextField(
            controller: modificationC,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter any modifications you want...',
            ),
          ).addHorizontalMargin(20),
          if (loading) ...[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ).center().addUniformMargin(20)
          ] else ...[
            Container(
              height: 80,
              child: ElevatedButton(
                onPressed: process,
                child: Text("MODIFY UI"),
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
    final componentModifierBot = ComponentModifierBot();
    final ans = await APIDashAIService.callAgent(
      componentModifierBot,
      "ORIGINAL CODE: ```${widget.generatedCode}```\n\nMODIFICATIONS REQUESTED: ```${modificationC.value.text}```",
    );
    setState(() {
      loading = false;
    });
    setState(() {
      generatedCode = ans['MODIFIED_CODE'];
      _compileAndRun(sampleCode, 'Modified Preview!');
    });
  }
}
