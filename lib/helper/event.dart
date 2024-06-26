/*
 * @Author: Levi Li
 * @Date: 2024-03-29 14:43:36
 * @description: 事件的发布订阅
 */
class GlobalEvent {
  // 单例
  static final GlobalEvent _instance = GlobalEvent._internal();
  GlobalEvent._internal();
  factory GlobalEvent() {
    return _instance;
  }

  // 事件监听器
  final Map<String, List<Function(dynamic data)>> _listeners = {};

  // 监听事件
  Function on(String event, Function(dynamic data) callback) {
    if (_listeners[event] == null) {
      _listeners[event] = [];
    }
    _listeners[event]?.add(callback);

    return () {
      _listeners[event]!.remove(callback);
    };
  }

  // 触发事件
  void emit(String event, [dynamic data]) {
    if (_listeners[event] == null) {
      return;
    }
    for (var callback in _listeners[event]!) {
      callback(data);
    }
  }
}
