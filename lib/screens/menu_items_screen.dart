import 'package:flutter/material.dart';

class MenuItemsScreen extends StatelessWidget {
  final List<String> menuItems;

  MenuItemsScreen({Key? key, required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(menuItems[index]),
          tileColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        );
      },
    );
  }
}
