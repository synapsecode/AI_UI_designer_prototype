import 'dart:convert';
import 'dart:math';
import 'package:ai_ui_designer/agents/component_gen.dart';
import 'package:ai_ui_designer/agents/component_modifier.dart';
import 'package:ai_ui_designer/extensions/miscextensions.dart';
import 'package:ai_ui_designer/extensions/textextensions.dart';
import 'package:ai_ui_designer/home.dart';
import 'package:ai_ui_designer/services/apidash_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  bool buildingUI = false;

  String generatedCode = "";

  String webViewKey = 'INITIAL';

  @override
  void initState() {
    super.initState();
    generatedCode = widget.generatedCode;
    Future.delayed(Duration(milliseconds: 200), () {
      buildUI();
    });
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
                            if (buildingUI) ...[
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.amber),
                                  ).center().addUniformMargin(20),
                                  Text('Re-Building UI').color(Colors.white54)
                                ],
                              ).center()
                            ] else
                              ...[],
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
                        if (loading) ...[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.amber),
                              ).center().addUniformMargin(20),
                              Text('Re-Generating Code').color(Colors.white54)
                            ],
                          ).center().expanded()
                        ] else ...[
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

  buildUI() async {
    setState(() {
      buildingUI = true;
    });

    final res = await http.post(
      Uri.parse('http://127.0.0.1:5152/build'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'code': base64.encode(utf8.encode(generatedCode))}),
    );
    setState(() {
      buildingUI = false;
    });
    if (res.statusCode == 200) {
      Future.delayed(Duration(milliseconds: 400), () {
        for (int i = 0; i < 5; i++) {
          setState(() {
            webViewKey = Random().nextInt(499999999).toString();
          });
        }
      });
    } else {
      print("BUILD_FAILED");
      return;
    }
  }

  process() async {
    setState(() {
      loading = true;
    });
    final componentModifierBot = ComponentModifierBot();
    final ans = await APIDashAIService.callAgent(
      componentModifierBot,
      query:
          "ORIGINAL CODE: ```${widget.generatedCode}```\n\nMODIFICATIONS REQUESTED: ```${modificationC.value.text}```",
    );
    setState(() {
      loading = false;
    });
    setState(() {
      generatedCode = ans['MODIFIED_CODE'];
    });
    Future.delayed(Duration(milliseconds: 100), () {
      buildUI();
    });
  }
}
