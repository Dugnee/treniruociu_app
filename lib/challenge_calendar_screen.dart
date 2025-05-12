import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'my_challenges_screen.dart';

class ChallengeCalendarScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic> challengeData;
  ChallengeCalendarScreen({required this.challengeId, required this.challengeData});

  @override
  State<ChallengeCalendarScreen> createState() => _ChallengeCalendarScreenState();
}

class _ChallengeCalendarScreenState extends State<ChallengeCalendarScreen> {
  late int period;
  late DateTime startDate;
  late String name;
  late String icon;
  List<bool> done = [];
  bool loading = true;
  late ConfettiController _confettiController;
  String? _motivation;

  @override
  void initState() {
    super.initState();
    period = widget.challengeData['period'] ?? 14;
    startDate = (widget.challengeData['startDate'] as Timestamp).toDate();
    name = widget.challengeData['name'] ?? '';
    icon = widget.challengeData['icon'] ?? '💪';
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('challenges')
        .doc(widget.challengeId)
        .get();
    if (doc.exists && doc.data() != null && doc.data()!['done'] != null) {
      setState(() {
        done = List<bool>.from(doc.data()!['done']);
        loading = false;
      });
    } else {
      setState(() {
        done = List.generate(period, (_) => false);
        loading = false;
      });
    }
  }

  Future<void> _updateProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('challenges')
        .doc(widget.challengeId)
        .update({'done': done});
  }

  void _onDayTap(int i) async {
    final now = DateTime.now();
    final dayDate = startDate.add(Duration(days: i));
    if (dayDate.isAfter(DateTime(now.year, now.month, now.day))) return;
    setState(() {
      done[i] = !done[i];
      _motivation = done[i]
          ? _randomMotivation()
          : null;
    });
    await _updateProgress();
    if (done[i]) {
      _confettiController.play();
      Future.delayed(Duration(seconds: 1), () {
        setState(() => _motivation = null);
      });
    }
  }

  String _randomMotivation() {
    final messages = [
      'Šaunuolis! 🎉',
      'Dar viena diena įveikta! 💪',
      'Taip ir toliau!',
      'Super! 🚀',
      'Puikus progresas!',
      'Esi kelyje į tikslą! ⭐',
    ];
    return (messages..shuffle()).first;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    int completed = done.where((d) => d).length;
    double progress = completed / period;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Kalendoriaus tinklelio dydis
    int columns = 7;
    int rows = (period / columns).ceil();
    return Scaffold(
      appBar: AppBar(title: Text('$icon $name')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.purple.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                SizedBox(height: 8),
                Text('Atlikta: $completed / $period (${(progress * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: period,
                    itemBuilder: (context, i) {
                      final dayDate = startDate.add(Duration(days: i));
                      final isToday = dayDate == today;
                      final isFuture = dayDate.isAfter(today);
                      return GestureDetector(
                        onTap: isFuture ? null : () => _onDayTap(i),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: done[i]
                                ? Colors.greenAccent.shade100
                                : isFuture
                                    ? Colors.grey.shade200
                                    : Colors.white,
                            border: Border.all(
                              color: isToday
                                  ? Colors.purple
                                  : done[i]
                                      ? Colors.green
                                      : Colors.grey.shade300,
                              width: isToday ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: done[i]
                                ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 8)]
                                : [],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${dayDate.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isFuture
                                          ? Colors.grey
                                          : done[i]
                                              ? Colors.green.shade800
                                              : Colors.black,
                                    )),
                                SizedBox(height: 4),
                                done[i]
                                    ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                                    : isFuture
                                        ? Icon(Icons.lock, color: Colors.grey, size: 18)
                                        : Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_motivation != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      _motivation!,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (progress == 1.0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Text('Sveikiname! Iššūkis įvykdytas! 🏅',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber[800])),
                        SizedBox(height: 8),
                        Icon(Icons.emoji_events, color: Colors.amber[700], size: 48),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.2,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: [Colors.purple, Colors.green, Colors.amber, Colors.pink, Colors.blue],
            ),
          ),
        ],
      ),
    );
  }
} 