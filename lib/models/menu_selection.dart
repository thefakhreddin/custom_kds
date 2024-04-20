import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuSelectionModel with ChangeNotifier {
  Set<String> _selectedItems = {};

  MenuSelectionModel() {
    loadSelectedItems();
  }

  Future<void> loadSelectedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> items = prefs.getStringList('selectedItems') ?? [];
    _selectedItems = items.toSet();
    notifyListeners();
  }

  void addItem(String item) {
    _selectedItems.add(item);
    saveItems();
    notifyListeners();
  }

  void removeItem(String item) {
    _selectedItems.remove(item);
    saveItems();
    notifyListeners();
  }

  bool isItemSelected(String item) {
    return _selectedItems.contains(item);
  }

  Set<String> get selectedItems => _selectedItems;

  void selectAll(List<String> items) {
    _selectedItems.addAll(items);
    saveItems();
    notifyListeners();
  }

  void deselectAll() {
    _selectedItems.clear();
    saveItems();
    notifyListeners();
  }

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedItems', _selectedItems.toList());
  }
}
