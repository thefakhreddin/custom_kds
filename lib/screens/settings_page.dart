import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onSaved;

  SettingsPage({required this.onSaved});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    _tokenController.text = token ?? '';
  }

  Future<void> _saveToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', _tokenController.text);
    widget.onSaved(); // Callback to refresh data on home screen
    Navigator.pop(context); // Pop back to the home screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(labelText: 'Access Token'),
            ),
            ElevatedButton(
              onPressed: _saveToken,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
