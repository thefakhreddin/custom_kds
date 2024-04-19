import 'package:flutter/material.dart';

class MenuItemsScreen extends StatefulWidget {
  final List<String> menuItems;

  MenuItemsScreen({Key? key, required this.menuItems}) : super(key: key);

  @override
  _MenuItemsScreenState createState() => _MenuItemsScreenState();
}

class _MenuItemsScreenState extends State<MenuItemsScreen> {
  late List<bool> _selected; // Declare as late

  @override
  void initState() {
    super.initState();
    // Initialize _selected based on the length of menuItems
    _selected = List<bool>.filled(widget.menuItems.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.menuItems.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(widget.menuItems[index]),
          tileColor: Colors.white,
          value: _selected[index],
          onChanged: (bool? value) {
            setState(() {
              _selected[index] = value!;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
    );
  }
}
