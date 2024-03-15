/*
 * @Author: Levi Li
 * @Date: 2024-03-15 11:47:14
 * @description: 
 */
part of 'user_bloc.dart';

abstract class UserEvent {}

// 获取用户列表
class GetUserListEvent extends UserEvent {
  final int pageNo;
  final int pageSize;

  GetUserListEvent(this.pageNo, this.pageSize);
}

// 删除用户
class DeleteUserEvent extends UserEvent {
  final int id;

  DeleteUserEvent(this.id);
}
