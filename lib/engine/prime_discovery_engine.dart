/*=============================
Author: Kvoc
Erosthenes Sieve
Date Started: 10/29/26
Last Worked:  11/01/26
=============================*/

//import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import '../data_management/json_manager.dart';
import '../data_management/file_manager.dart';
import '../data_management/statistics_manager.dart';

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
  int walker = 0;

  Int64List buffer1 = Int64List(13000000);
  int b1Walker = 0;

  Int64List buffer2 = Int64List(13000000);
  int b2Walker = 0;

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

  int initPrimeStart = 4;
  int candidatesCount = 0; //count for number of candidates reviewed
  int numPrimes = 1; //count for number of primes determined starts at 1 because 2 is a freebie
  int lastPrime = 2; //tracks last prime number discovered
  int maxInt64 =
      9223372036854775807; //Max int64 candidate before switching to BigInt
  int maxBufferPrimes = 13000000;
  int fileCount = 1;
  static const String primeStoragePath = r'P:\PrimeDiscovery';
  int versionNum = 1; //JSON format version
  Duration fiveMins = const Duration(
    milliseconds: 300000,
  ); //1,000ms(= 1 second) x 60 = 60,000ms (= 1min) * 5 = 300,000ms (=5 mins)

  bool firstRun = true;
  bool isPrime = true;

  Future<void> determineFirstRun() async {
    firstRun = await jsonSearch(primeStoragePath);
    if (firstRun == true) {
      await jsonCreate(primeStoragePath);
    } else {
      //await recoveryRestart();
    }
  }

  Future<void> discoverPrimes() async {
    DateTime start = DateTime.now();
    await determineFirstRun();
    //==============================================================
    //primeTiny handles determination for numbers from 3 - 20
    //it only avoids even numbers by primeTiny +=2 in the for loop
    //==============================================================
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
        lastPrime = primeTiny;
      } else {
        isPrime = true;
        initPrime = 0;
      }
      initPrime = 0;
    }
    // 20 - 3 = 17 total integers : candidatesCount = 9 : 20 = last int checked : num primes = 7 : 7 primes in 17 integers is 42% : 9 candidates in 18 total integers is 50% of all integers processed
    //
    //=============
    //End primeTiny
    //=============

    //==========================================================
    //PrimeSmall handles determination for ints between 21 - 198
    //primeSmall uses a wheel to avoid multiples of 2 & 5
    //==========================================================
    bool firstRun = true;
    //198 - 21 = 177 total integers : candidatesCount = 9 : 197 = last int checked : num primes = 7 : 7 primes in 17 integers is 42% : 9 candidates in 18 total integers is 50% of all integers processed
    //lastInitPrime - primeSmall = 177 : CandidateCount = ? : lastPrime =
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
    DateTime recoveryState = DateTime.now(); //initialize json update time
    for ( 
      int primeAverage = lastInitPrime;
      primeAverage < maxInt64;
      primeAverage += primeWheel[primeWalker]) 
    { //for each candidate
      candidatesCount++;
      int rootSmall = sqrt(primeAverage).floor(); //sqrt of current candidate
      //int bufferDetermined = getNextRead(initPrime);
      while (rootSmall >= getNextRead(initPrime) && isPrime) {
        if (primeAverage % getNextRead(initPrime) == 0) {
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      } //while
      if (isPrime) {
        initPrime = 4; //since the wheel avoids all items divisible by 2, 3, 5, & 7 these checks are redundant
        primeCache[walker] = primeAverage;
        lastPrime = primeAverage;
        numPrimes++;
        walker++;

        //write number of primes located to terminal
        //increments of 1000
        if (numPrimes % 10000 == 0) {
          print('maxBufferPrimes  ${commas(numPrimes)}');
        }

        //create a file storing the last 13million primes located
        //13million generates a binary file just under 100MBs
        //if (walker % maxBufferPrimes == 0) {
        if (walker % 1000000 == 0) {
          print(
            'Writing file ${fileCount.toString().padLeft(5, '0')} '
            'with primes: ${commas(walker-1000000)} thru ${commas(walker)} || The last determined prime was ${commas(primeAverage)}',
          );
          Duration elapsed = DateTime.now().difference(recoveryState);

          print('first Million Determined in: ${elapsed.inSeconds} seconds');

          await jsonWrite(
            versionNum,
            fileCount,
            numPrimes,
            lastPrime,
            primeWalker,
            primeStoragePath,
          ); //UPDATE recovery json file every time new bin file is created.

          recoveryState = DateTime.now(); //reset json update time
          //call function to asynchronously write to file
          await writeFile(
            primeStoragePath : primeStoragePath, 
            fileCount : fileCount, 
            primeCache : primeCache);
          fileCount++;
        }
        //End Create File
      } else {
        isPrime = true;
        initPrime = 4;
      }

      //=====================================
      //Wheel for primeAverage
      //following this pattern reduces
      //       numbers to check for primality
      //skipping numbers divisible by 2,3,5,7
      //=====================================
      if (!firstRun) {
        if (primeWalker < lastWalker) {
          primeWalker++;
        } else {
          primeWalker = 0;
        }
      }
      firstRun = false;
      DateTime end = DateTime.now();
      Duration elapsed = end.difference(recoveryState);
      if (elapsed >= fiveMins) {
        await jsonWrite(
          versionNum,
          fileCount,
          numPrimes,
          lastPrime,
          primeWalker,
          primeStoragePath,
        ); //UPDATE recovery json file every time new bin file is created.}
        recoveryState = DateTime.now(); //reset json update time
      }
    }
    //================
    //End primeAverage
    //================

    print('$numPrimes primes determined');
    print('$candidatesCount numbers checked for primality');
    Duration elapsed = DateTime.now().difference(recoveryState);

    print('first 13 Million Determined in: ${elapsed.inSeconds} seconds');
    //print('first 13 Million Determined in: ${end.difference(start).inMilliseconds} ms');
  }

  //============================================
  //Smooth List transitions when reading primes 
  //From buffers
  //============================================
  int getNextRead(int initPrime) {
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

    throw Exception('getNextRead() unsupported index: $initPrime');
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

  Future<void> recoveryRestart() async {
    //assign critical variables
    final Map<String, dynamic> recoveryData = await jsonRead(primeStoragePath);
    versionNum = recoveryData['version'];
    fileCount = recoveryData['fileCount'];
    numPrimes = recoveryData['numPrimes'];
    lastPrime = recoveryData['lastPrime'];
    primeWalker = recoveryData['wheelPosition'];

    //Load files into arrays as needed
  }

  Future<void> wheelSelect() async {}
}
