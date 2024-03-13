/*
 * @Author: Levi Li
 * @Date: 2024-03-13 09:53:35
 * @description: 
 */
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
import 'package:path/path.dart';

import 'package:cart/screens/home_screen.dart';
import 'package:cart/helper/path.dart';
import 'package:cart/helper/platform.dart';
import 'package:cart/constant/database_constants.dart';
import 'package:cart/helper/logger.dart';
import 'package:cart/helper/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化路径，获取到系统相关的文档、缓存目录
  await PathHelper().init();

  // 桌面端数据库初始化
  if (PlatformTool.isLinux() ||
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

  runApp(const MyApp());
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
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  }
}
