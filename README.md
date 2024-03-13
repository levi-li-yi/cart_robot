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
