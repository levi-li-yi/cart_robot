/*
 * @Author: Levi Li
 * @Date: 2024-03-13 15:59:16
 * @description: 
 */
import 'package:sqflite/sqflite.dart';

// 查看数据库版本
Future<String> getSQLiteVersion() async {
  // 打开临时数据库
  var database = await openDatabase(':memory:');
  try {
    var result = await database.rawQuery('SELECT sqlite_version()');
    String version = result.first['sqlite_version()'].toString();
    return version;
  } finally {
    await database.close();
  }
}

// 数据库初始化创建回调
void onCreateDatabase(db, version) async {
  // 创建一个用户基础信息表
  await db.execute(
    "CREATE TABLE user (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, sex TEXT)",
  );
}
