import 'package:flutter_test/flutter_test.dart';
import 'package:notecard/data/midi/midi_service.dart';

void main() {
  group('MIDI 设备名清洗（实机 Yamaha 名字里带换行）', () {
    test('换行压成单空格', () {
      expect(cleanMidiDeviceName('Yamaha Corporation\nDigital Piano', 'x'),
          'Yamaha Corporation Digital Piano');
    });

    test('多余空白与首尾空格', () {
      expect(cleanMidiDeviceName('  A \t  B  ', 'x'), 'A B');
    });

    test('空名字回退成带 id 的占位', () {
      expect(cleanMidiDeviceName('   ', '8#port=0'), 'MIDI 设备 (8#port=0)');
    });
  });
}