/*
 * @Author: Levi Li
 * @Date: 2024-03-15 15:54:15
 * @description: 
 */
// 页面加载状态枚举
enum NetState {
  // 初始状态
  initialize,
  // 加载中
  loading,
  // 失败页面
  error404,
  // 错误时显示刷新
  errorRefresh,
  // 错误空数据
  errorEmpty,
  // 超时
  timeout,
  // 加载成功
  success,
}

abstract class BaseState {
  // 页面加载状态
  NetState netState = NetState.loading;
  // 是否有更多数据
  bool? hasMore;
  // 接口请求是否完成
  bool? isNetworkFinished;
  // 列表数据结果
  List? dataList = [];
  // 对象数据结果
  Object? data;
  // 网络加载次数
  int? netCount;
}
