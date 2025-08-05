import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryManager {
  static const String _memoryKey = 'ally_user_memory';
  
  String _getUserKey(String userId) {
    final bytes = utf8.encode('ally_$userId');
    final digest = sha256.convert(bytes);
    return 'user_${digest.toString().substring(0, 16)}';
  }
  
  Future<Map<String, dynamic>> _loadUserMemory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(userId);
    final memoryJson = prefs.getString('${_memoryKey}_$userKey');
    
    if (memoryJson != null) {
      return json.decode(memoryJson);
    }
    
    return {
      'user_id_hash': sha256.convert(utf8.encode(userId)).toString().substring(0, 8),
      'created': DateTime.now().toIso8601String(),
      'last_updated': DateTime.now().toIso8601String(),
      'admin': {
        'reminders': <Map<String, dynamic>>[],
        'events': <Map<String, dynamic>>[],
        'groceries': <Map<String, dynamic>>[],
        'other_lists': <String, List<Map<String, dynamic>>>{},
      }
    };
  }
  
  Future<void> _saveUserMemory(String userId, Map<String, dynamic> memoryData) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(userId);
    memoryData['last_updated'] = DateTime.now().toIso8601String();
    await prefs.setString('${_memoryKey}_$userKey', json.encode(memoryData));
  }
  
  Future<bool> addAdminItem(String userId, String subcategory, String content, {String? listName}) async {
    final memory = await _loadUserMemory(userId);
    final admin = memory['admin'] as Map<String, dynamic>;
    final timestamp = DateTime.now().toIso8601String();
    
    if (subcategory == 'other_lists') {
      if (listName != null) {
        final otherLists = admin['other_lists'] as Map<String, dynamic>;
        if (!otherLists.containsKey(listName)) {
          otherLists[listName] = <Map<String, dynamic>>[];
        }
        (otherLists[listName] as List).add({
          'item': content,
          'added': timestamp,
        });
      } else {
        return false;
      }
    } else if (['reminders', 'events', 'groceries'].contains(subcategory)) {
      (admin[subcategory] as List).add({
        'item': content,
        'added': timestamp,
      });
    } else {
      return false;
    }
    
    await _saveUserMemory(userId, memory);
    return true;
  }
  
  Future<List<Map<String, dynamic>>> getAdminItems(String userId, String subcategory, {String? listName}) async {
    final memory = await _loadUserMemory(userId);
    final admin = memory['admin'] as Map<String, dynamic>;
    
    if (subcategory == 'other_lists') {
      if (listName != null) {
        final otherLists = admin['other_lists'] as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(otherLists[listName] ?? []);
      } else {
        return [];
      }
    } else if (['reminders', 'events', 'groceries'].contains(subcategory)) {
      return List<Map<String, dynamic>>.from(admin[subcategory] ?? []);
    }
    
    return [];
  }
  
  Future<bool> removeAdminItem(String userId, String subcategory, String itemText, {String? listName}) async {
    final memory = await _loadUserMemory(userId);
    final admin = memory['admin'] as Map<String, dynamic>;
    
    if (subcategory == 'other_lists' && listName != null) {
      final otherLists = admin['other_lists'] as Map<String, dynamic>;
      if (otherLists.containsKey(listName)) {
        final items = otherLists[listName] as List;
        final originalLength = items.length;
        items.removeWhere((item) => item['item'] == itemText);
        if (items.length < originalLength) {
          await _saveUserMemory(userId, memory);
          return true;
        }
      }
    } else if (['reminders', 'events', 'groceries'].contains(subcategory)) {
      final items = admin[subcategory] as List;
      final originalLength = items.length;
      items.removeWhere((item) => item['item'] == itemText);
      if (items.length < originalLength) {
        await _saveUserMemory(userId, memory);
        return true;
      }
    }
    
    return false;
  }
  
  Future<bool> clearAdminSubcategory(String userId, String subcategory, {String? listName}) async {
    final memory = await _loadUserMemory(userId);
    final admin = memory['admin'] as Map<String, dynamic>;
    
    if (subcategory == 'other_lists' && listName != null) {
      final otherLists = admin['other_lists'] as Map<String, dynamic>;
      if (otherLists.containsKey(listName)) {
        otherLists[listName] = <Map<String, dynamic>>[];
        await _saveUserMemory(userId, memory);
        return true;
      }
    } else if (['reminders', 'events', 'groceries'].contains(subcategory)) {
      admin[subcategory] = <Map<String, dynamic>>[];
      await _saveUserMemory(userId, memory);
      return true;
    }
    
    return false;
  }
  
  Future<Map<String, dynamic>> getAllAdminData(String userId) async {
    final memory = await _loadUserMemory(userId);
    return memory['admin'] as Map<String, dynamic>;
  }
}
