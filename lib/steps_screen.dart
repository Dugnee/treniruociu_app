import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StepsScreen extends StatefulWidget {
  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  late Stream<StepCount>? _stepCountStream;
  late Stream<PedestrianStatus>? _pedestrianStatusStream;
  String _status = 'Neaktyvus';
  int _steps = 0;
  int _todaySteps = 0;
  bool _isListening = false;
  bool _isWeb = kIsWeb;
  static const int _goalSteps = 10000;
  late DateTime _lastUpdate;
  Timer? _saveTimer;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _lastUpdate = DateTime.now();
    if (!_isWeb) {
      _initPlatformState();
    }
    _loadTodaySteps();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTodaySteps() async {
    if (_auth.currentUser == null) return;
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('steps')
          .doc(DateFormat('yyyy-MM-dd').format(startOfDay))
          .get();

      if (doc.exists) {
        setState(() {
          _todaySteps = doc.data()?['steps'] ?? 0;
          _steps = _todaySteps;
        });
      }
    } catch (e) {
      print('Klaida kraunant žingsnius: $e');
    }
  }

  Future<void> _saveSteps() async {
    if (_auth.currentUser == null) return;
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('steps')
          .doc(DateFormat('yyyy-MM-dd').format(startOfDay))
          .set({
        'steps': _steps,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Klaida išsaugant žingsnius: $e');
    }
  }

  Future<void> _initPlatformState() async {
    if (_isWeb) return;
    
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _initPedometer();
    } else {
      setState(() {
        _status = 'Nėra leidimo';
      });
    }
  }

  void _initPedometer() {
    if (_isWeb) return;

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _pedestrianStatusStream
        ?.listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream?.listen(onStepCount).onError(onStepCountError);

    setState(() {
      _isListening = true;
    });

    // Automatiškai išsaugoti žingsnius kas 5 minutes
    _saveTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (_isListening) {
        _saveSteps();
      }
    });
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
      _todaySteps = _steps;
    });
    
    // Išsaugoti žingsnius, jei praėjo bent 1 minutė nuo paskutinio išsaugojimo
    if (DateTime.now().difference(_lastUpdate).inMinutes >= 1) {
      _saveSteps();
      _lastUpdate = DateTime.now();
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Klaida gavus būseną';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 0;
    });
  }

  void _startWebStepCounting() {
    setState(() {
      _isListening = true;
      _status = 'Vaikšto';
    });
    
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isListening) {
        setState(() {
          _steps += 1;
          _todaySteps = _steps;
        });
        
        if (DateTime.now().difference(_lastUpdate).inMinutes >= 1) {
          _saveSteps();
          _lastUpdate = DateTime.now();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _stopStepCounting() {
    setState(() {
      _isListening = false;
      _status = 'Sustabdytas';
    });
    _saveSteps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Žingsnių Sekimas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isWeb) ...[
              Icon(
                Icons.directions_walk,
                size: 100,
                color: Colors.purple,
              ),
              SizedBox(height: 20),
              Text(
                'Žingsnių skaičius:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '$_steps',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Status: $_status',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              if (!_isListening)
                ElevatedButton(
                  onPressed: _startWebStepCounting,
                  child: Text('Pradėti žingsnių sekimą'),
                )
              else
                ElevatedButton(
                  onPressed: _stopStepCounting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Sustabdyti žingsnių sekimą'),
                ),
              SizedBox(height: 10),
              Text(
                'Web versijoje žingsniai yra simuluojami',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              if (!_isListening)
                ElevatedButton(
                  onPressed: _initPlatformState,
                  child: Text('Pradėti žingsnių sekimą'),
                ),
              if (_status == 'Nėra leidimo')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Reikalingas leidimas žingsnių sekimui! Prašome suteikti leidimą per telefono nustatymus.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_isListening) ...[
                Icon(
                  Icons.directions_walk,
                  size: 100,
                  color: Colors.purple,
                ),
                SizedBox(height: 20),
                Text(
                  'Žingsnių skaičius:',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '$_steps',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                LinearProgressIndicator(
                  value: (_steps / _goalSteps).clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: Colors.purple.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                SizedBox(height: 10),
                Text(
                  'Tikslas: $_goalSteps žingsnių',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                Text(
                  'Status: $_status',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
} 