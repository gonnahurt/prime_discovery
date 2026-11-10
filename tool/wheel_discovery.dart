void main() {
  //--------------------------------------------------
  // CONFIGURATION
  //--------------------------------------------------

  const targetCount = 5000000;

  final primes = [
    2,
    3,
    5,
    7,
    11,
    //13,
    //17,
    //19,
  ];

  const patternStart = 1000;

  // Your discovered wheel pattern size
  const patternLength = 480;

  //--------------------------------------------------
  // GENERATE SURVIVORS
  //--------------------------------------------------

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

    if (survivors.length % 100000 == 0) {
      print(
        'Generated ${survivors.length} survivors...',
      );
    }
  }

  print('\nGenerating gaps...');

  //--------------------------------------------------
  // BUILD GAP LIST
  //--------------------------------------------------

  final gaps = <int>[];

  for (int i = 1; i < survivors.length; i++) {
    gaps.add(
      survivors[i] - survivors[i - 1],
    );
  }

  print('Gap Count: ${gaps.length}');

  //--------------------------------------------------
  // EXTRACT PATTERN
  //--------------------------------------------------

  final pattern = gaps.sublist(
    patternStart,
    patternStart + patternLength,
  );

  print('\n=================================');
  print('PATTERN');
  print('=================================');
  print('Start Index : $patternStart');
  print('Length      : $patternLength');
  print(pattern.join(','));

  //--------------------------------------------------
  // FIND MATCHES
  //--------------------------------------------------

  print('\nSearching for pattern matches...');

  final matches = <int>[];

  for (int i = 0;
      i <= gaps.length - patternLength;
      i++) {
    bool match = true;

    for (int j = 0; j < patternLength; j++) {
      if (gaps[i + j] != pattern[j]) {
        match = false;
        break;
      }
    }

    if (match) {
      matches.add(i);
    }
  }

  //--------------------------------------------------
  // PRINT MATCHES
  //--------------------------------------------------

  print('\n=================================');
  print('MATCHES');
  print('=================================');

  print('Matches Found: ${matches.length}');
  print('');

  for (final match in matches) {
    print(match);
  }

  //--------------------------------------------------
  // ANALYZE SPACING
  //--------------------------------------------------

  print('\n=================================');
  print('PATTERN SPACING');
  print('=================================');

  bool consistent = true;

  int? wheelLength;

  for (int i = 1; i < matches.length; i++) {
    final spacing =
        matches[i] - matches[i - 1];

    print(
      '${matches[i - 1]} -> ${matches[i]} = $spacing',
    );

    wheelLength ??= spacing;

    if (spacing != wheelLength) {
      consistent = false;
    }
  }

  //--------------------------------------------------
  // RESULTS
  //--------------------------------------------------

  print('\n=================================');
  print('RESULT');
  print('=================================');

  if (matches.length < 2) {
    print(
      'Not enough matches found to determine wheel length.',
    );
    return;
  }

  if (consistent) {
    print(
      'Wheel Length Found: $wheelLength',
    );
  } else {
    print(
      'Pattern spacing is not consistent.',
    );

    print(
      'Try increasing the survivor count.',
    );
  }
}