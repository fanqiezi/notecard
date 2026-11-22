import 'package:material_ui/material_ui.dart';

/// 间距系统 —— 制作文档 5.6：只用 4/8/12/16/24/32 六档。
abstract final class Gap {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// 页边距
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: l, vertical: l);

  /// 卡片内边距
  static const EdgeInsets card = EdgeInsets.all(l);
}

/// 圆角 —— 小元件 8 / 卡片 12 / 弹层与主按钮 16。
abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius button = BorderRadius.all(Radius.circular(lg));
}

/// 动效时长 —— 短 150 / 中 250 / 长 400（制作文档 5.6）。
abstract final class Motion {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration long = Duration(milliseconds: 400);

  static const Curve standard = Curves.easeOutCubic;

  /// 答题反馈停留：正确 600 / 错误 800 / 超时 900（制作文档 5.3）。
  static const Duration feedbackCorrect = Duration(milliseconds: 600);
  static const Duration feedbackWrong = Duration(milliseconds: 800);
  static const Duration feedbackTimeout = Duration(milliseconds: 900);
}
