import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengeProgressScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic> challenge;

  ChallengeProgressScreen({
    required this.challengeId,
    required this.challenge,
  });

  @override
  _ChallengeProgressScreenState createState() => _ChallengeProgressScreenState();
}

class _ChallengeProgressScreenState extends State<ChallengeProgressScreen> with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late List<bool> _completed;
  bool _loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _completed = List<bool>.from(widget.challenge['completed']);
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
      begin: Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateProgress(int dayIndex, bool completed) async {
    setState(() => _loading = true);
    try {
      final completedList = List<bool>.from(_completed);
      completedList[dayIndex] = completed;

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('progress_journal')
          .doc(widget.challengeId)
          .update({
        'completed': completedList,
      });

      setState(() {
        _completed = completedList;
        _loading = false;
      });

      // Patikrinti ar iššūkis baigtas
      final allCompleted = completedList.every((c) => c);
      if (allCompleted) {
        await _addAchievement();
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klaida atnaujinant progresą: $e')),
      );
    }
  }

  Future<void> _addAchievement() async {
    try {
      final achievementsSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('achievements')
          .where('name', isEqualTo: widget.challenge['name'])
          .get();

      if (achievementsSnapshot.docs.isEmpty) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('achievements')
            .add({
          'name': widget.challenge['name'],
          'period': widget.challenge['period'],
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
    final completed = _completed.where((c) => c).length;
    final progress = completed / widget.challenge['period'];

    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(
        title: Text(widget.challenge['name']),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.purple.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Atlikta: $completed / ${widget.challenge['period']} (${(progress * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: widget.challenge['period'],
                    itemBuilder: (context, index) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleButton(
                            onPressed: () => _updateProgress(index, !_completed[index]),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _completed[index]
                                    ? Colors.green.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _completed[index]
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${index + 1}d',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: _completed[index]
                                            ? Colors.green.shade800
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Icon(
                                      _completed[index]
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: _completed[index]
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  ScaleButton({
    required this.child,
    required this.onPressed,
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
} 