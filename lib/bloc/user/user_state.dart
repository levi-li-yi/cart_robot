/*
 * @Author: Levi Li
 * @Date: 2024-03-15 11:47:22
 * @description: 
 * 注意：引入Equatable的对象值相等性比较，目的是：
 * 在状态的属性值没有改变时，不重新构建 Widget，以优化性能，避免不必要的 UI 重绘
 */

part of 'user_bloc.dart';

class UserState extends BaseState {
  // 初始化
  UserState init() {
    return UserState()
      ..netState = NetState.loading
      ..hasMore = false
      ..isNetworkFinished = false
      ..dataList = []
      ..netCount = 0;
  }

  // 数据更新
  UserState clone() {
    return UserState()
      ..netState = netState
      ..hasMore = hasMore
      ..isNetworkFinished = isNetworkFinished
      ..dataList = dataList
      ..netCount = netCount;
  }
}
