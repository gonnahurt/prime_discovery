import 'dart:io';

void main() {
  const targetCount = 50000000;

  final primes = [2, 3, 5, 7, 11, 13, 17, 19];

  // Product of wheel primes
  const wheelSize = 9699690;

  // φ(wheelSize)
  const wheelLength = 1658880;

  print('Generating survivors...');

  final survivors = <int>[];

  int n = 1;

  while (survivors.length < targetCount) {
    bool survives = true;

    for (final p in primes) {
      if (n % p == 0) {
        survives = false;
        break;
      }
    }

    if (survives) {
      survivors.add(n);
    }

    n++;

    if (survivors.length % 1000000 == 0) {
      print(
        'Generated ${survivors.length} survivors...',
      );
    }
  }

  print('\n====================================');
  print('GENERATION COMPLETE');
  print('====================================');
  print('Survivors Found : ${survivors.length}');
  print('Largest Checked : ${n - 1}');

  //----------------------------------------------------
  // Build gaps
  //----------------------------------------------------

  print('\nGenerating gaps...');

  final gaps = <int>[];

  for (int i = 1; i < survivors.length; i++) {
    gaps.add(
      survivors[i] - survivors[i - 1],
    );
  }

  print('Gap Count : ${gaps.length}');

  //----------------------------------------------------
  // Capture first wheel
  //----------------------------------------------------

  final wheel = gaps.sublist(0, wheelLength);

  //----------------------------------------------------
  // Save wheel to file
  //----------------------------------------------------

  const outputFile =
      r'C:\Users\kvoccola\Documents\bigwheel.txt';

  print('\nSaving wheel file...');

  File(outputFile).writeAsStringSync(
    wheel.join(','),
  );

  print('Saved to: $outputFile');

  //----------------------------------------------------
  // Statistics
  //----------------------------------------------------

  print('\n====================================');
  print('WHEEL STATISTICS');
  print('====================================');

  print('Wheel Size   : $wheelSize');
  print('Wheel Period : $wheelLength');
  print('Total Gaps   : ${gaps.length}');
  print(
    'Full Cycles  : ${gaps.length ~/ wheelLength}',
  );
  print(
    'Remainder    : ${gaps.length % wheelLength}',
  );

  //----------------------------------------------------
  // First wheel boundary
  //----------------------------------------------------

  print('\n====================================');
  print('FIRST WHEEL BOUNDARY');
  print('====================================');

  print(
    'Gap Index Where Wheel #2 Starts : $wheelLength',
  );

  print(
    'Last Survivor In Wheel #1      : '
    '${survivors[wheelLength - 1]}',
  );

  print(
    'First Survivor In Wheel #2     : '
    '${survivors[wheelLength]}',
  );

  print(
    'Boundary Gap                   : '
    '${gaps[wheelLength - 1]}',
  );

  print(
    'Expected Number Boundary       : '
    '$wheelSize',
  );

  //----------------------------------------------------
  // Verify repetition
  //----------------------------------------------------

  print('\n====================================');
  print('VERIFYING REPETITION');
  print('====================================');

  int mismatches = 0;

  for (int i = wheelLength; i < gaps.length; i++) {
    final expectedGap =
        wheel[i % wheelLength];

    final actualGap =
        gaps[i];

    if (actualGap != expectedGap) {
      mismatches++;

      print('\nMismatch #$mismatches');

      print(
        'Gap Index      : $i',
      );

      print(
        'Wheel Position : ${i % wheelLength}',
      );

      print(
        'Expected Gap   : $expectedGap',
      );

      print(
        'Actual Gap     : $actualGap',
      );

      if (mismatches >= 20) {
        break;
      }
    }

    if (i % 5000000 == 0) {
      print(
        'Verified ${i.toString().padLeft(10)} gaps...',
      );
    }
  }

  //----------------------------------------------------
  // Final results
  //----------------------------------------------------

  print('\n====================================');
  print('FINAL RESULTS');
  print('====================================');

  if (mismatches == 0) {
    print(
      'SUCCESS: Entire gap sequence repeats every '
      '$wheelLength gaps.',
    );
  } else {
    print(
      'FAILED: Found $mismatches mismatches.',
    );
  }
}