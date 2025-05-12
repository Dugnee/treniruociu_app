import 'package:flutter/material.dart';

class FriendsChallengesScreen extends StatelessWidget {
  // Simuliuoti draugų duomenys
  final List<Map<String, dynamic>> friends = [
    {
      'name': 'Tomas',
      'avatar': '🧑‍🦱',
      'exercise': 120,
      'goal': 200,
    },
    {
      'name': 'Aistė',
      'avatar': '👩‍🦰',
      'exercise': 180,
      'goal': 200,
    },
    {
      'name': 'Justas',
      'avatar': '🧑‍🦰',
      'exercise': 90,
      'goal': 200,
    },
    {
      'name': 'Tu',
      'avatar': '🧑',
      'exercise': 150,
      'goal': 200,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Draugų iššūkiai')),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: friends.length,
        separatorBuilder: (_, __) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final friend = friends[index];
          final percent = (friend['exercise'] / friend['goal']).clamp(0.0, 1.0);
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(friend['avatar'], style: TextStyle(fontSize: 36)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(friend['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percent,
                          minHeight: 10,
                          backgroundColor: Colors.purple.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('💪 ${friend['exercise']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                            SizedBox(width: 8),
                            Text('/ ${friend['goal']} per savaitę', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 