import 'package:camera/camera.dart';
import 'package:camera_ifpe/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Camera',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              await availableCameras().then((value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CameraPage(cameras: value))));
            },
            child: const Text('Take a picture'),
          ),
        ),
      ),
    );
  }
}
