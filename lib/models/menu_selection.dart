import 'package:flutter/material.dart';

class MenuSelectionModel with ChangeNotifier {
  Set<String> _selectedItems = {};

  void addItem(String item) {
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeItem(String item) {
    _selectedItems.remove(item);
    notifyListeners();
  }

  bool isItemSelected(String item) {
    return _selectedItems.contains(item);
  }

  Set<String> get selectedItems => _selectedItems;

  void selectAll(List<String> items) {
    _selectedItems.addAll(items);
    notifyListeners();
  }

  void deselectAll() {
    _selectedItems.clear();
    notifyListeners();
  }
}
