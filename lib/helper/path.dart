/*
 * @Author: Levi Li
 * @Date: 2024-03-13 15:23:49
 * @description: 
 */
import 'dart:io' show Directory, Platform;
import 'package:path_provider/path_provider.dart';

import 'package:cart/helper/platform.dart';

class PathHelper {
  // 该目录适合存储用户生成的数据或应用无法再次创建的文件。这个目录中的文件会在用户备份他们的设备时被备份。
  late final String cachePath;
  // 个存放不是用户生成的数据，但对应用运行来说非常重要的文件的地方。比如，数据库、配置文件等
  late final String documentsPath;
  // 存放应用暂时性文件，这些文件可以在应用运行时存在，但在设备重启后可以被清空
  late final String supportPath;

  init() async {
    // 存放不必备份的临时文件路径
    try {
      cachePath =
          (await getApplicationCacheDirectory()).path.replaceAll('\\', '/');
    } catch (e) {
      cachePath = '';
    }

    // 当前应用可以访问的路径，保存应用的个人设置、用户数据或者其他需要持久保存的信息。
    try {
      documentsPath =
          (await getApplicationDocumentsDirectory()).path.replaceAll('\\', '/');
    } catch (e) {
      documentsPath = '';
    }

    // 非用户生成的数据文件存储路径
    try {
      supportPath =
          (await getApplicationSupportDirectory()).path.replaceAll('\\', '/');
    } catch (e) {
      supportPath = '';
    }

    //创建cart目录
    try {
      Directory(getHomePath).create(recursive: true);
    } catch (e) {
      print('创建 $getHomePath 目录失败');
    }
  }

  // 应用根目录
  String get getHomePath {
    if (PlatformTool.isMacOS() || PlatformTool.isLinux()) {
      return '${Platform.environment['Home'] ?? ''}/.cart'
          .replaceAll('\\', '/');
    } else if (PlatformTool.isWindows()) {
      return '${Platform.environment['UserProfile'] ?? ''}/.cart'
          .replaceAll('\\', '/');
    } else if (PlatformTool.isAndroid() || PlatformTool.isIOS()) {
      return '$documentsPath/.cart'.replaceAll('\\', '/');
    }
    return '.cart';
  }

  String get getLogfilePath {
    return '$getHomePath/cart.log';
  }

  String get getCachePath {
    return getHomePath;
  }

  // path helper单例
  static final PathHelper _instance = PathHelper._internal();
  PathHelper._internal();
  factory PathHelper() {
    return _instance;
  }

  Map<String, String> toMap() {
    return {
      'cachePath': cachePath,
      'cachePathReal': getCachePath,
      'documentsPath': documentsPath,
      'supportPath': supportPath,
      'homePath': getHomePath,
      'logfilePath': getLogfilePath,
    };
  }
}
