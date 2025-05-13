import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'challenge_calendar_screen.dart';

class MyChallengesScreen extends StatefulWidget {
  @override
  State<MyChallengesScreen> createState() => _MyChallengesScreenState();
}

class _MyChallengesScreenState extends State<MyChallengesScreen> {
  final _challengeNameController = TextEditingController();
  int _selectedPeriod = 14;
  String _selectedIcon = '💪';
  DateTime _startDate = DateTime.now();
  final List<String> _icons = ['💪', '🏃', '📚', '🧘', '🚴', '🥗', '🛏️'];

  Future<void> _createChallenge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('challenges')
        .doc();
    await doc.set({
      'name': _challengeNameController.text.trim(),
      'period': _selectedPeriod,
      'icon': _selectedIcon,
      'startDate': _startDate,
      'createdAt': DateTime.now(),
    });
    _challengeNameController.clear();
    setState(() {
      _selectedPeriod = 14;
      _selectedIcon = '💪';
      _startDate = DateTime.now();
    });
    Navigator.pop(context);
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Naujas iššūkis'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _challengeNameController,
                decoration: InputDecoration(labelText: 'Iššūkio pavadinimas'),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(label: Text('14 d.'), selected: _selectedPeriod == 14, onSelected: (_) => setState(() => _selectedPeriod = 14)),
                  SizedBox(width: 8),
                  ChoiceChip(label: Text('30 d.'), selected: _selectedPeriod == 30, onSelected: (_) => setState(() => _selectedPeriod = 30)),
                  SizedBox(width: 8),
                  ChoiceChip(label: Text('60 d.'), selected: _selectedPeriod == 60, onSelected: (_) => setState(() => _selectedPeriod = 60)),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _icons.map((icon) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(icon, style: TextStyle(fontSize: 20)),
                    selected: _selectedIcon == icon,
                    onSelected: (_) => setState(() => _selectedIcon = icon),
                  ),
                )).toList(),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('Pradžios data: '),
                  TextButton(
                    child: Text('${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Atšaukti')),
          ElevatedButton(onPressed: _createChallenge, child: Text('Sukurti')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Mano iššūkiai')),
        body: Center(child: Text('Prisijunkite, kad matytumėte iššūkius.')),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(title: Text('Mano iššūkiai')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: Icon(Icons.add),
        tooltip: 'Sukurti naują iššūkį',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('challenges')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Iššūkių dar nėra. Sukurkite naują!'));
          }
          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Text(data['icon'] ?? '💪', style: TextStyle(fontSize: 32)),
                  title: Text(data['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Pradžia: ${data['startDate'] != null ? (data['startDate'] as Timestamp).toDate().toString().split(' ')[0] : ''}  |  Trukmė: ${data['period']} d.'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChallengeCalendarScreen(
                          challengeId: id,
                          challengeData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
} 