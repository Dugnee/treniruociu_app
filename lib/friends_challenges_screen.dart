import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class FriendsChallengesScreen extends StatefulWidget {
  @override
  State<FriendsChallengesScreen> createState() => _FriendsChallengesScreenState();
}

class _FriendsChallengesScreenState extends State<FriendsChallengesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(title: Text('Draugų iššūkiai')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Draugų iššūkiai',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BMICalculatorScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('BMI skaičiuoklė'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildChallengeCard(
                    'Bėgimo iššūkis',
                    'Nubėk 30 km per savaitę',
                    Icons.directions_run,
                    '3/7 dienų',
                    0.43,
                  ),
                  _buildChallengeCard(
                    'Pritūpimų iššūkis',
                    '1000 pritūpimų per 10 dienų',
                    Icons.fitness_center,
                    '450/1000 pritūpimų',
                    0.45,
                  ),
                  _buildChallengeCard(
                    'Vandens iššūkis',
                    'Gerk 2L vandens kasdien',
                    Icons.local_drink,
                    '5/10 dienų',
                    0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChallengeDialog(context);
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildChallengeCard(
    String title,
    String description,
    IconData icon,
    String progress,
    double progressValue,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.purple),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.share, color: Colors.grey),
              ],
            ),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 12),
            Text(
              progress,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dalyviai: Jonas, Tomas, Lina'),
                TextButton(
                  onPressed: () {},
                  child: Text('Prisijungti'),
                  style: TextButton.styleFrom(foregroundColor: Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Naujas iššūkis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Pavadinimas',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Aprašymas',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Trukmė (dienomis)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Atšaukti'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Sukurti'),
          ),
        ],
      ),
    );
  }
}

class BMICalculatorScreen extends StatefulWidget {
  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'Vyras';
  int _age = 25;
  double? _bmi;
  String? _bmiCategory;
  Color? _bmiColor;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      if (data['weight'] != null) _weightController.text = data['weight'].toString();
      if (data['height'] != null) _heightController.text = data['height'].toString();
      if (data['gender'] != null) _selectedGender = data['gender'];
      if (data['age'] != null) _age = data['age'];
      setState(() {});
    }
  }

  void _calculateBMI() {
    final double? weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final double? height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    if (weight == null || height == null || height == 0) {
      setState(() {
        _bmi = null;
        _bmiCategory = null;
        _bmiColor = null;
      });
      return;
    }
    final bmi = weight / pow(height / 100, 2);
    String category;
    Color color;
    if (bmi < 18.5) {
      category = 'Per mažas svoris';
      color = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normalus svoris';
      color = Colors.green;
    } else if (bmi < 30) {
      category = 'Antsvoris';
      color = Colors.orange;
    } else {
      category = 'Nutukimas';
      color = Colors.red;
    }
    setState(() {
      _bmi = bmi;
      _bmiCategory = category;
      _bmiColor = color;
    });
  }

  Widget _buildBarChart() {
    // Diagrama su gradientu, proporcingais žymėjimais ir ištęsta per 90% ekrano pločio
    final double minBMI = 15;
    final double maxBMI = 40;
    final double userBMI = _bmi ?? 0;
    final double barWidth = MediaQuery.of(context).size.width * 0.9;
    // Proporcijos pagal intervalus: [15-18.5], [18.5-25], [25-30], [30-40]
    final double seg1 = 18.5 - 15; // 3.5
    final double seg2 = 25 - 18.5; // 6.5
    final double seg3 = 30 - 25;   // 5
    final double seg4 = 40 - 30;   // 10
    final double total = seg1 + seg2 + seg3 + seg4; // 25
    final double w1 = barWidth * seg1 / total;
    final double w2 = barWidth * seg2 / total;
    final double w3 = barWidth * seg3 / total;
    final double w4 = barWidth * seg4 / total;
    // Rodyklės pozicija pagal proporciją
    double markerPos;
    if (userBMI <= 18.5) {
      markerPos = ((userBMI - 15) / seg1).clamp(0.0, 1.0) * w1;
    } else if (userBMI <= 25) {
      markerPos = w1 + ((userBMI - 18.5) / seg2).clamp(0.0, 1.0) * w2;
    } else if (userBMI <= 30) {
      markerPos = w1 + w2 + ((userBMI - 25) / seg3).clamp(0.0, 1.0) * w3;
    } else {
      markerPos = w1 + w2 + w3 + ((userBMI - 30) / seg4).clamp(0.0, 1.0) * w4;
    }
    // Proporcingos žymės (skaičiai ir kategorijos)
    final List<double> labelBMIs = [15, 18.5, 25, 30, 40];
    final List<String> labelNames = ['Per mažas', 'Normalus', 'Antsvoris', 'Nutukimas'];
    final List<Color> labelColors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    double _bmiToPos(double bmi) {
      if (bmi <= 18.5) {
        return ((bmi - 15) / seg1).clamp(0.0, 1.0) * w1;
      } else if (bmi <= 25) {
        return w1 + ((bmi - 18.5) / seg2).clamp(0.0, 1.0) * w2;
      } else if (bmi <= 30) {
        return w1 + w2 + ((bmi - 25) / seg3).clamp(0.0, 1.0) * w3;
      } else {
        return w1 + w2 + w3 + ((bmi - 30) / seg4).clamp(0.0, 1.0) * w4;
      }
    }
    return Stack(
      children: [
        SizedBox(height: 24),
        Text('BMI normų diagrama:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: barWidth,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: [
                  Colors.blue.shade200,
                  Colors.green.shade300,
                  Colors.orange.shade300,
                  Colors.red.shade300,
                ], stops: [0.14, 0.36, 0.56, 1.0]),
              ),
            ),
            if (_bmi != null)
              Positioned(
                left: markerPos - 8,
                top: 0,
                child: Column(
                  children: [
                    Icon(Icons.arrow_drop_down, color: _bmiColor, size: 32),
                    Container(
                      width: 16,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _bmiColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        // Skaičiai po diagrama
        SizedBox(
          width: barWidth,
          child: Stack(
            children: [
              for (var bmi in labelBMIs)
                Positioned(
                  left: _bmiToPos(bmi) - 12,
                  child: SizedBox(width: 24, child: Text(bmi.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Kategorijų pavadinimai po diagrama
        SizedBox(
          width: barWidth,
          child: Stack(
            children: [
              for (int i = 0; i < labelNames.length; i++)
                Positioned(
                  left: i == 0
                      ? _bmiToPos(15)
                      : i == labelNames.length - 1
                          ? _bmiToPos(35)
                          : (_bmiToPos(labelBMIs[i + 1]) + _bmiToPos(labelBMIs[i])) / 2 - 30,
                  child: SizedBox(
                    width: 60,
                    child: Text(labelNames[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: labelColors[i])),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA591E2),
      appBar: AppBar(title: Text('BMI skaičiuoklė')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Įveskite savo duomenis:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Svoris (kg)', border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Ūgis (cm)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: ['Vyras', 'Moteris'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _selectedGender = v ?? 'Vyras'),
                      decoration: InputDecoration(labelText: 'Lytis', border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Amžius', border: OutlineInputBorder()),
                      onChanged: (v) => setState(() => _age = int.tryParse(v) ?? 25),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateBMI,
                child: Text('Apskaičiuoti'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              ),
              if (_bmi != null) ...[
                SizedBox(height: 24),
                Text('Jūsų BMI: ${_bmi!.toStringAsFixed(1)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _bmiColor)),
                SizedBox(height: 8),
                Text(_bmiCategory ?? '', style: TextStyle(fontSize: 18, color: _bmiColor, fontWeight: FontWeight.w500)),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: _buildBarChart(),
                ),
              ],
              SizedBox(height: 32),
              Text('BMI normos pagal PSO:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• < 18.5 – per mažas svoris\n• 18.5–24.9 – normalus svoris\n• 25–29.9 – antsvoris\n• 30+ – nutukimas', style: TextStyle(fontSize: 14)),
              SizedBox(height: 16),
              Text('Pastaba: vaikams ir paaugliams normos gali skirtis pagal amžių ir lytį.', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }
} 