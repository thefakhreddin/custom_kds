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
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.menuItems; // Initialize filtered list
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.menuItems
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                var isSelected = Provider.of<MenuSelectionModel>(context)
                    .isItemSelected(_filteredItems[index]);
                return CheckboxListTile(
                  title: Text(_filteredItems[index]),
                  tileColor: Colors.white,
                  value: isSelected,
                  onChanged: (bool? value) {
                    if (value!) {
                      Provider.of<MenuSelectionModel>(context, listen: false)
                          .addItem(_filteredItems[index]);
                    } else {
                      Provider.of<MenuSelectionModel>(context, listen: false)
                          .removeItem(_filteredItems[index]);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Don't forget to dispose the controller!
    super.dispose();
  }
}
