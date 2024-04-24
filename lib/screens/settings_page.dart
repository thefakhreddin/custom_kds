import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsCategory { account, layout }

class SettingsPage extends StatefulWidget {
  final VoidCallback onTokenChanged;

  SettingsPage({required this.onTokenChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _tokenController = TextEditingController();
  SettingsCategory _selectedCategory = SettingsCategory.account;

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

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    widget.onTokenChanged(); // Callback to refresh data on home screen
    Navigator.pop(
        context, true); // Pop with a result indicating something was saved
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedCategory.index,
            onDestinationSelected: (index) {
              setState(() {
                _selectedCategory = SettingsCategory.values[index];
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.account_circle),
                selectedIcon: Icon(Icons.account_circle_outlined),
                label: Text('Account'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.abc),
                selectedIcon: Icon(Icons.abc_outlined),
                label: Text('Layout'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: _selectedCategory == SettingsCategory.account
                  ? _buildAccountSettings()
                  : _buildLayoutSettings(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      children: [
        TextField(
          controller: _tokenController,
          decoration: InputDecoration(
            labelText: 'Access Token',
            suffixIcon: IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                _saveToken(_tokenController.text);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          onSubmitted: _saveToken,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildLayoutSettings() {
    // Placeholder for layout settings
    return Center(
      child: Text('Layout settings will be displayed here.'),
    );
  }
}
