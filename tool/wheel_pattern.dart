import 'dart:io';
import 'dart:typed_data';

void main() {
  // Existing validated wheels
  buildCustomWheel(name: 'wheel_01', gaps: [1]);
  buildCustomWheel(name: 'wheel_02', gaps: [2]);
  buildCustomWheel(name: 'wheel_05', gaps: [4, 6, 2, 6, 4, 2, 4, 2]);

  // Experimental wheel_07 validation
  testWheel07();

  print('\nDone.');
}

void buildCustomWheel({required String name, required List<int> gaps}) {
  print('\n====================================');
  print('Building $name');
  print('====================================');

  final wheelData = Uint16List.fromList(gaps);

  final outputDir = Directory(r'assets\wheels');

  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final outputFile = File('${outputDir.path}\\$name.bin');

  outputFile.writeAsBytesSync(wheelData.buffer.asUint8List());

  int sum = 0;

  for (final gap in gaps) {
    sum += gap;
  }

  print('Wheel Length : ${gaps.length}');
  print('File Size    : ${wheelData.lengthInBytes} bytes');
  print('Saved        : ${outputFile.path}');
  print('Sum of Gaps  : $sum');
  print('Gaps         : ${gaps.join(", ")}');
}

void testWheel07() {
  print('\n====================================');
  print('Testing wheel_07');
  print('====================================');

  const int startValue = 199;
  const int endValue = 1000;

  final candidates = <int>[];

  // Numbers not divisible by 2,3,5,7
  for (int n = startValue; n <= endValue; n++) {
    if (n % 2 != 0 && n % 3 != 0 && n % 5 != 0 && n % 7 != 0) {
      candidates.add(n);
    }
  }

  print('\nFirst 100 candidates:\n');

  for (int i = 0; i < 100 && i < candidates.length; i++) {
    print('#${(i + 1).toString().padLeft(3)} : ${candidates[i]}');
  }

  final gaps = <int>[];

  for (int i = 1; i < candidates.length; i++) {
    gaps.add(candidates[i] - candidates[i - 1]);
  }

  print('\n====================================');
  print('First 48 Gaps');
  print('====================================');

  print(gaps.take(48).join(', '));

  print('\n====================================');
  print('Second 48 Gaps');
  print('====================================');

  print(gaps.skip(48).take(48).join(', '));

  print('\n====================================');
  print('Comparison');
  print('====================================');

  bool repeats = true;

  for (int i = 0; i < 48; i++) {
    int gap1 = gaps[i];
    int gap2 = gaps[i + 48];

    if (gap1 != gap2) {
      repeats = false;

      print(
        'Mismatch @ index $i : '
        '$gap1 != $gap2',
      );
    }
  }

  print('\nRepeats = $repeats');

  if (repeats) {
    print('\nCreating wheel_07.bin');

    final wheel07 = gaps.take(48).toList();

    final wheelData = Uint16List.fromList(wheel07);

    final outputDir = Directory(r'assets\wheels');

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final outputFile = File('${outputDir.path}\\wheel_07.bin');

    outputFile.writeAsBytesSync(wheelData.buffer.asUint8List());

    int sum = 0;

    for (final gap in wheel07) {
      sum += gap;
    }

    print('\n====================================');
    print('wheel_07 CREATED');
    print('====================================');
    print('Wheel Length : ${wheel07.length}');
    print('File Size    : ${wheelData.lengthInBytes}');
    print('Sum of Gaps  : $sum');
    print('Saved        : ${outputFile.path}');
    print('Gaps         : ${wheel07.join(", ")}');
  } else {
    print(
      '\nwheel_07 NOT CREATED'
      ' because pattern did not repeat.',
    );
  }
}
