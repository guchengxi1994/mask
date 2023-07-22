import 'package:flutter/material.dart';
import 'package:mask/model.dart';
import 'package:tuple/tuple.dart';

import 'mask.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: MaskWidget(
        image: Image.asset(
          "assets/199_S.jpg",
          fit: BoxFit.fill,
        ),
        models: [
          MaskModel(
              bottomRight: const Tuple2(300, 300),
              topLeft: const Tuple2(200, 200),
              id: 0),
          MaskModel(
              bottomRight: const Tuple2(200, 200),
              topLeft: const Tuple2(100, 100),
              id: 1),
          MaskModel(
              bottomRight: const Tuple2(400, 400),
              topLeft: const Tuple2(300, 300),
              id: 2)
        ],
      ),
    );
  }
}
