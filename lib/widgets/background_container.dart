/*
 * @Author: Levi Li
 * @Date: 2024-03-29 16:52:09
 * @description: 应用背景容器
 */
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:cart/theme/custom_size.dart';
import 'package:cart/theme/custom_theme.dart';
// import 'package:cart/widgets/image.dart';

class BackgroundContainer extends StatefulWidget {
  final Widget child;
  final bool? useGradient;
  final bool enabled;
  final bool pureColorMode;
  final double maxWidth;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.useGradient,
    this.enabled = true,
    this.pureColorMode = false,
    this.maxWidth = CustomSize.maxWindowSize,
  });

  @override
  State<BackgroundContainer> createState() => _BackgroundContainerState();
}

class _BackgroundContainerState extends State<BackgroundContainer> {
  final int opacity = 180;
  double? blur = double.tryParse('15.0');

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onHorizontalDragUpdate: (details) {
        int sensitivity = 10;
        if (details.delta.dx > sensitivity) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth > 0 ? widget.maxWidth : double.infinity,
          ),
          child: _buildChild(customColors),
        ),
      ),
    );
  }

  Widget _buildChild(CustomColors customColors) {
    if (widget.pureColorMode) {
      return Container(
        height: double.infinity,
        decoration: _createPureColorDecoration(customColors),
        child: widget.child,
      );
    }

    if (!widget.enabled) {
      return Container(
        height: double.infinity,
        decoration: _createTransportDecoration(),
        child: widget.child,
      );
    }

    return Container(
      decoration: _createPureColorDecoration(customColors),
      height: double.infinity,
      child: widget.child,
    );
  }

  // 纯底色容器
  BoxDecoration _createPureColorDecoration(CustomColors customColors) {
    return BoxDecoration(
      color: customColors.backgroundContainerColor,
    );
  }

  // 线性渐变底色容器
  BoxDecoration _createLinearGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(opacity, 90, 218, 196),
          Color.fromARGB(opacity, 230, 153, 38),
          Color.fromARGB(opacity, 242, 7, 213),
        ],
        transform: const GradientRotation(0.5),
      ),
    );
  }

  // 透明容器
  BoxDecoration _createTransportDecoration() {
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }
}
