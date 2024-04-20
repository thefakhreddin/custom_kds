import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function onTokenUpdate;

  SettingsPage({Key? key, required this.onTokenUpdate}) : super(key: key);

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
    _tokenController.text = prefs.getString('accessToken') ?? '';
  }

  Future<void> _saveToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', _tokenController.text);
    widget.onTokenUpdate(); // Call the callback after the token is saved
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
