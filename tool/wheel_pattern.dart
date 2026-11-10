import 'dart:io';
import 'dart:typed_data';

void main() {
  buildWheel(
    name: 'wheel_07',
    primes: [2, 3, 5, 7],
  );

  buildWheel(
    name: 'wheel_11',
    primes: [2, 3, 5, 7, 11],
  );

  buildWheel(
    name: 'wheel_13',
    primes: [2, 3, 5, 7, 11, 13],
  );

  buildWheel(
    name: 'wheel_17',
    primes: [2, 3, 5, 7, 11, 13, 17],
  );

  buildWheel(
    name: 'wheel_19',
    primes: [2, 3, 5, 7, 11, 13, 17, 19],
  );

  print('\nDone.');
}

void buildWheel({
  required String name,
  required List<int> primes,
}) {
  print('\n====================================');
  print('Building $name');
  print('====================================');

  //--------------------------------------------------
  // Compute wheel size
  //--------------------------------------------------

  int wheelSize = 1;

  for (final p in primes) {
    wheelSize *= p;
  }

  print('Wheel Product: $wheelSize');

  //--------------------------------------------------
  // Generate survivors
  //--------------------------------------------------

  final survivors = <int>[];

  for (int n = 1; n < wheelSize; n++) {
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
  }

  //--------------------------------------------------
  // Generate gap wheel
  //--------------------------------------------------

  final gaps = <int>[];

  for (int i = 1; i < survivors.length; i++) {
    gaps.add(
      survivors[i] - survivors[i - 1],
    );
  }

  // Wrap-around gap
  gaps.add(
    wheelSize +
        survivors.first -
        survivors.last,
  );

  //--------------------------------------------------
  // Convert to Uint16 binary
  //--------------------------------------------------

  final wheelData =
      Uint16List.fromList(gaps);

  //--------------------------------------------------
  // Ensure folder exists
  //--------------------------------------------------

  final outputDir = Directory(
    r'assets\wheels',
  );

  if (!outputDir.existsSync()) {
    outputDir.createSync(
      recursive: true,
    );
  }

  //--------------------------------------------------
  // Save wheel
  //--------------------------------------------------

  final outputFile = File(
    '${outputDir.path}\\$name.bin',
  );

  outputFile.writeAsBytesSync(
    wheelData.buffer.asUint8List(),
  );

  //--------------------------------------------------
  // Summary
  //--------------------------------------------------

  print('Prime Set   : ${primes.join(", ")}');
  print('Wheel Size  : $wheelSize');
  print('Wheel Length: ${gaps.length}');
  print(
    'File Size   : ${wheelData.lengthInBytes} bytes',
  );
  print(
    'Saved       : ${outputFile.path}',
  );  
  print(
  'Start Value : ${survivors[survivors.length - 2]}',
);

print(
  'Last Survivor : ${survivors.last}',
);

print(
  'First Gap : ${gaps.first}',
);
}