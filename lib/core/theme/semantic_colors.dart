import 'package:material_ui/material_ui.dart';

/// 语义色 —— 制作文档 5.6 的 18 组 token 中，ColorScheme 覆盖不到的部分。
///
/// 之所以单独抽出来：成功/警告/错误底色这几个语义色在 Material 的 ColorScheme 里
/// 没有对应槽位（只有 error），散落在各处 hardcode 会让暗色模式没法统一换。
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.errorSoft,
    required this.keyWhite,
    required this.keyBlack,
    required this.keyPressed,
    required this.streak,
  });

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color errorSoft;
  final Color keyWhite;
  final Color keyBlack;
  final Color keyPressed;
  final Color streak;

  static const light = SemanticColors(
    success: Color(0xFF15803D),
    successSoft: Color(0xFFDCFCE7),
    warning: Color(0xFFB45309),
    errorSoft: Color(0xFFFEE4E2),
    keyWhite: Color(0xFFFFFFFF),
    keyBlack: Color(0xFF1F242B),
    keyPressed: Color(0xFFD6E0F7),
    streak: Color(0xFFF59E0B),
  );

  static const dark = SemanticColors(
    success: Color(0xFF4ADE80),
    successSoft: Color(0xFF14351F),
    warning: Color(0xFFFBBF24),
    errorSoft: Color(0xFF3A1A18),
    keyWhite: Color(0xFFE9ECF1),
    keyBlack: Color(0xFF0B0D10),
    keyPressed: Color(0xFFC7D2E6),
    streak: Color(0xFFFBBF24),
  );

  @override
  SemanticColors copyWith({
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? errorSoft,
    Color? keyWhite,
    Color? keyBlack,
    Color? keyPressed,
    Color? streak,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      errorSoft: errorSoft ?? this.errorSoft,
      keyWhite: keyWhite ?? this.keyWhite,
      keyBlack: keyBlack ?? this.keyBlack,
      keyPressed: keyPressed ?? this.keyPressed,
      streak: streak ?? this.streak,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      keyWhite: Color.lerp(keyWhite, other.keyWhite, t)!,
      keyBlack: Color.lerp(keyBlack, other.keyBlack, t)!,
      keyPressed: Color.lerp(keyPressed, other.keyPressed, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
    );
  }
}

extension SemanticColorsX on BuildContext {
  SemanticColors get semantic => Theme.of(this).extension<SemanticColors>()!;
}
