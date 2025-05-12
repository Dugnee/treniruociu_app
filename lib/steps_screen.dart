import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class StepsScreen extends StatefulWidget {
  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  late Stream<StepCount>? _stepCountStream;
  late Stream<PedestrianStatus>? _pedestrianStatusStream;
  String _status = 'Unknown';
  int _steps = 0;
  bool _isListening = false;
  bool _isWeb = kIsWeb;

  @override
  void initState() {
    super.initState();
    if (!_isWeb) {
      _initPlatformState();
    }
  }

  Future<void> _initPlatformState() async {
    if (_isWeb) return;
    
    // Request activity recognition permission
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _initPedometer();
    } else {
      setState(() {
        _status = 'Permission denied';
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
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 0;
    });
  }

  // Simulated step counting for web
  void _startWebStepCounting() {
    setState(() {
      _isListening = true;
      _status = 'Walking';
    });
    
    // Simulate step counting
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isListening) {
        setState(() {
          _steps += 1;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _stopStepCounting() {
    setState(() {
      _isListening = false;
      _status = 'Stopped';
    });
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