import 'dart:io';
import 'package:logger/logger.dart' as logger;

import 'package:cart/helper/path.dart';
import 'package:cart/helper/platform.dart';

class Logger {
  static final logger.Logger instance = logger.Logger(
    printer: logger.PrettyPrinter(
      lineLength: 120,
      printTime: true,
      colors: false,
      noBoxingByDefault: true,
    ),
    output: logger.MultiOutput(
      [
        logger.ConsoleOutput(),
        if (!PlatformTool.isWeb())
          logger.FileOutput(
            file: File(PathHelper().getLogfilePath),
            overrideExisting: true,
          ),
      ],
    ),
  );
}
