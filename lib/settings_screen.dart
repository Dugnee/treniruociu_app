import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkTheme = false;
  bool _notifications = true;
  final _nameController = TextEditingController();
  bool _saving = false;
  String? _photoUrl;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    print('DEBUG: Firebase user: \\${_user?.uid} displayName=\\${_user?.displayName} photoURL=\\${_user?.photoURL}');
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

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Nustatymai')),
        body: Center(child: Text('Vartotojas neprisijungęs')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Nustatymai')),
      body: ListView(
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
          SwitchListTile(
            title: Text('Tamsi tema'),
            value: _darkTheme,
            onChanged: (val) {
              setState(() => _darkTheme = val);
              // Čia gali pridėti temų keitimo logiką visam app
            },
          ),
          SwitchListTile(
            title: Text('Pranešimai'),
            value: _notifications,
            onChanged: (val) {
              setState(() => _notifications = val);
              // Čia gali pridėti pranešimų valdymo logiką
            },
          ),
          // Gali pridėti daugiau nustatymų čia
        ],
      ),
    );
  }
} 