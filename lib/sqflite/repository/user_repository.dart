/*
 * @Author: Levi Li
 * @Date: 2024-03-14 17:55:10
 * @description: 
 */
import 'package:sqflite/sqflite.dart';
import 'package:cart/sqflite/model/user_model.dart';

class UserRepository {
  final Database db;

  UserRepository(this.db);

  // 获取用户列表
  Future<List<User>> getUsers() async {
    final List<Map<String, dynamic>> maps = await db.query('user');
    return List.generate(maps.length, (index) {
      return User.fromJson(maps[index]);
    });
  }

  // 添加用户
  Future<void> insertUser(User user) async {
    await db.insert(
      'user',
      user.toJson(),
      // 插入的数据条目与已存在的条目发生冲突时，覆盖数据库中的条目
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 根据id获取指定用户
  Future<User?> getUserById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'id=?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  // 删除用户
  Future<void> deleteUserById(int id) async {
    await db.delete('user', where: 'id  = ?', whereArgs: [id]);
  }
}
