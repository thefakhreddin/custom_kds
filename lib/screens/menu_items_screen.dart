import 'package:flutter/material.dart';
import 'package:newkds/models/menu_selection.dart'; // Make sure path is correct
import 'package:provider/provider.dart';

class MenuItemsScreen extends StatefulWidget {
  final List<String> menuItems;

  MenuItemsScreen({Key? key, required this.menuItems}) : super(key: key);

  @override
  _MenuItemsScreenState createState() => _MenuItemsScreenState();
}

class _MenuItemsScreenState extends State<MenuItemsScreen> {
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<bool>.filled(widget.menuItems.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu Items"),
        actions: [
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () {
              Provider.of<MenuSelectionModel>(context, listen: false)
                  .selectAll(widget.menuItems);
            },
            tooltip: "Select All",
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              Provider.of<MenuSelectionModel>(context, listen: false)
                  .deselectAll();
            },
            tooltip: "Deselect All",
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.menuItems.length,
        itemBuilder: (context, index) {
          var isSelected = Provider.of<MenuSelectionModel>(context)
              .isItemSelected(widget.menuItems[index]);
          return CheckboxListTile(
            title: Text(widget.menuItems[index]),
            tileColor: Colors.white,
            value: isSelected,
            onChanged: (bool? value) {
              if (value!) {
                Provider.of<MenuSelectionModel>(context, listen: false)
                    .addItem(widget.menuItems[index]);
              } else {
                Provider.of<MenuSelectionModel>(context, listen: false)
                    .removeItem(widget.menuItems[index]);
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          );
        },
      ),
    );
  }
}
