import 'package:material_ui/material_ui.dart';

import 'semantic_colors.dart';

/// 主题 —— 制作文档 5.6 的 token 落地。
///
/// 只做两套（浅色/暗色），跟随系统；不给用户自定义色板，减少一次设置项。
abstract final class AppTheme {
  static const Color _primary = Color(0xFF2F6BFF);
  static const Color _primaryDark = Color(0xFF7AA2FF);
  static const Color _bgLight = Color(0xFFF7F8FA);
  static const Color _bgDark = Color(0xFF0F1115);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1A1D22);
  static const Color _dividerLight = Color(0xFFE4E7EC);
  static const Color _dividerDark = Color(0xFF2B3037);
  static const Color _textPrimaryLight = Color(0xFF101828);
  static const Color _textPrimaryDark = Color(0xFFF2F4F7);
  static const Color _textSecondaryLight = Color(0xFF5B616E);
  static const Color _textSecondaryDark = Color(0xFFA7AEB8);
  static const Color _error = Color(0xFFD92D20);
  static const Color _errorDark = Color(0xFFFF7B72);

  static ThemeData light() => _build(
        brightness: Brightness.light,
        seed: _primary,
        background: _bgLight,
        surface: _surfaceLight,
        divider: _dividerLight,
        text: _textPrimaryLight,
        textSecondary: _textSecondaryLight,
        error: _error,
        semantic: SemanticColors.light,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        seed: _primaryDark,
        background: _bgDark,
        surface: _surfaceDark,
        divider: _dividerDark,
        text: _textPrimaryDark,
        textSecondary: _textSecondaryDark,
        error: _errorDark,
        semantic: SemanticColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color seed,
    required Color background,
    required Color surface,
    required Color divider,
    required Color text,
    required Color textSecondary,
    required Color error,
    required SemanticColors semantic,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: seed,
      onPrimary: Colors.white,
      secondary: seed,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: background,
      outline: divider,
      outlineVariant: divider,
      onSurfaceVariant: textSecondary,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: text,
      onInverseSurface: surface,
      inversePrimary: seed,
      tertiary: semantic.success,
      onTertiary: Colors.white,
      tertiaryContainer: semantic.successSoft,
      onTertiaryContainer: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: divider,
      extensions: <ThemeExtension<dynamic>>[semantic],
      textTheme: _textTheme(text, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      // 选中态必须显式给色：indicator 透明 + 默认 onSecondaryContainer 在浅色下
      // 会和白色背景融在一起，选中图标直接看不见。
      navigationBarTheme: NavigationBarThemeData(
        height: 56,
        backgroundColor: surface,
        indicatorColor: seed.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(size: 22, color: selected ? seed : textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            height: 1.5,
            color: selected ? seed : textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(fontSize: 16, height: 1.5, color: text),
        subtitleTextStyle: TextStyle(fontSize: 12, height: 1.5, color: textSecondary),
        minVerticalPadding: 12,
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
    );
  }

  static TextTheme _textTheme(Color text, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(fontSize: 32, height: 1.25, fontWeight: FontWeight.w700, color: text),
      headlineMedium: TextStyle(fontSize: 32, height: 1.25, fontWeight: FontWeight.w700, color: text),
      titleLarge: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: text),
      titleMedium: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: text),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: text),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: text),
      bodySmall: TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500, color: text),
      labelSmall: TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w400, color: secondary),
    );
  }
}
