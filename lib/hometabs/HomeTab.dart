import 'package:flutter/material.dart';
import '../global.dart';

void main() {
  runApp(HomeTab(null, null));
}

class HomeTab extends StatefulWidget {
  final context, string;
  HomeTab(this.context, this.string);

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with WidgetsBindingObserver {

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
