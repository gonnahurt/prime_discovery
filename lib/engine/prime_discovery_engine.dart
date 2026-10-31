/*=============================
Author: Kvoc
Erosthenes Sieve
Date Started: 10/29/26
=============================*/

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

class PrimeDiscoveryEngine {
  final List<BigInt> megaPrimes = List<BigInt>.filled(10, BigInt.zero);

  //=========================================================================
  // dart format off
  //primes in first 200 integers - jumping point
  final initialPrimes = List<int>.of([2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31,
  37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109,
  113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 
  197, 199], growable: false);
  // dart format on
  int initPrime = 0;
  int lastInitPrime = 199; //last prime in List initialPrimes
  int lastIndex = 45; //0-45
  //=========================================================================

  Int64List primeCache = Int64List(26000000);
  int pcWalker = 0;

  Int64List buffer1 = Int64List(13000000);
  int b1Walker = 0;
 
  Int64List buffer2 = Int64List(13000000);
  int b2Walker = 0;
 
  List<int> currentRecoveryData = [1,1,1,2,0];
  /*"version": 1,
  "fileCount": 1,
  "numPrimes": 1,
  "lastPrime": 2,
  "bufferPosition": 0 */


  //wheel for walking past even numbers and numbers divisible by 5 -
  //used for numbers 21 - 199
  final miniPrimeWalk = List<int>.of([2, 4, 2, 2], growable: false);
  int miniWalker = 0;
  final int lastMini = 3;

  //wheel for walking past numbers divisible by 2,3,5,7 & 9 -
  //this allows us to only check 24% of numbers beyone 199
  // dart format off
  final primeWalk = List<int>.of([10,2,10,2,4,2,4,6,2,6,4,2,4,6,6,2,6,4,2,6,4,
  6,8,4,2,4,2,4,8,6,4,6,2,4,6,2,6,6,4,2,4,6,2,6,4,2,4,2], growable: false);
  // dart format on

  int primeWalker = 0;
  final int lastWalker = 47;

  int candidatesCount = 0; //count for number of candidates reviewed
  int numPrimes = 1; //count for number of primes determined starts at 1 because 2 is a freebie
  int max_64Int = 9223372036854775807; //Max int64 candidate before switching to BigInt
  int maxBufferPrimes = 13000000;
  int fileCount = 1;
  bool isPrime = true;

  Future<void> discoverPrimes() async {
    DateTime start = DateTime.now();
    for (int primeLittle = 3; primeLittle < 21; primeLittle += 2) {
      candidatesCount++;
      while (primeLittle > initialPrimes[initPrime] && isPrime) {
        if (primeLittle % initialPrimes[initPrime] == 0) {
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      }
      if (isPrime) {
        numPrimes++;
      } else {
        isPrime = true;
        initPrime = 0;
      }
      initPrime = 0;
    }

    bool firstRun = true;
    for (
      int primeSmall = 21;
      primeSmall < lastInitPrime;
      primeSmall += miniPrimeWalk[miniWalker]
    ) {
      candidatesCount++;
      int rootSmall = sqrt(primeSmall).floor();
      while (rootSmall >= initialPrimes[initPrime] && isPrime) {
        if (primeSmall % initialPrimes[initPrime] == 0) {
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      } //while

      if (isPrime) {
        initPrime = 0;
        numPrimes++;
      } else {
        isPrime = true;
        initPrime = 0;
      }

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
    for (
      int primeAverage = lastInitPrime;
      primeAverage < max_64Int;
      primeAverage += primeWalk[primeWalker]
    ) {
      candidatesCount++;
      int rootSmall = sqrt(primeAverage).floor();
      while (rootSmall >= getNext(initPrime) && isPrime) {
        if (primeAverage % getNext(initPrime) == 0) {
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      } //while
      if (isPrime) {
        initPrime = 4; //since the wheel avoids all items divisible by 2, 3, 5, & 7 these checks are redundant
        primeCache[pcWalker] = primeAverage;
        numPrimes++;
        pcWalker++; 

        if (numPrimes % 1000 == 0) {
          print('maxBufferPrimes  ${commas(numPrimes)}');
        }
        if (pcWalker == maxBufferPrimes) {
          print(
            'Writing file ${fileCount.toString().padLeft(5, '0')} '
            'with ${commas(pcWalker)} primes...  :The last determined prime was ${commas(primeAverage)}',
          );

          //call function to asynchronously write to file
          await writeFile(fileCount);
          fileCount++;
        }
        
        
      } else {
        isPrime = true;
        initPrime = 4;
      }

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
    print('$candidatesCount numbers checked for primality');
    DateTime end = DateTime.now();
    Duration elapsed = end.difference(start);

    print('first 13 Million Determined in: ${elapsed.inSeconds} seconds');
    //print('first 13 Million Determined in: ${end.difference(start).inMilliseconds} ms');
  }

  //============================================
  //Smooth List transitions
  //From List initPrimes to List primeCache
  //============================================
  int getNext(int initPrime) {
    if (initPrime <= 45) {
      return initialPrimes[initPrime];
    }
    return primeCache[initPrime - 46];
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
      await file.writeAsBytes(primeCache.buffer.asUint8List());

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

  int seconds(int ms) {
    return (ms / 1000).floor();
  }

  //=======================
  //All things JSON related
  //=======================

  //Verify JSON file exists or create it
  Future<void> jsonSearch() async {
    String primeStoragePath = r'D:\PrimeDiscovery';
    String fileName = 'state.json';
    File file = File('$primeStoragePath\\$fileName');

    // Validate file existence
    if (!await file.exists()) {
      // Call jsonCreate()
    } else {
      //Call jsonRead()
    }
  }

  //Create JSON file
  Future<void> jsonCreate() async {
    final state = {
  "version": 1,
  "fileCount": 1,
  "numPrimes": 1,
  "lastPrime": 2,
  "bufferPosition": 0
};
    final jsonString = jsonEncode(state);

    final file = File('state.json');
    await file.writeAsString(jsonString);
  }

  //Write to JSON file
  Future<void> jsonWrite() async {
    //nothing yet
  }

  //Read from JSON file
  Future<void> jsonRead() async {
    // nothing yet
  }
  //=============================
  //End - all things JSON related
  //=============================
}
