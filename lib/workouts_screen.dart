import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() => {
        'pavadinimas': pavadinimas,
        'setai': setai,
        'pakartojimai': pakartojimai,
        'spalva': spalva.value,
      };

  static Pratimas fromMap(Map<String, dynamic> map) => Pratimas(
        pavadinimas: map['pavadinimas'],
        setai: map['setai'],
        pakartojimai: map['pakartojimai'],
        spalva: Color(map['spalva']),
      );
}

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

  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _kraunama = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_uid == null) {
      if (mounted) setState(() => _kraunama = false);
      return;
    }
    final doc = await _firestore.collection('treniruotes').doc(_uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data.forEach((diena, sarasas) {
        final pratimai = (sarasas as List)
            .map((e) => Pratimas.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        _savaitesPratimai[diena] = pratimai;
      });
    }
    if (mounted) setState(() => _kraunama = false);
  }

  Future<void> _saveData() async {
    if (_uid == null) return;
    final Map<String, dynamic> data = {};
    _savaitesPratimai.forEach((diena, sarasas) {
      data[diena] = sarasas.map((e) => e.toMap()).toList();
    });
    await _firestore.collection('treniruotes').doc(_uid).set(data);
  }

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
      Navigator.pop(context);
      _saveData();
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
      if (mounted) setState(() {
        _savaitesPratimai[_aktyviDiena]![index].spalva = pasirinkta;
      });
      _saveData();
    }
  }

  void _rodytiDialogaPrideti() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Naujas pratimas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pavadinimasController,
              decoration: InputDecoration(labelText: 'Pavadinimas'),
            ),
            TextField(
              controller: _setaiController,
              decoration: InputDecoration(labelText: 'Setai'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pakartojimaiController,
              decoration: InputDecoration(labelText: 'Pakartojimai'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Atšaukti')),
          ElevatedButton(onPressed: _pridetiPratima, child: Text('Pridėti')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dienos = _savaitesPratimai.keys.toList();
    final aktyviosDienosPratimai = _savaitesPratimai[_aktyviDiena]!;

    if (_kraunama) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dienos.length,
              itemBuilder: (context, index) {
                final diena = dienos[index];
                final aktyvi = diena == _aktyviDiena;
                return GestureDetector(
                  onTap: () => setState(() => _aktyviDiena = diena),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
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
          Expanded(
            child: aktyviosDienosPratimai.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Pratimai neįvesti'),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: aktyviosDienosPratimai.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final elementas = aktyviosDienosPratimai.removeAt(oldIndex);
                        aktyviosDienosPratimai.insert(newIndex, elementas);
                      });
                      _saveData();
                    },
                    itemBuilder: (context, index) {
                      final pratimas = aktyviosDienosPratimai[index];
                      return Dismissible(
                        key: ValueKey('${_aktyviDiena}_${pratimas.pavadinimas}_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          final istrintasPratimas = pratimas;
                          final istrintoIndexas = index;
                          setState(() {
                            aktyviosDienosPratimai.removeAt(index);
                          });
                          _saveData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pratimas ištrintas'),
                              action: SnackBarAction(
                                label: 'Atšaukti',
                                onPressed: () {
                                  setState(() {
                                    aktyviosDienosPratimai.insert(
                                      istrintoIndexas > aktyviosDienosPratimai.length
                                        ? aktyviosDienosPratimai.length
                                        : istrintoIndexas,
                                      istrintasPratimas,
                                    );
                                  });
                                  _saveData();
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: pratimas.spalva.withOpacity(0.2),
                          elevation: 3,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            title: Text(pratimas.pavadinimas),
                            subtitle: Text('${pratimas.setai} setai × ${pratimas.pakartojimai} kartai'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.color_lens, color: pratimas.spalva),
                                  onPressed: () => _pasirinktiSpalva(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Ištrinti',
                                  onPressed: () {
                                    final istrintasPratimas = pratimas;
                                    final istrintoIndexas = index;
                                    setState(() {
                                      aktyviosDienosPratimai.removeAt(index);
                                    });
                                    _saveData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Pratimas ištrintas'),
                                        action: SnackBarAction(
                                          label: 'Atšaukti',
                                          onPressed: () {
                                            setState(() {
                                              aktyviosDienosPratimai.insert(
                                                istrintoIndexas > aktyviosDienosPratimai.length
                                                  ? aktyviosDienosPratimai.length
                                                  : istrintoIndexas,
                                                istrintasPratimas,
                                              );
                                            });
                                            _saveData();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _rodytiDialogaPrideti,
        icon: Icon(Icons.add),
        label: Text('Pratimas'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
