import 'package:ai_ui_designer/home.dart';
import 'package:flutter/material.dart';
import 'package:stac/stac.dart' as stac;

void main() async {
  await stac.Stac.initialize();
  runApp(const AIUIDesignerPrototype());
}

class AIUIDesignerPrototype extends StatelessWidget {
  const AIUIDesignerPrototype({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI UI Designer Prototype',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 34, 1, 91)),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }
}
