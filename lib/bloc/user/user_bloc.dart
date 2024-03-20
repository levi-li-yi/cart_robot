/*
 * @Author: Levi Li
 * @Date: 2024-03-15 11:47:06
 * @description: 
 */
import 'package:bloc/bloc.dart';

import 'package:cart/sqflite/repository/user_repository.dart';
import 'package:cart/service/user_service.dart';
import 'package:cart/bloc/base_state.dart';

part 'user_state.dart';
part 'user_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;
  final UserRepository userRepository;

  UserBloc(this.userService, this.userRepository) : super(UserState().init()) {
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
      emit(state.clone());
    } catch (_) {
      print('_getUserList error');
    }
  }
}
