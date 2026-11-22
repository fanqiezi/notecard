import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/constants/note_name.dart';
import '../../../core/constants/pitch.dart';

/// 五线谱渲染 —— 制作文档 6.3。
///
/// 尺寸契约：lineGap = (可用宽 / 28).clamp(10, 20)；五线垂直居中；
/// y(step) = originY − step × lineGap / 2（originY 为最下那条线）。
class StaffCanvas extends StatelessWidget {
  const StaffCanvas({
    super.key,
    required this.midi,
    required this.clef,
    this.accent,
    this.showNoteName = false,
    this.solfege = false,
    this.liveMidi,
  });

  final int midi;
  final Clef clef;

  /// 答对绿、答错红；null 为中性。
  final Color? accent;
  final bool showNoteName;

  /// 音名显示风格：false = C-D-E，true = do-re-mi。
  final bool solfege;

  /// MIDI 键盘上正按下的音，实时画一个空心符头。
  final int? liveMidi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TalkBack 需要把题目读出来（制作文档 5.7）
    return Semantics(
      label: '练习音符：${clef == Clef.treble ? '高音谱' : '低音谱'}，'
          '音名 ${NoteNaming.of(midi)}，请在键盘上找到它',
      child: CustomPaint(
        painter: StaffPainter(
          midi: midi,
          clef: clef,
          lineColor: theme.colorScheme.onSurface,
          accent: accent ?? theme.colorScheme.primary,
          showName: showNoteName,
          solfege: solfege,
          liveMidi: liveMidi,
          liveColor: theme.colorScheme.tertiary,
          nameColor: theme.colorScheme.onSurfaceVariant,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class StaffPainter extends CustomPainter {
  StaffPainter({
    required this.midi,
    required this.clef,
    required this.lineColor,
    required this.accent,
    required this.showName,
    required this.solfege,
    required this.liveMidi,
    required this.liveColor,
    required this.nameColor,
  });

  final int midi;
  final Clef clef;
  final Color lineColor;
  final Color accent;
  final bool showName;
  final bool solfege;
  final int? liveMidi;
  final Color liveColor;
  final Color nameColor;

  static const int _trebleClefCode = 0xE050;
  static const int _bassClefCode = 0xE062;

  TextPainter? _clefPainter;
  double _clefSize = 0;

  @override
  void paint(Canvas canvas, Size size) {
    final step = Pitch.staffStep(midi, clef).toDouble();

    // 加线会向外延伸：A0 要往下画 6 条，C8 要往上画 11 条。
    // 先按宽度算 lineGap，再按可用高度收缩，保证加线不被裁掉。
    final liveStep = liveMidi == null ? null : Pitch.staffStep(liveMidi!, clef).toDouble();
    final topStep = liveStep == null ? step : math.max(step, liveStep);
    final bottomStep = liveStep == null ? step : math.min(step, liveStep);
    final above = topStep > 8 ? (topStep - 8) / 2 : 0.0; // 谱表上方的间数
    final below = bottomStep < 0 ? -bottomStep / 2 : 0.0; // 谱表下方的间数
    final unitsHigh = 4 + above + below + 2; // 4 个间 + 加线 + 上下留白

    var lineGap = (size.width / 28).clamp(10.0, 20.0);
    final byHeight = size.height / unitsHigh;
    if (lineGap > byHeight) lineGap = byHeight.clamp(5.0, 20.0);

    final staffWidth = math.min(size.width, 560.0);
    final left = (size.width - staffWidth) / 2;
    final right = left + staffWidth;

    // 把「谱表 + 加线」整体垂直居中：最上一条谱线的 y
    final totalHeight = (4 + above + below) * lineGap;
    final topLineY = (size.height - totalHeight) / 2 + above * lineGap;
    final bottomLineY = topLineY + 4 * lineGap;

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.72)
      ..strokeWidth = math.max(1.0, lineGap / 10)
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final y = bottomLineY - i * lineGap;
      canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
    }

    _paintClef(canvas, lineGap, left, bottomLineY);

    final noteX = left + staffWidth * 0.62;
    final noteY = bottomLineY - step * lineGap / 2;

    _paintLedgerLines(canvas, linePaint, lineGap, noteX, bottomLineY, step);
    _paintNoteHead(canvas, lineGap, noteX, noteY);
    _paintStem(canvas, lineGap, noteX, noteY, step);

    if (showName) {
      _paintName(canvas, lineGap, noteX, noteY);
    }

    // MIDI 实时符头：空心、稍右偏，避免和题目符头重叠
    if (liveStep != null && liveStep != step) {
      final liveX = noteX + lineGap * 2.2;
      final liveY = bottomLineY - liveStep * lineGap / 2;
      _paintLedgerLines(canvas, linePaint, lineGap, liveX, bottomLineY, liveStep);
      final w = 1.24 * lineGap;
      canvas.save();
      canvas.translate(liveX, liveY);
      canvas.rotate(-20 * math.pi / 180);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w, height: w / 1.18),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, lineGap * 0.13)
          ..color = liveColor,
      );
      canvas.restore();
    }
  }

  void _paintClef(Canvas canvas, double lineGap, double left, double bottomLineY) {
    final fontSize = 4 * lineGap;
    if (_clefPainter == null || _clefSize != fontSize) {
      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(clef == Clef.treble ? _trebleClefCode : _bassClefCode),
          style: TextStyle(
            fontFamily: 'Bravura',
            fontSize: fontSize,
            color: lineColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _clefPainter = tp;
      _clefSize = fontSize;
    }
    final tp = _clefPainter!;
    // SMuFL 约定：谱号字形的基线落在它的参考线上（高音谱 G4、低音谱 F3）
    final anchorStep = clef == Clef.treble ? 2 : 6;
    final anchorY = bottomLineY - anchorStep * lineGap / 2;
    final baseline = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    tp.paint(canvas, Offset(left + lineGap * 0.2, anchorY - baseline));
  }

  void _paintLedgerLines(
    Canvas canvas,
    Paint paint,
    double lineGap,
    double noteX,
    double bottomLineY,
    double step,
  ) {
    final half = lineGap * 1.15;
    if (step < 0) {
      for (var s = -2.0; s >= step; s -= 2.0) {
        final y = bottomLineY - s * lineGap / 2;
        canvas.drawLine(Offset(noteX - half, y), Offset(noteX + half, y), paint);
      }
    } else if (step > 8) {
      for (var s = 10.0; s <= step; s += 2.0) {
        final y = bottomLineY - s * lineGap / 2;
        canvas.drawLine(Offset(noteX - half, y), Offset(noteX + half, y), paint);
      }
    }
  }

  void _paintNoteHead(Canvas canvas, double lineGap, double noteX, double noteY) {
    final w = 1.24 * lineGap;
    final h = w / 1.18;
    canvas.save();
    canvas.translate(noteX, noteY);
    canvas.rotate(-20 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      Paint()..color = accent,
    );
    canvas.restore();
  }

  void _paintStem(Canvas canvas, double lineGap, double noteX, double noteY, double step) {
    final up = step < 4;
    final w = 1.24 * lineGap;
    final stemX = up ? noteX + w * 0.44 : noteX - w * 0.44;
    final length = 3.2 * lineGap;
    final paint = Paint()
      ..color = accent
      ..strokeWidth = math.max(1.2, lineGap * 0.09)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(stemX, noteY),
      Offset(stemX, up ? noteY - length : noteY + length),
      paint,
    );
  }

  void _paintName(Canvas canvas, double lineGap, double noteX, double noteY) {
    final tp = TextPainter(
      text: TextSpan(
        text: solfege ? Pitch.solfegeName(midi) : NoteNaming.of(midi),
        style: TextStyle(fontSize: lineGap * 0.95, color: nameColor, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(noteX - tp.width / 2, noteY + lineGap * 2.2));
  }

  @override
  bool shouldRepaint(StaffPainter old) =>
      old.midi != midi ||
      old.clef != clef ||
      old.accent != accent ||
      old.lineColor != lineColor ||
      old.showName != showName ||
      old.solfege != solfege ||
      old.liveMidi != liveMidi ||
      old.liveColor != liveColor;
}
