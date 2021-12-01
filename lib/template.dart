import 'package:flutter/material.dart';
import 'global.dart';

void main() {
  runApp(Template(null, null));
}

class Template extends StatefulWidget {
  final context, string;
  Template(this.context, this.string);

  @override
  TemplateState createState() => TemplateState();
}

class TemplateState extends State<Template> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Container()));
  }
}
