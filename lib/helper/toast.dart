/*
 * @Author: Levi Li
 * @Date: 2024-06-03 10:17:50
 * @description: 主要用于统一fluttertoast的类型、样式
 */
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showToast(
    String message, {
    String length = 'short',
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    Toast toastLength =
        length == 'long' ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT;
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 20.0,
    );
  }
}
