import 'package:flutter/material.dart';

import 'demo.dart';
import 'equations.dart';
import 'feature.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Math Demo v0.2.0',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Flutter Math Demo v0.2.0',
              ),
              bottom: const TabBar(tabs: [
                Text('Interactive Demo'),
                Text('Equation Samples'),
                Text('Supported Features'),
              ]),
            ),
            body: const TabBarView(children: [
              DemoPage(),
              EquationsPage(),
              FeaturePage(),
            ]),
          ),
        ),
      );
}
