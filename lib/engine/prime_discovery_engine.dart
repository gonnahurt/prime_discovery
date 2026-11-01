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
  int initPrime = 0; //Pointer for current
  int lastInitPrime = 199; //last prime in List initialPrimes
  int lastIndex = 45; //0-45
  //=========================================================================

  Int64List primeCache = Int64List(150000000);
  int pcWalker = 0;

  Int64List buffer1 = Int64List(13000000);
  int b1Walker = 0;

  Int64List buffer2 = Int64List(13000000);
  int b2Walker = 0;

  List<int> currentRecoveryData = [1, 1, 1, 2, 0];
  //Update JSON file when new file written & Every 5 or 10 mins.
  //"version": 1,       No Variable: this is the JSON format?  If we change the format it becomes version 2?
  //"fileCount": 1,     Var fileCount: this is number of files created, containing 13million prime 64xInt
  //"numPrimes": 1,     Var numPrimes: This is the current number of all primes 2 - our last determine prime
  //"lastPrime": 2,     Var lastPrime: This is the last determined prime number
  //"wheelPosition":0   Var primeWalker necesarry to resume using the wheel on new startup.
  //                    I assume this could be alternatively handled by a calculation

  //wheel for walking past even numbers and numbers divisible by 5 -
  //used for numbers 21 - 199
  final miniWheel = List<int>.of([2, 4, 2, 2], growable: false);
  int miniWalker = 0;
  final int lastMini = 3;

  //wheel for walking past numbers divisible by 2,3,5,7 & 9 -
  //this allows us to only check 24% of numbers beyone 199
  // dart format off
  final primeWheel = List<int>.of([10,2,10,2,4,2,4,6,2,6,4,2,4,6,6,2,6,4,2,6,4,
  6,8,4,2,4,2,4,8,6,4,6,2,4,6,2,6,6,4,2,4,6,2,6,4,2,4,2], growable: false);
  // dart format on
  int primeWalker = 0;
  final int lastWalker = 47;

  int candidatesCount = 0; //count for number of candidates reviewed
  int numPrimes = 1; //count for number of primes determined starts at 1 because 2 is a freebie
  int lastPrime = 2; //tracks last prime number discovered
  int maxInt64 =
      9223372036854775807; //Max int64 candidate before switching to BigInt
  int maxBufferPrimes = 13000000;
  int fileCount = 1;
  static const String primeStoragePath = r'D:\PrimeDiscovery';
  int version = 1; //JSON format version
  int fiveMins = 300000;

  bool firstRun = true;
  bool isPrime = true;

  Future<void> determineFirstRun() async {
    firstRun = await jsonSearch();
    if (firstRun == true) {
      await jsonCreate();
    } else {
      await recoveryRestart();
    }
  }

  //==============================================================
  //primeTiny handles determination for numbers from 3 - 20
  //it only avoids even numbers by primeTiny +=2 in the for loop
  //==============================================================
  Future<void> discoverPrimes() async {
    DateTime start = DateTime.now();
    for (int primeTiny = 3; primeTiny < 21; primeTiny += 2) {
      candidatesCount++;
      while (primeTiny > initialPrimes[initPrime] && isPrime) {
        if (primeTiny % initialPrimes[initPrime] == 0) {
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
    //=============
    //End primeTiny
    //=============

    //==========================================================
    //PrimeSmall handles determination for ints between 21 - 198
    //primeSmall uses a wheel to avoid multiples of 2 & 5
    //==========================================================
    bool firstRun = true;
    for (
      int primeSmall = 21;
      primeSmall < lastInitPrime;
      primeSmall += miniWheel[miniWalker]
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
      //======================================
      //Wheel for primeSmall
      //miniWalker points to the correct index
      //in List miniWheel
      //avoiding mutiples of 2 & 5
      //======================================
      if (!firstRun) {
        if (miniWalker < lastMini) {
          miniWalker++;
        } else {
          miniWalker = 0;
        }
      }
      firstRun = false;
    }
    //==============
    //End primeSmall
    //==============

    //============================================
    //primeAverage handles ints
    //199 - 9223372036854775807 aka maxInt64
    //uses a wheel to avoid multiples of 2,3,5 & 7
    //============================================
    firstRun = true;
    for (
      int primeAverage = lastInitPrime;
      primeAverage < maxInt64;
      primeAverage += primeWheel[primeWalker]
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
        lastPrime = primeAverage;
        numPrimes++;
        pcWalker++;

        //write number of primes located to terminal
        //increments of 1000
        if (numPrimes % 1000 == 0) {
          print('maxBufferPrimes  ${commas(numPrimes)}');
        }

        //create a file storing the last 13million primes located
        //13million generates a binary file just under 100MBs
        if (pcWalker % maxBufferPrimes == 0) {
          print(
            'Writing file ${fileCount.toString().padLeft(5, '0')} '
            'with ${commas(pcWalker)} primes...  :The last determined prime was ${commas(primeAverage)}',
          );

          //call function to asynchronously write to file
          await writeFile(fileCount);
          fileCount++;

          //Update JSON file when new file written & Every 5 or 10 mins.
          //"version": 1,       No Variable: this is the JSON format?  If we change the format it becomes version 2?
          //"fileCount": 1,     Var fileCount: this is number of files created, containing 13million prime 64xInt
          //"numPrimes": 1,     Var numPrimes: This is the current number of all primes 2 - our last determine prime
          //"lastPrime": 2,     Var lastPrime: This is the last determined prime number
          //"wheelPosition":0   Var primeWalker necesarry to resume using the wheel on new startup.
          //                    I assume this could be alternatively handled by a calculation
        }
        //End Create File
      } else {
        isPrime = true;
        initPrime = 4;
      }

      //======================================
      //Wheel for primeAverage
      //miniWalker points to the correct index
      //in List miniWheel
      //avoiding mutiples of 2 & 5
      //======================================
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
    //================
    //End primeAverage
    //================

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
    if (initPrime > 45 && initPrime <= 26000045) {
      return primeCache[initPrime - 46];
    }
    if (initPrime > 26000045 && initPrime <= 39000045) {
      return buffer1[initPrime - 26000046];
    }
    if (initPrime > 39000045 && initPrime <= 52000045) {
      return buffer2[initPrime - 39000046];
    }

    throw Exception('getNext() unsupported index: $initPrime');
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
  Future<bool> jsonSearch() async {
    //String primeStoragePath = r'D:\PrimeDiscovery';
    String fileName = 'state.json';
    File file = File('$primeStoragePath\\$fileName');

    // Validate file existence
    return !await file.exists();
  }

  //Create JSON file
  Future<void> jsonCreate() async {
    final Map<String, dynamic> recoveryData = {
      "version": 1,
      "fileCount": 1,
      "numPrimes": 1,
      "lastPrime": 2,
      "wheelPosition": 0,
    };

    final File jsonFile = File('$primeStoragePath\\state.json');

    try {
      // 3. Convert the Dart map into a pretty-printed JSON string
      // (Using JsonEncoder.withIndent('  ') adds clean line breaks and indents)
      final String jsonString = const JsonEncoder.withIndent('  ')
          .convert(recoveryData);

      // 4. Write the string asynchronously to the file
      await jsonFile.writeAsString(jsonString);

      print('Successfully created JSON file at: ${jsonFile.absolute.path}');
    } catch (e) {
      print('An error occurred while creating the file: $e');
    }
  }

  //Write to JSON file
  Future<void> jsonWrite() async {
    final Map<String, dynamic> recoveryData = {
      "version": 1,
      "fileCount": fileCount,
      "numPrimes": numPrimes,
      "lastPrime": lastPrime,
      "wheelPosition": primeWalker,
    }; //nothing yet

    final File jsonFile = File('$primeStoragePath\\state.json');

    try {
      // 3. Convert the Dart map into a pretty-printed JSON string
      // (Using JsonEncoder.withIndent('  ') adds clean line breaks and indents)
      final String jsonString = const JsonEncoder.withIndent('  ')
          .convert(recoveryData);

      // 4. Write the string asynchronously to the file
      await jsonFile.writeAsString(jsonString);

      print('Successfully created JSON file at: ${jsonFile.absolute.path}');
    } catch (e) {
      print('An error occurred while creating the file: $e');
    }
  }

  //Read from JSON file
  Future<Map<String, dynamic>> jsonRead() async {
    final String jsonString = await File('$primeStoragePath\\state.json')
        .readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  //=============================
  //End - all things JSON related
  //=============================

  Future<void> recoveryRestart() async {
    //assign critical variables
    final Map<String, dynamic> recoveryData = await jsonRead();
    version = recoveryData['version'];
    fileCount = recoveryData['fileCount'];
    numPrimes = recoveryData['numPrimes'];
    lastPrime = recoveryData['lastPrime'];
    primeWalker = recoveryData['wheelPosition'];

    //Load files into arrays as needed
  }
}
