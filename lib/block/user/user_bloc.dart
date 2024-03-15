import 'package:bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

import 'package:cart/sqflite/model/user_model.dart';
import 'package:cart/sqflite/repository/user_repository.dart';
import 'package:cart/service/user_service.dart';
import 'package:cart/block/base_state.dart';

part 'user.state.dart';
part 'user_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final UserService userService;

  UserBloc(this.userRepository, this.userService) : super(UserState().init()) {
    on<GetUserListEvent>(_getUserList);
  }

  // 获取用户列表
  Future<void> _getUserList(event, emit) async {
    try {
      // 请求接口
      final users = await userService.fetchUsers(event.pageNo, event.pageSize);
      // 更新数据库
      for (var user in users) {
        await userRepository.insertUser(user);
      }
      //更新数据列表
      state.dataList = users;
      print('dataList：${state.dataList.toString()}');
      // 发出更新状态
    } catch (_) {
      print('_getUserList error');
    }
  }
}
