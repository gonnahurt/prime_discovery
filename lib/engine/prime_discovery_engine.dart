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

  void discoverPrimes() {
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
      primeAverage < 236888443;
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
        nextBatchWalker++;
        nextBatchPrimesInt++;
        numPrimes++;
        
        if (numPrimes % 1000 == 0) {
          print('Discovered: $numPrimes');
        }
        nextBatchPrimesInt = nextBatchWalker + 1;
        if (nextBatchPrimesInt == discovered) {
          //call function to asynchronously write to file
          print("WRITE IT TO FILE!");
          print('Prime number at index $nextBatchWalker: $primeAverage');
          writeFile(fileCount);
        }
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
  }

  /* for(int primeMega = 9223372036854775807, primeMega > 9223372036854775807; primeprimeAverage += 0){
        
    }*/

  //Function getNext smooths transition from List initPrimes to List nextBatchPrimes
  int getNext(int initPrime) {
    if (initPrime <= 45) {
      return initialPrimes[initPrime];
    }
    return nextBatchPrimes[initPrime - 46];
  }

  Future<void> writeFile(int fileCount) async {
    // Create a space-separated string from the array
    try {
      DateTime start = DateTime.now();

      //format numeric part of file name to always be 5 digits
      String formatted = fileCount.toString().padLeft(5, '0');

      //Define file path
      String primeStoragePath = r'D:\PrimeDiscovery';
      String fileName = '${formatted}prime.dat';
      File file = File(
        '$primeStoragePath\\$fileName',
      ); //need to determine how to select drive D: or Volume Name prime01

      // Write asynchronously to .dat file
      await file.writeAsBytes(nextBatchPrimes.buffer.asUint8List());

      DateTime end = DateTime.now();

      print('Write time: ${end.difference(start).inMilliseconds} ms');

      print('$fileName created.');
    } catch (e) {
      print('error writing file: $e');
    }
  }
}
