/*
 * @Author: Levi Li
 * @Date: 2024-03-15 10:14:37
 * @description: 
 */
import 'package:bloc/bloc.dart';
import 'package:cart/sqflite/repository/setting_repository.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingRepository settingRepository;

  SettingBloc(this.settingRepository) : super(SettingState(theme: 'light')) {
    // 主题切换
    on<ThemeChangedEvent>((event, emit) async {
      await settingRepository.set('theme', event.theme);
      emit(SettingState(theme: event.theme));
    });

    _init();
  }

  // 初始化
  void _init() async {
    await settingRepository.loadSetting();
    String currentTheme = settingRepository.get('theme') ?? 'light';
    add(ThemeChangedEvent(theme: currentTheme));
  }
}
