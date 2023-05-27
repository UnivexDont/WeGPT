import 'dart:ui' as ui;

class Device {
  static double get width {
    final size = ui.window.physicalSize;
    final width = size.width / ui.window.devicePixelRatio;
    return width;
  }

  static double get height {
    final size = ui.window.physicalSize;
    final height = size.height / ui.window.devicePixelRatio;
    return height;
  }
}
