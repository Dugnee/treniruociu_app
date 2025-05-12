import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'main.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  final _nameController = TextEditingController();
  bool _saving = false;
  String? _photoUrl;
  User? _user;
  bool _isWeb = kIsWeb;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _photoUrl = _user?.photoURL;
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    if (_user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      if (doc.exists && doc.data() != null && doc.data()!['name'] != null) {
        _nameController.text = doc.data()!['name'];
      } else if (_user!.displayName != null && _user!.displayName!.isNotEmpty) {
        _nameController.text = _user!.displayName!;
      } else {
        _nameController.text = '';
      }
      setState(() {});
    } catch (e) {
      print('DEBUG: Klaida kraunant vartotojo vardą: $e');
      setState(() {
        _nameController.text = '';
      });
    }
  }

  Future<void> _saveUserName() async {
    if (_user == null) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
      'name': _nameController.text.trim(),
    }, SetOptions(merge: true));
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vardas išsaugotas!')));
  }

  Widget _buildAchievements() {
    if (_user == null) return SizedBox.shrink();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('achievements')
          .orderBy('completedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Pasiekimų dar nėra', style: TextStyle(color: Colors.grey)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text('Pasiekimai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['completedAt'] as Timestamp).toDate();
              return Card(
                color: Colors.amber.shade50,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Text('🏅', style: TextStyle(fontSize: 32)),
                  title: Text(data['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Įvykdyta: ${DateFormat('yyyy-MM-dd').format(date)}'),
                  trailing: Text('${data['period']} d.', style: TextStyle(fontSize: 16)),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Nustatymai')),
        body: Center(child: Text('Vartotojas neprisijungęs')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nustatymai'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
                          ? NetworkImage(_photoUrl!)
                          : null,
                      child: (_photoUrl == null || _photoUrl!.isEmpty)
                          ? Icon(Icons.person, size: 48)
                          : null,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Vardas',
                          border: OutlineInputBorder(),
                          hintText: 'Nežinomas vartotojas',
                        ),
                      ),
                    ),
                    if (_nameController.text.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Vardas nerastas', style: TextStyle(color: Colors.red)),
                      ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _saving ? null : _saveUserName,
                      child: _saving ? CircularProgressIndicator() : Text('Išsaugoti'),
                    ),
                  ],
                ),
              ),
              Divider(height: 32),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Tamsi tema'),
                      value: themeNotifier.value == ThemeMode.dark,
                      onChanged: (val) {
                        setState(() {
                          themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Pranešimai'),
                      value: _notifications,
                      onChanged: (val) {
                        setState(() => _notifications = val);
                      },
                    ),
                  ],
                ),
              ),
              _buildAchievements(),
              if (_isWeb) ...[
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Web versijos informacija',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ši aplikacija veikia web naršyklėje. Kai kurios funkcijos gali būti ribotos arba neveikti taip, kaip mobiliuose įrenginiuose.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 