/*
 * @Author: Levi Li
 * @Date: 2024-03-15 12:13:33
 * @description: 
 */
import 'package:cart/sqflite/model/user_model.dart';

class UserService {
  // 模拟获取用户数据
  Future<List<User>> fetchUsers(int pageNo, int pageSize) async {
    return Future.delayed(const Duration(seconds: 2), () {
      return [
        User(id: 1, name: 'user1', age: 18, gender: 'male'),
        User(id: 2, name: 'user2', age: 18, gender: 'female'),
        User(id: 3, name: 'user3', age: 18, gender: 'female'),
      ];
    });
  }

  // 模拟删除用户数据
  Future<bool> deleteUserById(int id) async {
    return Future.delayed(const Duration(seconds: 2), () {
      return true;
    });
  }
}
