import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutsScreen extends StatefulWidget {
  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final Map<String, List<Pratimas>> _savaitesPratimai = {
    'Pirmadienis': [],
    'Antradienis': [],
    'Trečiadienis': [],
    'Ketvirtadienis': [],
    'Penktadienis': [],
    'Šeštadienis': [],
    'Sekmadienis': [],
  };

  String _aktyviDiena = 'Pirmadienis';
  final _pavadinimasController = TextEditingController();
  final _setaiController = TextEditingController();
  final _pakartojimaiController = TextEditingController();

  void _pridetiPratima() {
    final pavadinimas = _pavadinimasController.text.trim();
    final setai = _setaiController.text.trim();
    final pakartojimai = _pakartojimaiController.text.trim();

    if (pavadinimas.isNotEmpty && setai.isNotEmpty && pakartojimai.isNotEmpty) {
      setState(() {
        _savaitesPratimai[_aktyviDiena]!.add(Pratimas(
          pavadinimas: pavadinimas,
          setai: setai,
          pakartojimai: pakartojimai,
          spalva: Colors.grey,
        ));
      });

      _pavadinimasController.clear();
      _setaiController.clear();
      _pakartojimaiController.clear();
    }
  }

  void _pasirinktiSpalva(int index) async {
    final pasirinkta = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pasirink spalvą'),
        content: Wrap(
          spacing: 10,
          children: Colors.primaries.map((color) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(color),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (pasirinkta != null) {
      setState(() {
        _savaitesPratimai[_aktyviDiena]![index].spalva = pasirinkta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dienos = _savaitesPratimai.keys.toList();
    final aktyviosDienosPratimai = _savaitesPratimai[_aktyviDiena]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tavo treniruotės'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Atsijungti',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dienos.length,
              itemBuilder: (context, index) {
                final diena = dienos[index];
                final aktyvi = diena == _aktyviDiena;
                return GestureDetector(
                  onTap: () => setState(() => _aktyviDiena = diena),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: aktyvi ? Colors.purple : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      diena,
                      style: TextStyle(
                        color: aktyvi ? Colors.white : Colors.black,
                        fontWeight: aktyvi ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _pavadinimasController,
                  decoration: InputDecoration(labelText: 'Pratimo pavadinimas'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _setaiController,
                        decoration: InputDecoration(labelText: 'Setai'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _pakartojimaiController,
                        decoration: InputDecoration(labelText: 'Pakartojimai'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pridetiPratima,
                  child: Text('Pridėti pratimą'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: aktyviosDienosPratimai.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final elementas = aktyviosDienosPratimai.removeAt(oldIndex);
                  aktyviosDienosPratimai.insert(newIndex, elementas);
                });
              },
              itemBuilder: (context, index) {
                final pratimas = aktyviosDienosPratimai[index];
                return Card(
                  key: ValueKey(pratimas),
                  color: pratimas.spalva.withOpacity(0.2),
                  child: ListTile(
                    title: Text(pratimas.pavadinimas),
                    subtitle: Text('${pratimas.setai} setai × ${pratimas.pakartojimai} kartai'),
                    trailing: IconButton(
                      icon: Icon(Icons.color_lens, color: pratimas.spalva),
                      onPressed: () => _pasirinktiSpalva(index),
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

class Pratimas {
  final String pavadinimas;
  final String setai;
  final String pakartojimai;
  Color spalva;

  Pratimas({
    required this.pavadinimas,
    required this.setai,
    required this.pakartojimai,
    required this.spalva,
  });
}
