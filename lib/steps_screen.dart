import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
  int _trackingStartSteps = 0;
  int _trackingSteps = 0;
  bool _isListening = false;
  bool _isWeb = kIsWeb;
  static const int _goalSteps = 10000;
  late DateTime _lastUpdate;
  Timer? _saveTimer;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Maršruto sekimo kintamieji
  bool _tracking = false;
  List<LatLng> _route = [];
  double _distance = 0.0; // metrais
  StreamSubscription<Position>? _positionSub;
  String _locationStatus = '';
  bool _locationEnabled = true;
  double? _lastAccuracy;
  int _filteredPoints = 0;

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
    _positionSub?.cancel();
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
      if (_tracking) {
        _trackingSteps = _steps - _trackingStartSteps;
        if (_trackingSteps < 0) _trackingSteps = 0;
      }
    });
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

  // --- Maršruto sekimas ---
  Future<void> _startTracking() async {
    final locStatus = await Permission.location.status;
    setState(() {
      _locationStatus = 'Leidimo statusas: ${locStatus.toString()}';
    });
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _locationEnabled = serviceEnabled;
    });
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Vietos paslaugos (GPS) išjungtos!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Įjunkite vietos paslaugas (GPS)!')),
      );
      return;
    }
    if (!locStatus.isGranted) {
      final req = await Permission.location.request();
      setState(() {
        _locationStatus = 'Leidimo statusas: ${req.toString()}';
      });
      if (!req.isGranted) {
        setState(() {
          _locationStatus = 'Reikalingas vietos leidimas!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reikalingas vietos leidimas!')),
        );
        return;
      }
    }
    setState(() {
      _locationStatus = 'Sekama...';
      _tracking = true;
      _route = [];
      _distance = 0.0;
      _trackingStartSteps = _steps;
      _trackingSteps = 0;
      _filteredPoints = 0;
    });
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10),
    ).listen((Position pos) {
      final point = LatLng(pos.latitude, pos.longitude);
      _lastAccuracy = pos.accuracy;
      setState(() {
        if (_route.isEmpty) {
          // Pirmą tašką visada pridedam, kad žemėlapis matytųsi
          _route.add(point);
        } else {
          final last = _route.last;
          final d = Geolocator.distanceBetween(
            last.latitude, last.longitude, pos.latitude, pos.longitude);
          // GPS filtravimas: tikslumas < 20m, atstumas tarp taškų 10-30m
          if (pos.accuracy < 20 && d > 10 && d < 30) {
            _distance += d;
            _route.add(point);
          } else {
            _filteredPoints++;
          }
        }
      });
    });
  }

  void _stopTracking() {
    _positionSub?.cancel();
    setState(() {
      _tracking = false;
    });
    if (_route.isNotEmpty) {
      _saveRouteToFirestore();
    }
  }

  Future<void> _saveRouteToFirestore() async {
    if (_auth.currentUser == null) return;
    final now = DateTime.now();
    final routeData = {
      'points': _route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'distance': _distance,
      'date': now,
      'steps': _trackingSteps,
      'duration': null, // bus pridėta vėliau
    };
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('routes')
        .add(routeData);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(
        title: Text('Žingsnių Sekimas'),
      ),
      body: Column(
        children: [
          if (_locationStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _locationStatus,
                style: TextStyle(color: _locationStatus == 'Sekama...' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          if (_lastAccuracy != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text('GPS tikslumas: ${_lastAccuracy!.toStringAsFixed(1)} m, atmesta taškų: $_filteredPoints', style: TextStyle(fontSize: 12, color: Colors.grey[800])),
            ),
          // Žemėlapis viršuje
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            child: _route.isEmpty
                ? Center(child: Text('Maršrutas dar nepradėtas', style: TextStyle(color: Colors.white70)))
                : FlutterMap(
                    options: MapOptions(
                      center: _route.last,
                      zoom: 16,
                      interactiveFlags: InteractiveFlag.all,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route,
                            color: Colors.purple,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                      if (_route.isNotEmpty)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _route.first,
                              width: 40,
                              height: 40,
                              child: Icon(Icons.flag, color: Colors.green, size: 32),
                            ),
                            Marker(
                              point: _route.last,
                              width: 40,
                              height: 40,
                              child: Icon(Icons.directions_walk, color: Colors.red, size: 32),
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
          // Info ir mygtukai apačioje
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Žingsniai šiandien:', style: TextStyle(fontSize: 18, color: Colors.purple)),
                  Text('$_trackingSteps', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.purple)),
                  SizedBox(height: 16),
                  Text('Nueitas atstumas:', style: TextStyle(fontSize: 18, color: Colors.purple)),
                  Text(_formatDistance(_distance), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple)),
                  SizedBox(height: 24),
                  _tracking
                      ? ElevatedButton.icon(
                          icon: Icon(Icons.stop),
                          label: Text('Stabdyti sekimą'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: _stopTracking,
                        )
                      : ElevatedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          label: Text('Pradėti maršruto sekimą'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                          onPressed: _startTracking,
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