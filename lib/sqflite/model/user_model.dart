/*
 * @Author: Levi Li
 * @Date: 2024-03-14 14:39:39
 * @description: 用户数据model
 */
class User {
  final int id;
  final String name;
  final int? age;
  final String? gender;

  User({required this.id, required this.name, this.age, this.gender});

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
    };
  }

  // fromJson
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
    );
  }
}
