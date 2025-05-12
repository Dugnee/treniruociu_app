import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProgressJournalScreen extends StatefulWidget {
  @override
  _ProgressJournalScreenState createState() => _ProgressJournalScreenState();
}

class _ProgressJournalScreenState extends State<ProgressJournalScreen> {
  int _period = 14;
  late List<bool> _done;
  late List<String> _notes;
  final _challengeNameController = TextEditingController();
  bool _challengeCompleted = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _done = List.generate(_period, (_) => false);
    _notes = List.generate(_period, (_) => '');
  }

  void _changePeriod(int days) {
    setState(() {
      _period = days;
      _done = List.generate(_period, (i) => i < _done.length ? _done[i] : false);
      _notes = List.generate(_period, (i) => i < _notes.length ? _notes[i] : '');
    });
  }

  Future<void> _saveAchievementToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('achievements')
        .doc();
    await doc.set({
      'name': _challengeNameController.text.trim(),
      'period': _period,
      'completedAt': now,
      'badge': 'gold',
      'notes': _notes,
    });
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    int completed = _done.where((d) => d).length;
    double progress = completed / _period;
    final today = DateTime.now().day;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _period - 1));
    bool allDone = completed == _period && !_challengeCompleted;

    if (allDone) {
      _challengeCompleted = true;
      _saveAchievementToFirebase();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Sveikiname!'),
            content: Text('Iššūkis įvykdytas ir pasiekimas išsaugotas! 🏅'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('Progreso žurnalas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _challengeNameController,
              decoration: InputDecoration(
                labelText: 'Iššūkio pavadinimas',
                hintText: 'Pvz., 14 dienų atsispaudimų iššūkis',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text('14 d.'),
                  selected: _period == 14,
                  onSelected: (_) => _changePeriod(14),
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('30 d.'),
                  selected: _period == 30,
                  onSelected: (_) => _changePeriod(30),
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('60 d.'),
                  selected: _period == 60,
                  onSelected: (_) => _changePeriod(60),
                ),
              ],
            ),
            SizedBox(height: 18),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.purple.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 8),
            Text('Atlikta: $completed / $_period (${(progress * 100).toStringAsFixed(0)}%)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _period,
                itemBuilder: (context, i) {
                  final dayDate = startDate.add(Duration(days: i));
                  final isFuture = dayDate.isAfter(DateTime(now.year, now.month, now.day));
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(dayDate), style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(_done[i] ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: _done[i] ? Colors.green : Colors.grey),
                                onPressed: isFuture
                                    ? null
                                    : () {
                                        setState(() => _done[i] = !_done[i]);
                                      },
                              ),
                            ],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Komentaras',
                                hintText: 'Kaip sekėsi, ką tobulinti...'
                              ),
                              minLines: 1,
                              maxLines: 3,
                              onChanged: (val) => _notes[i] = val,
                              controller: TextEditingController(text: _notes[i]),
                              enabled: !isFuture,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_saving)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
} 