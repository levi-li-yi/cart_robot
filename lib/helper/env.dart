/*
 * @Author: Levi Li
 * @Date: 2024-03-19 13:42:04
 * @description: 
 */
import 'package:cart/config/config_model.dart';
import 'package:cart/config/dev_config.dart';
import 'package:cart/config/build_server_config.dart';
import 'package:cart/config/build_local_config.dart';
import 'package:cart/config/build_hybrid_config.dart';

export 'package:cart/config/config_model.dart';

Config getEnv() {
  // 环境配置
  Config config = DevConfig();
  const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  if (env == 'dev') {
    config = DevConfig();
  } else if (env == 'server') {
    config = BuildServerConfig();
  } else if (env == 'local') {
    config = BuildLocalConfig();
  } else if (env == 'hybrid') {
    config = BuildHybridConfig();
  }
  return config;
}
