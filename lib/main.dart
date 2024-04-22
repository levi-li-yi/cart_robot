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
import 'package:camera/camera.dart';

import 'package:cart/helper/path.dart';
import 'package:cart/helper/platform.dart';
import 'package:cart/constant/database_constants.dart';
import 'package:cart/helper/logger.dart';
import 'package:cart/helper/database.dart';
import 'package:cart/helper/env.dart';
import 'package:cart/helper/http.dart' as http;

// theme
import 'package:cart/theme/custom_theme.dart';
import 'package:cart/theme/theme.dart';
// l10n
import 'package:cart/generated/l10n.dart';

// widgets
import 'package:cart/widgets/app_scaffold.dart';
import 'package:cart/widgets/transition_resolver.dart';
// pages
import 'package:cart/screens/home_screen.dart';

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
    child: MyApp(),
  ));
}

List<RouteBase> _getRoutes(GlobalKey<NavigatorState> key) {
  return [
    GoRoute(
      path: '/home',
      parentNavigatorKey: key,
      pageBuilder: (context, state) => transitionResolver(HomeScreen()),
      // builder: (BuildContext context, GoRouterState state) {
      //   return const HomePage(title: '首页');
      // },
    ),
  ];
}

class MyApp extends StatefulWidget {
  // 页面路由
  late final GoRouter _router;

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  MyApp({super.key}) {
    _router = GoRouter(
        initialLocation: '/home',
        navigatorKey: _rootNavigatorKey,
        routes: [
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) {
              return AppScaffold(
                child: child,
              );
            },
            routes: _getRoutes(_shellNavigatorKey),
          ),
        ]);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        // final appTheme = context.watch<AppTheme>();

        return MaterialApp.router(
          theme: createLightThemeData(),
          darkTheme: createDarkThemeData(),
          themeMode: state.theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            S.delegate,
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
          routerConfig: widget._router,
        );
      },
    );
  }
}

// 自定义明亮主题
ThemeData createLightThemeData() {
  return ThemeData.light().copyWith(
    extensions: [CustomColors.light],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: PlatformTool.isMacOS()
        ? IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          )
        : null,
    dividerColor: Colors.transparent,
    dialogBackgroundColor: Colors.white,
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 9, 185, 85),
      ),
    ),
  );
}

// 自定义暗色主题
ThemeData createDarkThemeData() {
  return ThemeData.dark().copyWith(
    extensions: [CustomColors.dark],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: PlatformTool.isMacOS()
        ? IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          )
        : null,
    dividerColor: Colors.transparent,
    dialogBackgroundColor: const Color.fromARGB(255, 48, 48, 48),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 9, 185, 85),
      ),
    ),
  );
}
