/*=============================
Author: Kvoc
Erosthenes Sieve
Date Started: 10/29/26
=============================*/

import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

class PrimeDiscoveryEngine {
  final List<BigInt> megaPrimes = List<BigInt>.filled(10, BigInt.zero);

  //primes in first 200 integers - jumping point
  final initialPrimes = List<int>.of([
    2,
    3,
    5,
    7,
    11,
    13,
    17,
    19,
    23,
    29,
    31,
    37,
    41,
    43,
    47,
    53,
    59,
    61,
    67,
    71,
    73,
    79,
    83,
    89,
    97,
    101,
    103,
    107,
    109,
    113,
    127,
    131,
    137,
    139,
    149,
    151,
    157,
    163,
    167,
    173,
    179,
    181,
    191,
    193,
    197,
    199,
  ], growable: false);
  int initPrime = 0;
  int lastInitPrime = 199; //last prime in List initialPrimes
  int lastIndex = 45; //0-45

  //primes discovered - 13million as 64 bit integers this keeps the file up near 100MBs
  Int64List nextBatchPrimes = Int64List(13000000);
  int nextBatchWalker = 0;
  int nextBatchPrimesInt = 0; //number of primes inside List nextBatchPrimes

  //primes discovered - 13million as 64 bit integers this keeps the file up near 100MBs
  Int64List nextBatchPrimes1 = Int64List(13000000);
  int nextBatch1Walker = 0;
  int nextBatch1PrimesInt = 0; //number of primes inside List nextBatchPrimes

  //wheel for walking past even numbers and numbers divisible by 5 - used for numbers 21 - 199
  final miniPrimeWalk = List<int>.of([2, 4, 2, 2], growable: false);
  int miniWalker = 0;
  final int lastMini = 3;

  //wheel for walking past numbers divisible by 2,3,5,7 & 9 - this allows us to only check 24% of numbers beyone 199
  // dart format off
  final primeWalk = List<int>.of([10,2,10,2,4,2,4,6,2,6,4,2,4,6,6,2,6,4,2,6,4,6,8,4,2,4,2,4,8,6,4,6,2,4,6,2,6,6,4,2,4,6,2,6,4,2,4,2], growable: false);
  // dart format on

  int primeWalker = 0;
  final int lastWalker = 47;

  int candidates = 0;
  int numPrimes = 1; //because 2 is a freebie
  int lastSupportedInt = 9223372036854775807;
  int discovered = 13000000;
  int fileCount = 1;
  bool isPrime = true;

  Future<void> discoverPrimes() async {
    //print('2');
    for (int primeLittle = 3; primeLittle < 21; primeLittle += 2) {
      candidates++;
      while (primeLittle > initialPrimes[initPrime] && isPrime) {
        if (primeLittle % initialPrimes[initPrime] == 0) {
          //print('Candidate $primeLittle is not prime');
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      }
      if (isPrime) {
        //add to list of primes
        //stdout.write('$primeLittle, ');
        //print('$primeLittle, ');
        numPrimes++;
      } else {
        isPrime = true;
        initPrime = 0;
      }
      //add to list

      initPrime = 0;
    }

    bool firstRun = true;
    for (
      int primeSmall = 21;
      primeSmall < lastInitPrime;
      primeSmall += miniPrimeWalk[miniWalker]
    ) {
      candidates++;
      int rootSmall = sqrt(primeSmall).floor();
      while (rootSmall >= initialPrimes[initPrime] && isPrime) {
        if (primeSmall % initialPrimes[initPrime] == 0) {
          //print('$primeSmall divides evenly by ${initialPrimes[initPrime]}');
          //print('Candidate $primeSmall is not prime');
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      } //while
      if (isPrime) {
        //add to list of primes
        //stdout.write('$primeSmall, ');
        //print('$primeSmall, ');
        initPrime = 0;
        numPrimes++;
      } else {
        isPrime = true;
        initPrime = 0;
      }
      //primeSmall += 2;

      //add to list
      if (!firstRun) {
        if (miniWalker < lastMini) {
          miniWalker++;
        } else {
          miniWalker = 0;
        }
      }
      firstRun = false;
    }

    firstRun = true;
    //for(int primeAverage = lastInitPrime; primeAverage < lastSupportedInt; primeAverage += 0){
    for (
      int primeAverage = lastInitPrime;
      primeAverage < 236888461;
      primeAverage += primeWalk[primeWalker]
    ) {
      candidates++;
      int rootSmall = sqrt(primeAverage).floor();
      while (rootSmall >= getNext(initPrime) && isPrime) {
        if (primeAverage % getNext(initPrime) == 0) {
          //print('$primeSmall divides evenly by ${initialPrimes[initPrime]}');
          //print('Candidate $primeSmall is not prime');
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      } //while
      if (isPrime) {
        //add to list of primes
        //print('$primeAverage, ');
        initPrime = 4; //since the wheel avoids all items divisible by 2, 3, 5, & 7 these checks are redundant
        nextBatchPrimes[nextBatchWalker] = primeAverage;        
        nextBatchPrimesInt++;
        numPrimes++;

        if (numPrimes % 1000 == 0) {
          print('Discovered: ${commas(numPrimes)}');
        }
        //nextBatchPrimesInt = nextBatchWalker + 1;
        if (nextBatchPrimesInt == discovered) {
          //call function to asynchronously write to file
          print("WRITE IT TO FILE!");
          print('Prime number at index $nextBatchWalker: $primeAverage');

                     print(nextBatchWalker);

          print(nextBatchPrimes[12999995]);
          print(nextBatchPrimes[12999996]);
          print(nextBatchPrimes[12999997]);
          print(nextBatchPrimes[12999998]);
          print(nextBatchPrimes[12999999]); 

          await writeFile(fileCount);
        }
        nextBatchPrimesInt = nextBatchWalker + 1;
        nextBatchWalker++;
      } else {
        isPrime = true;
        initPrime = 4;
      }
      //primeSmall += 2;

      //wheel - following this pattern reduces numbers to check for primality
      //skipping all numbers divisible by 2,3,5,7
      if (!firstRun) {
        if (primeWalker < lastWalker) {
          primeWalker++;
        } else {
          primeWalker = 0;
        }
      }
      firstRun = false;
    }
    print('$numPrimes primes determined');
    print('$candidates numbers checked for primality');

    try {
      final integers = await readBinary(endian: Endian.little);

      print("Read ${integers.length} 64-bit integers:");
      //print(integers);
      print('First: ${integers[0]}');
      print('Second: ${integers[1]}');
      print('Second: ${integers[2]}');
      print('Second: ${integers[3]}');
      print('Second: ${integers[4]}');
      print('Tenth: ${integers[9]}');
      print('Last: ${integers[discovered - 5]}');
      print('Last: ${integers[discovered - 4]}');
      print('Last: ${integers[discovered - 3]}');
      print('Last: ${integers[discovered - 2]}');
      print('Last: ${integers[discovered - 1]}');
    } catch (e) {
      print("Error: $e");
    }
  }

  /* for(int primeMega = 9223372036854775807, primeMega > 9223372036854775807; primeprimeAverage += 0){
        
    }*/

  //============================================
  //Smooth List transitions
  //From List initPrimes to List nextBatchPrimes
  //============================================
  int getNext(int initPrime) {
    if (initPrime <= 45) {
      return initialPrimes[initPrime];
    }
    return nextBatchPrimes[initPrime - 46];
  }

  //======================
  //Function Write to File
  //======================
  Future<void> writeFile(int fileCount) async {
    // Create a space-separated string from the array
    try {
      DateTime start = DateTime.now();

      //format numeric part of file name to always be 5 digits
      String formatted = fileCount.toString().padLeft(5, '0');
      String fileName = '${formatted}prime.dat';

      //Define file path
      String primeStoragePath = r'D:\PrimeDiscovery';

      File file = File('$primeStoragePath\\$fileName');

      // Write asynchronously to .dat file
      await file.writeAsBytes(nextBatchPrimes.buffer.asUint8List());

      DateTime end = DateTime.now();

      print('Write time: ${end.difference(start).inMilliseconds} ms');

      //print('$fileName created.');
    } catch (e) {
      print('error writing file: $e');
    }
  }

  //=======================
  //Function Read from file
  //=======================
  Future<List<int>> readBinary({Endian endian = Endian.little}) async {
    //Define file path
    String primeStoragePath = r'D:\PrimeDiscovery';

    //format numeric part of file name to always be 5 digits
    String formatted = fileCount.toString().padLeft(5, '0');
    String fileName = '${formatted}prime.dat';
    File file = File('$primeStoragePath\\$fileName');

    // Validate file existence
    if (!await file.exists()) {
      throw FileSystemException("File not found", primeStoragePath);
    }

    // Read all bytes from the file
    final bytes = await file.readAsBytes();

    // Ensure file length is a multiple of 8 bytes (64-bit integers)
    if (bytes.length % 8 != 0) {
      throw FormatException("File length is not a multiple of 8 bytes.");
    }

    // Wrap bytes in ByteData for easy integer extraction
    final byteData = ByteData.sublistView(bytes);

    // Extract integers
    final intCount = bytes.length ~/ 8;
    final List<int> integers = List<int>.generate(
      intCount,
      (i) => byteData.getInt64(i * 8, endian),
    );

    return integers;
  }

  String commas(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}
