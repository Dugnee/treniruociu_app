import 'package:flutter/material.dart';
import 'workout_generator.dart';
import 'workout_plan_screen.dart';

// ScaleButton klasė - naudojama animuotiems mygtukams
class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;

  const ScaleButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  _ScaleButtonState createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
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

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class WorkoutGeneratorScreen extends StatefulWidget {
  @override
  _WorkoutGeneratorScreenState createState() => _WorkoutGeneratorScreenState();
}

class _WorkoutGeneratorScreenState extends State<WorkoutGeneratorScreen> with SingleTickerProviderStateMixin {
  Goal _selectedGoal = Goal.muscle;
  Experience _selectedExperience = Experience.intermediate;
  Equipment _selectedEquipment = Equipment.gym;
  int _selectedDaysPerWeek = 3;
  bool _isGenerating = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _generatePlan() async {
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Generuojame treniruočių planą
      final workoutPlan = WorkoutGenerator.generateWorkoutPlan(
        goal: _selectedGoal,
        experience: _selectedExperience,
        equipment: _selectedEquipment,
        daysPerWeek: _selectedDaysPerWeek,
      );

      // Log the generated workout plan
      print('Generated Workout Plan: $workoutPlan');

      // Išsaugome planą Firestore
      final planId = await WorkoutGenerator.saveWorkoutPlan(workoutPlan);
      
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        
        // Navigacija į sugeneruoto plano peržiūros ekraną
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutPlanScreen(
              workoutPlan: workoutPlan,
              planId: planId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Klaida generuojant planą: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(
        title: Text('Treniruočių generatorius'),
        elevation: 0,
      ),
      body: _isGenerating
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Generuojamas asmeninis treniruočių planas...',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoCard(
                          icon: Icons.fitness_center,
                          title: 'Koks treniruočių tikslas?',
                          content: _buildGoalSelection(),
                        ),
                        SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.bar_chart,
                          title: 'Patirtis?',
                          content: _buildExperienceSelection(),
                        ),
                        SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.fitness_center,
                          title: 'Kokia įranga naudosi?',
                          content: _buildEquipmentSelection(),
                        ),
                        SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.calendar_today,
                          title: 'Kiek dienų per savaitę?',
                          content: _buildDaysPerWeekSelection(),
                        ),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _generatePlan,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'GENERUOTI TRENIRUOČIŲ PLANĄ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.purple),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalSelection() {
    return Column(
      children: [
        _buildSelectionOption(
          isSelected: _selectedGoal == Goal.strength,
          title: 'Jėga',
          description: 'Didinti maksimalią jėgą ir raumenų pajėgumą',
          onTap: () => setState(() => _selectedGoal = Goal.strength),
        ),
        _buildSelectionOption(
          isSelected: _selectedGoal == Goal.muscle,
          title: 'Raumenų masė',
          description: 'Auginti raumenų masę ir gerinti kūno formą',
          onTap: () => setState(() => _selectedGoal = Goal.muscle),
        ),
        _buildSelectionOption(
          isSelected: _selectedGoal == Goal.weightLoss,
          title: 'Svorio metimas',
          description: 'Mažinti kūno riebalų kiekį ir gerinti fizinę formą',
          onTap: () => setState(() => _selectedGoal = Goal.weightLoss),
        ),
        _buildSelectionOption(
          isSelected: _selectedGoal == Goal.endurance,
          title: 'Ištvermė',
          description: 'Didinti raumenų ištvermę ir gerinti širdies darbą',
          onTap: () => setState(() => _selectedGoal = Goal.endurance),
          isLast: true,
        ),
      ],
    );
  }
  
  Widget _buildExperienceSelection() {
    return Column(
      children: [
        _buildSelectionOption(
          isSelected: _selectedExperience == Experience.beginner,
          title: 'Pradedantysis',
          description: 'Iki 1 metų treniruočių patirties',
          onTap: () => setState(() => _selectedExperience = Experience.beginner),
        ),
        _buildSelectionOption(
          isSelected: _selectedExperience == Experience.intermediate,
          title: 'Vidutinis',
          description: '1-3 metai treniruočių patirties',
          onTap: () => setState(() => _selectedExperience = Experience.intermediate),
        ),
        _buildSelectionOption(
          isSelected: _selectedExperience == Experience.advanced,
          title: 'Pažengęs',
          description: 'Daugiau nei 3 metai treniruočių patirties',
          onTap: () => setState(() => _selectedExperience = Experience.advanced),
          isLast: true,
        ),
      ],
    );
  }
  
  Widget _buildEquipmentSelection() {
    return Column(
      children: [
        _buildSelectionOption(
          isSelected: _selectedEquipment == Equipment.gym,
          title: 'Sporto salė',
          description: 'Prieiga prie pilnos sporto salės įrangos',
          onTap: () => setState(() => _selectedEquipment = Equipment.gym),
        ),
        _buildSelectionOption(
          isSelected: _selectedEquipment == Equipment.home,
          title: 'Namų įranga',
          description: 'Ribotas kiekis įrangos namuose (hanteliai, kamuoliai)',
          onTap: () => setState(() => _selectedEquipment = Equipment.home),
        ),
        _buildSelectionOption(
          isSelected: _selectedEquipment == Equipment.minimal,
          title: 'Minimali įranga',
          description: 'Beveik be įrangos, daugiausia savo svorio pratimai',
          onTap: () => setState(() => _selectedEquipment = Equipment.minimal),
          isLast: true,
        ),
      ],
    );
  }
  
  Widget _buildDaysPerWeekSelection() {
    return Container(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          final days = index + 1;
          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: _buildCircularButton(
              isSelected: _selectedDaysPerWeek == days,
              label: days.toString(),
              onTap: () => setState(() => _selectedDaysPerWeek = days),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCircularButton({
    required bool isSelected,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.purple : Colors.white,
          border: Border.all(
            color: Colors.purple,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSelectionOption({
    required bool isSelected,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.purple : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 16,
          ),
      ],
    );
  }
} 