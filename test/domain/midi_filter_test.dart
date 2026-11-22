import 'package:flutter_test/flutter_test.dart';
import 'package:notecard/domain/midi_filter.dart';

void main() {
  group('MidiNoteFilter（制作文档 7.8 / 9.2 U18–U20）', () {
    test('非 Note On、velocity 0 都不产生答案', () {
      final f = MidiNoteFilter();
      expect(f.accept(isNoteOn: false, note: 60, velocity: 100, nowMs: 0), isNull);
      expect(f.accept(isNoteOn: true, note: 60, velocity: 0, nowMs: 1000), isNull);
    });

    test('移调：+1 八度把 48 抬到 60', () {
      final f = MidiNoteFilter(transpose: 1);
      expect(f.accept(isNoteOn: true, note: 48, velocity: 100, nowMs: 0), 60);
    });

    test('移调后越界要 clamp 到 0–127', () {
      expect(
        MidiNoteFilter(transpose: 2).accept(isNoteOn: true, note: 127, velocity: 100, nowMs: 0),
        127,
      );
      expect(
        MidiNoteFilter(transpose: -2).accept(isNoteOn: true, note: 3, velocity: 100, nowMs: 0),
        0,
      );
    });

    test('300ms 去抖：连发只认第一条', () {
      final f = MidiNoteFilter();
      expect(f.accept(isNoteOn: true, note: 64, velocity: 90, nowMs: 1000), 64);
      expect(f.accept(isNoteOn: true, note: 64, velocity: 90, nowMs: 1100), isNull);
      expect(f.accept(isNoteOn: true, note: 64, velocity: 90, nowMs: 1299), isNull);
      expect(f.accept(isNoteOn: true, note: 64, velocity: 90, nowMs: 1301), 64);
    });

    test('reset 后立刻可接受新事件（换设备/开新会话）', () {
      final f = MidiNoteFilter();
      f.accept(isNoteOn: true, note: 60, velocity: 90, nowMs: 1000);
      expect(f.accept(isNoteOn: true, note: 62, velocity: 90, nowMs: 1010), isNull);
      f.reset();
      expect(f.accept(isNoteOn: true, note: 62, velocity: 90, nowMs: 1020), 62);
    });
  });
}
