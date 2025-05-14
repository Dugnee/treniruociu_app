import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_generator.dart';
import 'exercise_database.dart';
import 'exercise_detail_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  final List<Map<String, dynamic>> workoutPlan;
  final String planId;
  final String? initialName;

  const WorkoutPlanScreen({
    Key? key,
    required this.workoutPlan,
    required this.planId,
    this.initialName,
  }) : super(key: key);

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedDay = 0;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _planNameController;

  @override
  void initState() {
    super.initState();
    _planNameController = TextEditingController(
      text: widget.initialName ??
          'Asmeninis planas ${DateTime.now().toString().substring(0, 10)}',
    );
  }

  @override
  void dispose() {
    _planNameController.dispose();
    super.dispose();
  }

  Future<void> _updatePlanName() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('workout_plans')
              .doc(widget.planId)
              .update({'name': _planNameController.text.trim()});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plano pavadinimas atnaujintas')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Klaida atnaujinant planą: $e')),
        );
      }
    }
  }

  void _showExerciseDetails(Map<String, dynamic> exercise) {
    final exerciseData = ExerciseDatabase.getExerciseByName(exercise['name']);

    if (exerciseData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExerciseDetailScreen(exercise: exerciseData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pratimo informacija nerasta')),
      );
    }
  }

  Widget _buildExerciseCard(
    Map<String, dynamic> exercise,
    Map<String, dynamic> trainingParams,
  ) {
    final name = exercise['name'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showExerciseDetails(exercise),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.info_outline, color: Colors.purple),
                ],
              ),
              const SizedBox(height: 8),
              Text('Setai: ${trainingParams['sets']}',
                  style: const TextStyle(fontSize: 16)),
              Text(
                'Pakartojimai: ${trainingParams['reps'][0]}-${trainingParams['reps'][1]}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('Poilsis: ${trainingParams['rest']}'),
                    backgroundColor: Colors.purple.withOpacity(0.2),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Tempas: ${trainingParams['tempo']}'),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workoutPlan.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Treniruotės planas tuščias')),
      );
    }

    final currentDay = widget.workoutPlan[_selectedDay];
    final exercises = currentDay['exercises'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: const Color(0xFFA591E2),
      appBar: AppBar(
        title: const Text('Jūsų treniruočių planas'),
        actions: [
          // ---- Edit name ----
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Redaguoti plano pavadinimą'),
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _planNameController,
                      decoration: const InputDecoration(
                        labelText: 'Plano pavadinimas',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Įveskite pavadinimą' : null,
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('ATŠAUKTI'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: const Text('IŠSAUGOTI'),
                      onPressed: () {
                        _updatePlanName();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          // ---- Delete plan ----
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Ištrinti planą',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Ištrinti planą?'),
                  content: const Text('Ar tikrai norite ištrinti šį treniruočių planą?'),
                  actions: [
                    TextButton(
                      child: const Text('Atšaukti'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Ištrinti'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('workout_plans')
                    .doc(widget.planId)
                    .delete();
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------ Dienų „chip“ juosta ------
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.workoutPlan.length,
                  itemBuilder: (context, index) {
                    final day = widget.workoutPlan[index]['day'] as String;
                    final isSelected = index == _selectedDay;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: ChoiceChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (sel) {
                          if (sel) setState(() => _selectedDay = index);
                        },
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ------ Likęs turinys su slinktuku ------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Kortelė su raumenų grupėmis ir info ---
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Treniruojamos raumenų grupės:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (currentDay['muscleGroups'] as List).map((group) {
                                  return Chip(
                                    label: Text(_getMuscleGroupName(group.toString())),
                                    backgroundColor: _getMuscleGroupColor(group.toString()),
                                  );
                                }).toList(),
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.fitness_center, color: Colors.purple),
                                  const SizedBox(width: 8),
                                  Text('Intensyvumas: ${currentDay['intensity']}',
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.purple),
                                  const SizedBox(width: 8),
                                  Text('Poilsis tarp setų: ${currentDay['rest']}',
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- Pratimų sąrašas ---
                      Row(
                        children: [
                          const Text('Pratimai',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(
                            '(paspauskite, kad pamatytumėte detales)',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...exercises.map((ex) {
                        // Gauti treniruotės parametrus
                        final params = {
                          'sets': 3,
                          'reps': [8, 12],
                          'rest': currentDay['rest'],
                          'tempo': 'Vidutinis',
                        };
                        return _buildExerciseCard(ex, params);
                      }).toList(),
                      const SizedBox(height: 24),

                      // --- Patarimų kortelė ---
                      Card(
                        color: Colors.yellow.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Treniruotės patarimai',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '- Prieš treniruotę būtinai atlikite apšilimą.\n'
                                '- Pratimus atlikite techniškai teisingai.\n'
                                '- Geriau mažesnis svoris su teisinga technika, nei didelis su netinkama.\n'
                                '- Gerkite pakankamai vandens treniruotės metu.\n'
                                '- Po treniruotės skirkite laiko tempimo pratimams.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMuscleGroupName(String code) {
    switch (code) {
      case 'chest':
        return 'Krūtinė';
      case 'back':
        return 'Nugara';
      case 'legs':
        return 'Kojos';
      case 'shoulders':
        return 'Pečiai';
      case 'arms':
        return 'Rankos';
      case 'core':
        return 'Pilvo presas';
      case 'cardio':
        return 'Kardio';
      case 'biceps':
        return 'Bicepsai';
      case 'triceps':
        return 'Tricepsai';
      default:
        return code;
    }
  }

  Color _getMuscleGroupColor(String code) {
    switch (code) {
      case 'chest':
        return Colors.red.withOpacity(0.3);
      case 'back':
        return Colors.blue.withOpacity(0.3);
      case 'legs':
        return Colors.green.withOpacity(0.3);
      case 'shoulders':
        return Colors.amber.withOpacity(0.3);
      case 'arms':
        return Colors.purple.withOpacity(0.3);
      case 'core':
        return Colors.orange.withOpacity(0.3);
      case 'cardio':
        return Colors.pink.withOpacity(0.3);
      case 'biceps':
        return Colors.indigo.withOpacity(0.3);
      case 'triceps':
        return Colors.teal.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }
}
