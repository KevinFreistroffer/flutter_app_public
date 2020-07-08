import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
// import '../enums/storage.enum.dart';

// SECURE STORAGE MIGHT AS WELL REPLACE THIS
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.get(key);
  }

  Future<SharedPreferences> getInstance() async {
    return await SharedPreferences.getInstance();
  }

  // Convert type to the built_value enum
  Future<void> set(String key, String type, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (type == 'bool') {
      prefs.setBool((key), value);
    } else if (type == 'double') {
      prefs.setDouble((key), value);
    } else if (type == 'int') {
      prefs.setInt((key), value);
    } else if (type == 'String') {
      prefs.setString((key), value);
    } else if (type == 'List') {
      prefs.setStringList((key), value);
    }
  }

  Future<void> setMultiple(List<Map> data) async {
    data.forEach((d) {
      set(d['key'], d['type'], d['value']);
    });
  }

  // Convert type to the built_value enum
  Future<void> setIfDoesNotExist(String key, String type, dynamic value) async {
    if (value != null) {
      try {
        final prefs = await SharedPreferences.getInstance();

        final exists = await get(key);

        if (exists != null) {
          return;
        } else {
          if (type == 'bool') {
            prefs.setBool((key), value);
          } else if (type == 'double') {
            prefs.setDouble((key), value);
          } else if (type == 'int') {
            prefs.setInt((key), value);
          } else if (type == 'String') {
            prefs.setString((key), value);
          } else if (type == 'List') {
            prefs.setStringList((key), value);
          }
        }
      } catch (error) {
        print(error);
      }
    }
  }

  Future<void> remove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  Future<void> removeMultiple(List<String> keys) async {
    keys.forEach((key) => remove(key));
  }

  void removeAll() {
    var keys = [...Constants.SHARED_PREFS_KEYS];
    keys.forEach((key) => remove(key));
  }
}
