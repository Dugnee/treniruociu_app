import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'challenge_progress_screen.dart';

class ProgressJournalScreen extends StatefulWidget {
  @override
  _ProgressJournalScreenState createState() => _ProgressJournalScreenState();
}

class _ProgressJournalScreenState extends State<ProgressJournalScreen> with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = true;
  List<Map<String, dynamic>> _challenges = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadChallenges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    if (_auth.currentUser == null) return;
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('progress_journal')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _challenges = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'period': data['period'] ?? 14,
            'createdAt': (data['createdAt'] as Timestamp).toDate(),
            'notes': List<String>.from(data['notes'] ?? []),
            'completed': List<bool>.from(data['completed'] ?? []),
          };
        }).toList();
        _loading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Klaida kraunant iššūkius: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _createNewChallenge() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => NewChallengeDialog(),
    );

    if (result != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('progress_journal')
            .add({
          'name': result['name'],
          'period': result['period'],
          'createdAt': FieldValue.serverTimestamp(),
          'notes': List.generate(result['period'], (_) => ''),
          'completed': List.generate(result['period'], (_) => false),
        });

        await _loadChallenges();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Klaida kuriant iššūkį: $e')),
        );
      }
    }
  }

  Future<void> _updateChallenge(String challengeId, int dayIndex, bool completed, String note) async {
    try {
      final challenge = _challenges.firstWhere((c) => c['id'] == challengeId);
      final completedList = List<bool>.from(challenge['completed']);
      final notesList = List<String>.from(challenge['notes']);
      
      completedList[dayIndex] = completed;
      notesList[dayIndex] = note;

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('progress_journal')
          .doc(challengeId)
          .update({
        'completed': completedList,
        'notes': notesList,
      });

      // Patikrinti ar iššūkis baigtas
      final allCompleted = completedList.every((c) => c);
      if (allCompleted) {
        await _addAchievement(challenge['name'], challenge['period']);
      }

      await _loadChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klaida atnaujinant iššūkį: $e')),
      );
    }
  }

  Future<void> _addAchievement(String name, int period) async {
    try {
      // Patikrinti ar jau yra toks pasiekimas
      final achievementsSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('achievements')
          .where('name', isEqualTo: name)
          .get();

      if (achievementsSnapshot.docs.isEmpty) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('achievements')
            .add({
          'name': name,
          'period': period,
          'completedAt': FieldValue.serverTimestamp(),
          'badge': 'gold',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sveikiname! Iššūkis įvykdytas! 🏅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Klaida pridedant pasiekimą: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Color(0xFFA591E2),
        appBar: AppBar(title: Text('Progreso žurnalas')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(
        title: Text('Progreso žurnalas'),
        actions: [
          ScaleButton(
            onPressed: _createNewChallenge,
            child: Icon(Icons.add),
            tooltip: 'Naujas iššūkis',
          ),
        ],
      ),
      body: _challenges.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Iššūkių dar nėra',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  ScaleButton(
                    onPressed: _createNewChallenge,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Sukurti iššūkį'),
                      onPressed: null,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                final completed = (challenge['completed'] as List<bool>).where((c) => c).length;
                final progress = completed / challenge['period'];
                
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ScaleButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChallengeProgressScreen(
                                challengeId: challenge['id'],
                                challenge: challenge,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.emoji_events, color: Colors.amber),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        challenge['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${challenge['period']} d.',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.purple.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Atlikta: $completed / ${challenge['period']} (${(progress * 100).toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String? tooltip;

  ScaleButton({
    required this.child,
    required this.onPressed,
    this.tooltip,
  });

  @override
  _ScaleButtonState createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

class NewChallengeDialog extends StatefulWidget {
  @override
  _NewChallengeDialogState createState() => _NewChallengeDialogState();
}

class _NewChallengeDialogState extends State<NewChallengeDialog> {
  final _nameController = TextEditingController();
  int _selectedPeriod = 14;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Naujas iššūkis'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Iššūkio pavadinimas',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleButton(
                onPressed: () => setState(() => _selectedPeriod = 14),
                child: ChoiceChip(
                  label: Text('14 d.'),
                  selected: _selectedPeriod == 14,
                  onSelected: (_) {},
                ),
              ),
              SizedBox(width: 8),
              ScaleButton(
                onPressed: () => setState(() => _selectedPeriod = 30),
                child: ChoiceChip(
                  label: Text('30 d.'),
                  selected: _selectedPeriod == 30,
                  onSelected: (_) {},
                ),
              ),
              SizedBox(width: 8),
              ScaleButton(
                onPressed: () => setState(() => _selectedPeriod = 60),
                child: ChoiceChip(
                  label: Text('60 d.'),
                  selected: _selectedPeriod == 60,
                  onSelected: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ScaleButton(
          onPressed: () => Navigator.pop(context),
          child: TextButton(
            onPressed: null,
            child: Text('Atšaukti'),
          ),
        ),
        ScaleButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'period': _selectedPeriod,
              });
            }
          },
          child: ElevatedButton(
            onPressed: null,
            child: Text('Sukurti'),
          ),
        ),
      ],
    );
  }
} 