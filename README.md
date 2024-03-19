<!--
 * @Author: Levi Li
 * @Date: 2024-03-13 17:24:06
 * @description: 
-->
# cart_robot

## dependencies依赖安装
### flutter pub add xxx

## dev_dependencies依赖安装
### flutter pub add --dev xxx

## 依赖安装
### flutter pub get

## 工程目录结构
- cart_robot
  - assets
  - lib
    - bloc/          # bloc数据状态
    - constant/      # 常量
    - di/            # 依赖注入
    - generated/     # 生成的文件
    - helper/        # 工具类
    - lang/          # 语言包
    - repository/    # SQLite数据库操作
    - routes/        # 路由
    - screens/       # 页面
    - service/       # http请求接口
    - widgets/       # 自定义组件
  

## 自动生成arb->app_localization.dart文件
### 命令：flutter gen-l10n


## 数据管理的三种策略
- 从服务器获取和存储数据(Server)
  - server
  - bloc
  - 业务页面
- 从本地SQLite数据库获取和存储数据(Local)
  - SQLite
  - bloc
  - 业务页面
- 从第三方服务获取和存储数据(Hybrid)
  - 字段转义
  - third server
  - SQLite(实时调用三方服务失败时需要，定时推送需要)
  - bloc
  - 业务页面


<!-- run dev -->
## run dev
flutter run --dart-define=ENV=dev
## 打包成在线版
flutter build apk --dart-define=ENV=server
## 打包成离线版
flutter build apk --dart-define=ENV=local
## 打包成第三方服务版
flutter build apk --dart-define=ENV=hybrid
