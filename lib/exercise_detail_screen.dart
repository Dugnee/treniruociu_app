import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'workout_generator.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  
  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  Future<void> _launchYoutubeVideo() async {
    final videoUrl = widget.exercise['example'] as String;
    final Uri url = Uri.parse(videoUrl);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nepavyko atidaryti video: $videoUrl')),
        );
      }
    }
  }
  
  Widget _buildEquipmentChips() {
    final equipment = widget.exercise['equipment'] as List<Equipment>;
    final chips = equipment.map((e) {
      String label;
      Color color;
      
      switch (e) {
        case Equipment.gym:
          label = 'Sporto salė';
          color = Colors.red;
          break;
        case Equipment.home:
          label = 'Namų įranga';
          color = Colors.green;
          break;
        case Equipment.minimal:
          label = 'Minimali įranga';
          color = Colors.blue;
          break;
      }
      
      return Chip(
        label: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
      );
    }).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
  
  Widget _buildLevelChips() {
    final levels = widget.exercise['level'] as List<Experience>;
    final chips = levels.map((e) {
      String label;
      Color color;
      
      switch (e) {
        case Experience.beginner:
          label = 'Pradedantysis';
          color = Colors.green;
          break;
        case Experience.intermediate:
          label = 'Vidutinis';
          color = Colors.orange;
          break;
        case Experience.advanced:
          label = 'Pažengęs';
          color = Colors.red;
          break;
      }
      
      return Chip(
        label: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
      );
    }).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
  
  Widget _buildMuscleChips() {
    final muscles = widget.exercise['muscles'] as List<String>;
    final chips = muscles.map((muscle) {
      String label = _getMuscleTranslation(muscle);
      
      return Chip(
        label: Text(label),
        backgroundColor: Colors.purple.withOpacity(0.2),
      );
    }).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
  
  String _getMuscleTranslation(String muscle) {
    switch (muscle) {
      case 'quadriceps':
        return 'Keturgalvis';
      case 'hamstrings':
        return 'Dvigalvis šlaunies';
      case 'glutes':
        return 'Sėdmenys';
      case 'calves':
        return 'Blauzdos';
      case 'chest':
        return 'Krūtinė';
      case 'upper_chest':
        return 'Viršutinė krūtinė';
      case 'triceps':
        return 'Tricepsas';
      case 'biceps':
        return 'Bicepsas';
      case 'shoulders':
        return 'Pečiai';
      case 'front_deltoids':
        return 'Priekiniai pečiai';
      case 'lateral_deltoids':
        return 'Šoniniai pečiai';
      case 'rear_deltoids':
        return 'Užpakaliniai pečiai';
      case 'traps':
        return 'Trapecijos';
      case 'lats':
        return 'Plačiausias nugaros';
      case 'middle_back':
        return 'Vidurinė nugara';
      case 'lower_back':
        return 'Apatinė nugara';
      case 'abs':
        return 'Pilvo presas';
      case 'obliques':
        return 'Šoniniai preso raumenys';
      case 'lower_abs':
        return 'Apatinis presas';
      case 'forearms':
        return 'Dilbiai';
      case 'hip_flexors':
        return 'Klubo lenkiamieji';
      case 'heart':
        return 'Širdis';
      case 'full_body':
        return 'Visas kūnas';
      case 'arms':
        return 'Rankos';
      case 'legs':
        return 'Kojos';
      default:
        return muscle;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final videoUrl = widget.exercise['example'] as String;
    
    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(
        title: Text(widget.exercise['name']),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video demonstracija mygtukas
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _launchYoutubeVideo,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded, 
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Žiūrėti video demonstraciją',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Atidarys YouTube programėlę',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new),
                    ],
                  ),
                ),
              ),
            ),
              
            SizedBox(height: 16),
            
            // Pratimo aprašymas
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aprašymas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.exercise['description'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Raumenų grupės
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirbantys raumenys',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildMuscleChips(),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Įranga ir lygis
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Įranga',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildEquipmentChips(),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sudėtingumas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildLevelChips(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Patarimai
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.yellow.shade100,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Patarimai',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Išlaikykite teisingą formą vietoj didesnio svorio.\n'
                      '• Kvėpuokite teisingai - iškvėpkite pastangos metu.\n'
                      '• Judėkite kontroliuodami judesį, venkite staigių judesių.\n'
                      '• Užtikrinkite tinkamą raumenų įtempimą viso judesio metu.',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 