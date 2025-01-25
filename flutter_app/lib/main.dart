import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Binary Runner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BinaryRunnerScreen(),
    );
  }
}

class BinaryRunnerScreen extends StatefulWidget {
  const BinaryRunnerScreen({super.key});

  @override
  State<BinaryRunnerScreen> createState() => _BinaryRunnerScreenState();
}

class _BinaryRunnerScreenState extends State<BinaryRunnerScreen> {
  final Map<String, String> _binaries = {
    'C': 'hello-c',
    'C++': 'hello-cpp',
    'Rust': 'hello-rust',
    'Go': 'hello-go',
  };
  
  String _output = '';
  bool _isReady = false;
  late Directory _executableDir;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _initializeEnvironment();
  }

  Future<void> _initializeEnvironment() async {
    try {
      _executableDir = await getApplicationDocumentsDirectory();
      await _prepareBinaries();
      setState(() => _isReady = true);
    } catch (e) {
      setState(() => _output = 'Initialization failed: $e');
    }
  }

  Future<void> _prepareBinaries() async {
    final platform = Platform.isAndroid ? 'android' : 'linux';
    final assets = _binaries.values;
    
    for (int i = 0; i < assets.length; i++) {
      final name = assets.elementAt(i);
      final file = File('${_executableDir.path}/$name');
      
      if (!await file.exists()) {
        final data = await rootBundle.load('assets/$platform/$name');
        await file.writeAsBytes(data.buffer.asUint8List());
        await file.setExecutable(true);
      }
      
      setState(() => _progress = (i + 1) / assets.length);
    }
  }

  Future<void> _executeBinary(String name) async {
    if (!_isReady) return;

    setState(() => _output = 'Executing $name...\n');
    try {
      final file = File('${_executableDir.path}/$name');
      final result = await Process.run(file.path, []);

      setState(() {
        _output = '''
        === $name Output ===
        Exit code: ${result.exitCode}
        ${result.stdout.toString().trim()}
        ${result.stderr.toString().trim()}
        === End of output ===
        ''';
      });
    } catch (e) {
      setState(() => _output = 'Error executing $name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Binary Runner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isReady ? _initializeEnvironment : null,
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _isReady ? 1 : _progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _isReady ? Colors.green : Colors.blue,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _binaries.keys.map((name) {
                      return ElevatedButton(
                        onPressed: _isReady
                            ? () => _executeBinary(_binaries[name]!)
                            : null,
                        child: Text('Run $name'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _output,
                          style: const TextStyle(
                            fontFamily: 'Monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
