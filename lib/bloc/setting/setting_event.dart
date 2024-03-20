/*
 * @Author: Levi Li
 * @Date: 2024-03-15 10:14:59
 * @description: 
 */
part of 'setting_bloc.dart';

abstract class SettingEvent {}

class ThemeChangedEvent extends SettingEvent {
  final String theme;

  ThemeChangedEvent({required this.theme});
}
