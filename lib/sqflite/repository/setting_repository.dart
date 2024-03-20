/*
 * @Author: Levi Li
 * @Date: 2024-03-15 10:57:45
 * @description: 
 */
import 'package:sqflite/sqflite.dart';

class SettingRepository {
  final Database db;

  SettingRepository(this.db);

  final _setting = <String, String>{};

  // 加载setting数据库数据
  // setting数据存储结构如下
  // [
  //  {'key': 'version', 'value': '1.0.0'},
  //  {'key': 'locale', 'value': 'en'},
  //  {'key': 'theme', 'value': 'light'},
  //  ...
  // ]
  Future<void> loadSetting() async {
    List<Map<String, Object?>> kvs = await db.query('setting');

    // _setting.clear();
    for (var kv in kvs) {
      _setting[kv['key'] as String] = kv['value'] as String;
    }
  }

  // 设置key、value
  Future<void> set(String key, String value) async {
    _setting[key] = value;
    final kvs = await db.query('setting', where: 'key = ?', whereArgs: [key]);
    if (kvs.isEmpty) {
      await db.insert('setting', {'key': key, 'value': value});
    } else {
      await db.update('setting', {'value': value},
          where: 'key = ?', whereArgs: [key]);
    }
  }

  // 根据key获取value
  String? get(String key) {
    return _setting[key];
  }

  // 根据key获取value，带缺省值
  String getDefault(String key, String defaultValue) {
    return _setting[key] ?? defaultValue;
  }

  // 根据key获取value，带Int缺省值
  int getDefaultInt(String key, int defaultValue) {
    return int.tryParse(_setting[key] ?? '') ?? defaultValue;
  }

  // 根据key获取value，带bool缺省值
  bool getDefaultBool(String key, bool defaultValue) {
    return _setting[key] == 'true' ? true : defaultValue;
  }

  // 根据key获取value，带double缺省值
  double getDefaultDouble(String key, double defaultValue) {
    return double.tryParse(_setting[key] ?? '') ?? defaultValue;
  }
}
