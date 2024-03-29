/*
 * @Author: Levi Li
 * @Date: 2024-03-29 14:36:45
 * @description: 
 */
import 'package:flutter/services.dart';

class HapticFeedbackHelper {
  static Future<void> lightImpact() async {
    return HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() async {
    return HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() async {
    return HapticFeedback.heavyImpact();
  }
}
