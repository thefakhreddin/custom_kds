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

  @override
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
            Text('Account', style: Theme.of(context).textTheme.headline6),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(labelText: 'Access Token'),
              onSubmitted: (value) => _saveSettings(),
            ),
            Divider(color: Colors.grey[300], thickness: 1),
            Text('Time Indicators',
                style: Theme.of(context).textTheme.headline6),
            _buildNumericInput(
                'Yellow Indicator (minutes)', _timeYellowController),
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
      ),
      keyboardType: TextInputType.number,
      onSubmitted: (value) {
        _saveSettings();
        FocusScope.of(context).unfocus(); // Hide the keyboard after input
      },
    );
  }
}
