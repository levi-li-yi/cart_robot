/*
 * @Author: Levi Li
 * @Date: 2024-03-29 16:10:37
 * @description: 
 * 自定义主题属性：可以定义一些不在 ThemeData 中的属性，诸如自定义组件的默认样式等。
 * 更好的主题可扩展性：可以方便地向现有主题添加新属性而不影响原有的主题结构。
 * 更加细粒度的主题控制：通过扩展主题，可以更精细地控制应用的视觉表现。
 */
import 'dart:ui';
import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    this.backgroundContainerColor,
  });
  // 应用根容器背景色
  final Color? backgroundContainerColor;

  // 线性插值，平滑过渡主题切换
  @override
  ThemeExtension<CustomColors> lerp(
    covariant ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) {
      return this;
    }

    return CustomColors(
      backgroundContainerColor: Color.lerp(
          backgroundContainerColor, other.backgroundContainerColor, t),
    );
  }

  // 明亮主题
  static const light = CustomColors(
    backgroundContainerColor: Color.fromARGB(255, 234, 234, 234),
  );

  // 暗色主题
  static const dark = CustomColors(
    backgroundContainerColor: Color.fromARGB(255, 41, 41, 41),
  );

  // 扩展主题复制
  @override
  ThemeExtension<CustomColors> copyWith({
    Color? backgroundContainerColor,
  }) {
    return CustomColors(
      backgroundContainerColor:
          backgroundContainerColor ?? this.backgroundContainerColor,
    );
  }
}
