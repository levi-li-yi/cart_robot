/*
 * @Author: Levi Li
 * @Date: 2024-03-13 09:53:35
 * @description: 
 */
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cart/screens/home_screen.dart';
import 'package:cart/helper/path.dart';
import 'package:cart/helper/platform.dart';
import 'package:cart/constant/database_constants.dart';
import 'package:cart/helper/logger.dart';
import 'package:cart/helper/database.dart';
import 'package:cart/helper/env.dart';
import 'package:cart/helper/http.dart' as http;

// user bloc、repository、service
import 'package:cart/bloc/user/user_bloc.dart';
import 'package:cart/sqflite/repository/user_repository.dart';
import 'package:cart/service/user_service.dart';
// setting bloc、repository
import 'package:cart/bloc/setting/setting_bloc.dart';
import 'package:cart/sqflite/repository/setting_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  http.HttpClient.init();

  // 环境配置
  Config? config;
  config = getEnv();
  print('config ${config.appMode}');

  // 初始化路径，获取到系统相关的文档、缓存目录
  await PathHelper().init();

  // 桌面端数据库初始化
  if (PlatformTool.isWeb()) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (PlatformTool.isLinux() ||
      PlatformTool.isIOS() ||
      PlatformTool.isWindows()) {
    sqfliteFfiInit();
    // 设置数据库路径
    databaseFactory = databaseFactoryFfi;
    var path = absolute(join(PathHelper().getHomePath, 'database'));
    databaseFactory.setDatabasesPath(path);
  }

  // 连接数据库
  final db = await databaseFactory.openDatabase(
    'system.db',
    options: OpenDatabaseOptions(
      version: databaseSchemaVersion,
      // 数据库第一次创建时的回调
      onCreate: onCreateDatabase,
      // 数据库升级时的回调
      // onUpgrade: (db, oldVersion, newVersion) async {},
      onOpen: (db) {
        Logger.instance.i('数据库存储路径：${db.path}');
      },
    ),
  );

  // 设置状态与持久化
  final SettingRepository settingRepository = SettingRepository(db);
  // 用户状态与持久化
  final UserRepository userRepository = UserRepository(db);
  final UserService userService = UserService();

  runApp(MultiBlocProvider(
    // 在全局一次性注入多个Bloc或Cubit实例
    providers: [
      BlocProvider<SettingBloc>(
        create: (BuildContext context) => SettingBloc(settingRepository),
      ),
      BlocProvider<UserBloc>(
        create: (BuildContext context) => UserBloc(userService, userRepository),
      ),
    ],
    child: const MyApp(),
  ));
}

final GoRouter _router = GoRouter(routes: <RouteBase>[
  GoRoute(
    path: '/',
    builder: (BuildContext context, GoRouterState state) {
      return const HomePage(title: '首页');
    },
  ),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        return MaterialApp.router(
          theme: createLightThemeData(),
          darkTheme: createDarkThemeData(),
          themeMode: state.theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            // 指定本地化的字符串和一些其他的值
            GlobalMaterialLocalizations.delegate,
            // 对应的Cupertino风格
            GlobalCupertinoLocalizations.delegate,
            // 指定默认的文本排列方向, 由左到右或由右到左
            GlobalWidgetsLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          title: 'Cart Robot',
          routerConfig: _router,
        );
      },
    );
  }
}

// 自定义明亮主题
ThemeData createLightThemeData() {
  return ThemeData.light().copyWith();
}

// 自定义暗色主题
ThemeData createDarkThemeData() {
  return ThemeData.dark().copyWith();
}
