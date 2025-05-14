import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_plan_screen.dart';

class MyPlansScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Mano planai')),
        body: Center(child: Text('Prisijunkite, kad matytumėte planus.')),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(title: Text('Mano treniruočių planai')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('workout_plans')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('Nėra išsaugotų planų.'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final planId = docs[i].id;
              final name = data['name'] ?? 'Be pavadinimo';
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              return Dismissible(
                key: ValueKey(planId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (dir) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Ištrinti planą?'),
                      content: Text('Ar tikrai norite ištrinti šį treniruočių planą?'),
                      actions: [
                        TextButton(
                          child: Text('Atšaukti'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        ElevatedButton(
                          child: Text('Ištrinti'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('workout_plans')
                      .doc(planId)
                      .delete();
                },
                child: ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: createdAt != null
                      ? Text('Sukurta: ${createdAt.toString().split(' ')[0]}')
                      : null,
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutPlanScreen(
                          workoutPlan: (data['workoutDays'] as List?)?.map((e) {
                            final day = Map<String, dynamic>.from(e as Map);
                            day['exercises'] = (day['exercises'] as List?)?.map((ex) => Map<String, dynamic>.from(ex as Map)).toList() ?? [];
                            return day;
                          }).toList() ?? [],
                          planId: planId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 