import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onTokenChanged;

  SettingsPage({required this.onTokenChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _tokenController = TextEditingController();
  TextEditingController _timeYellowController = TextEditingController();
  TextEditingController _timeRedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _tokenController.text = prefs.getString('accessToken') ?? '';
    _timeYellowController.text =
        prefs.getString('timeYellow') ?? '5'; // Default to 5 minutes
    _timeRedController.text =
        prefs.getString('timeRed') ?? '10'; // Default to 10 minutes
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', _tokenController.text);
    await prefs.setString('timeYellow', _timeYellowController.text);
    await prefs.setString('timeRed', _timeRedController.text);
    widget.onTokenChanged(); // Notify that settings have changed
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child:
                  Text('Account', style: Theme.of(context).textTheme.headline6),
            ),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Access Token',
                border:
                    OutlineInputBorder(), // Adds border around the TextField
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15), // Padding inside the TextField
              ),
              onSubmitted: (value) => _saveSettings(),
            ),
            SizedBox(height: 20), // Spacing between sections
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Time Indicators',
                  style: Theme.of(context).textTheme.headline6),
            ),
            _buildNumericInput(
                'Yellow Indicator (minutes)', _timeYellowController),
            SizedBox(height: 10), // Spacing between fields
            _buildNumericInput('Red Indicator (minutes)', _timeRedController),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
      keyboardType: TextInputType.number,
      onSubmitted: (value) => _saveSettings(),
    );
  }
}
