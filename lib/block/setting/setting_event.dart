/*
 * @Author: Levi Li
 * @Date: 2024-03-15 10:14:59
 * @description: 
 */
part of 'setting_bloc.dart';

// 申明不可变类
@immutable
abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

// 设置数据加载事件
class SettingLoadEvent extends SettingEvent {
  final String? version;
  final String? locale;

  const SettingLoadEvent({this.version, this.locale});

  @override
  List<Object?> get props => [version, locale];
}

// 更新设置数据事件
class SettingUpdateEvent extends SettingEvent {
  final String? version;
  final String? locale;

  const SettingUpdateEvent({this.version, this.locale});

  @override
  List<Object?> get props => [version, locale];
}
