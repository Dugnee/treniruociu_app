import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  DateTime? _joinDate;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _photoUrl = _user?.photoURL;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? _user!.displayName ?? '';
        _joinDate = (data['joinDate'] as Timestamp?)?.toDate() ?? _user!.metadata.creationTime;
        _photoUrl = data['photoUrl'] ?? _user!.photoURL;
      } else {
        // If user document doesn't exist, create it
        _joinDate = _user!.metadata.creationTime;
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
          'name': _user!.displayName ?? '',
          'email': _user!.email,
          'joinDate': _joinDate,
          'photoUrl': _user!.photoURL,
        });
      }
      setState(() {});
    } catch (e) {
      print('DEBUG: Klaida kraunant vartotojo duomenis: $e');
    }
  }

  Future<String?> _compressAndEncodeImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 200,
        minHeight: 200,
        quality: 85,
      );
      return base64Encode(result!);
    } catch (e) {
      print('Klaida suspaudžiant nuotrauką: $e');
      return null;
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile == null) return;

      setState(() => _saving = true);

      // Compress and encode image
      final base64Image = await _compressAndEncodeImage(File(pickedFile.path));
      if (base64Image == null) {
        throw Exception('Nepavyko apdoroti nuotraukos');
      }

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
        'photoUrl': 'data:image/jpeg;base64,$base64Image',
      });

      setState(() {
        _photoUrl = 'data:image/jpeg;base64,$base64Image';
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profilio nuotrauka atnaujinta!')),
      );
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klaida įkeliant nuotrauką: $e')),
      );
    }
  }

  Future<void> _saveUserName() async {
    if (_user == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
        'name': _nameController.text.trim(),
      });
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vardas išsaugotas!')),
      );
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klaida išsaugant vardą: $e')),
      );
    }
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
                              ? _photoUrl!.startsWith('data:image')
                                  ? MemoryImage(base64Decode(_photoUrl!.split(',')[1]))
                                  : NetworkImage(_photoUrl!) as ImageProvider
                              : null,
                          child: (_photoUrl == null || _photoUrl!.isEmpty)
                              ? Icon(Icons.person, size: 60)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _pickAndUploadImage,
                            ),
                          ),
                        ),
                      ],
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
                    if (_joinDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Prisijungė: ${DateFormat('yyyy-MM-dd').format(_joinDate!)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
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