import 'dart:convert';
import 'package:check_yourself/model/checklist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistStorage {
  static const String _keyPrefix = 'checklists';

  static Future<void> saveEditedChecklist(ChecklistItem editedChecklist) async {
    final prefs = await SharedPreferences.getInstance();
    List<ChecklistItem> existingChecklists = await getAllChecklists();

    int index = existingChecklists
        .indexWhere((item) => item.title == editedChecklist.title);

    if (index != -1) {
      existingChecklists[index] = editedChecklist;

      final jsonList = existingChecklists.map((item) => item.toJson()).toList();

      await prefs.setString('checklists', jsonEncode(jsonList));
    }
  }

  static Future<void> saveChecklist(ChecklistItem checklistItem) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('checklists');
    List<dynamic> jsonList = jsonString != null ? jsonDecode(jsonString) : [];

    int existingIndex = -1;
    for (int i = 0; i < jsonList.length; i++) {
      final item = jsonList[i];
      if (item['title'] == checklistItem.title) {
        existingIndex = i;
        break;
      }
    }
    if (existingIndex != -1) {
      jsonList[existingIndex] = checklistItem.toJson();
    } else {
      jsonList.add(checklistItem.toJson());
    }

    await prefs.setString('checklists', jsonEncode(jsonList));
  }

  static Future<ChecklistItem?> getChecklist(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$title';
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return ChecklistItem.fromJson(jsonMap);
    }
    return null;
  }

  static Future<List<ChecklistItem>> getAllChecklists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPrefix);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => ChecklistItem.fromJson(item)).toList();
    }
    return [];
  }
}
