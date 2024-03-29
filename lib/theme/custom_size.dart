/*
 * @Author: Levi Li
 * @Date: 2024-03-29 16:08:30
 * @description: 应用基础尺寸
 */
import 'package:flutter/material.dart';

import 'package:cart/helper/platform.dart';

class CustomSize {
  static const double appBarTitleSize = 16;
  static const double defaultHintTextSize = 14;
  static const double maxWindowSize = 1000;
  static const double smallWindowSize = 500;

  static double get toolbarHeight {
    if (PlatformTool.isMacOS()) {
      return kToolbarHeight + 30;
    }

    return kToolbarHeight;
  }
}
