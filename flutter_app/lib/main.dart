import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Hello World Executor')),
        body: Center(child: BinaryRunner()),
      ),
    );
  }
}

class BinaryRunner extends StatefulWidget {
  @override
  _BinaryRunnerState createState() => _BinaryRunnerState();
}

class _BinaryRunnerState extends State<BinaryRunner> {
  String _output = '';
  bool _isPrepared = false;

  @override
  void initState() {
    super.initState();
    _prepareBinaries();
  }

  Future<void> _prepareBinaries() async {
    final appDir = await getApplicationDocumentsDirectory();
    final platform = Platform.isAndroid ? 'android' : 'linux';
    final binaries = ['hello-c', 'hello-cpp', 'hello-rust', 'hello-go'];

    for (var binary in binaries) {
      final file = File('${appDir.path}/$binary');
      if (!await file.exists()) {
        final data = await rootBundle.load('assets/$platform/$binary');
        await file.writeAsBytes(data.buffer.asUint8List());
        await Process.run('chmod', ['+x', file.path]);
      }
    }
    setState(() => _isPrepared = true);
  }

  Future<void> _runBinary(String name) async {
    final appDir = await getApplicationDocumentsDirectory();
    final process = await Process.run('${appDir.path}/$name', []);
    setState(() {
      _output = '${process.stdout}\n${process.stderr}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          children: ['C', 'C++', 'Rust', 'Go'].map((lang) {
            return ElevatedButton(
              onPressed: _isPrepared ? () => _runBinary('hello-${lang.toLowerCase()}') : null,
              child: Text('Run $lang'),
            );
          }).toList(),
        ),
        Expanded(child: SingleChildScrollView(child: Text(_output))),
      ],
    );
  }
}
