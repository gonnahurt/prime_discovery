/*=============================
Author: Kvoc
Erosthenes Sieve
Date Started: 10/29/26
Last Worked:  11/14/26
=============================*/

// TODO:
// Time checks currently occur every candidate.
// In the distant future a single candidate may take
// several seconds to evaluate.
// Investigate checking time every N comparisons
// (100k? 1M?) and benchmark actual cost.

// TODO: Prime determination refactor
//
// primeSmall() and primeAverage() contain very similar
// primality determination logic.
//
// Investigate creating a shared function that:
//   - determines if a candidate is prime
//   - returns true/false
//
// Consider whether the function should:
//   - return a bool
//   - modify isPrime
//   - handle processLocatedPrime/processCandidateNotPrime
//
// Revisit after statistics system is working.
//The following segment is similar for both primeSmall & primeAverage
//create a shared method??
// int rootSmall = sqrt(primeSmall).floor();
// while (rootSmall >= initialPrimes[initPrime] && isPrime) {
//   if (primeSmall % initialPrimes[initPrime] == 0) {
//     initPrime = 0;
//     isPrime = false;
//   } else {
//     initPrime++;
//   }
// } //while

// if (isPrime) {
//   initPrime = 0;
//   processLocatedPrime(primeSmall);
// } else {
//   isPrime = true;
//   initPrime = 0;
//   processCandidateNotPrime();
// }

//import 'dart:convert';
import 'dart:math';
//import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import '../data_management/json_manager.dart';
import '../data_management/file_manager.dart';
import '../data_management/statistics_manager.dart';
import '../data_management/time_manager.dart';

import '../utilities/formatters.dart';

import '../models/config_model.dart';
import '../models/recovery_model.dart';
import '../models/session_model.dart';
import '../models/statistics_model.dart';
import 'process_determined_prime.dart';

class PrimeDiscoveryEngine {
  // #region Discovery State
  final RecoveryData recoveryData;
  final ConfigData configData;
  final SessionData sessionData;
  final PerTenSecondsStatisticsModel perTenSecondsStatisticsModel;
  final Per1MinuteStatisticsModel per1MinuteStatisticsModel;
  final PerMillionStatisticsModel perMillionStatisticsModel;
  final CycleStatisticsModel cycleStatisticsModel;
  final SessionStatisticsModel sessionStatisticsModel;
  //final ProcessDeterminedPrime processDeterminedPrime;

  PrimeDiscoveryEngine(
    this.recoveryData,
    this.configData,
    this.sessionData,
    this.perTenSecondsStatisticsModel,
    this.per1MinuteStatisticsModel,
    this.perMillionStatisticsModel,
    this.cycleStatisticsModel,
    this.sessionStatisticsModel,
  );
  //========================================================================
  // BOOTSTRAP PRIMES
  //========================================================================

  // dart format off
final initialPrimes = List<int>.of([
  2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31,
  37, 41, 43, 47, 53, 59, 61, 67, 71, 73,
  79, 83, 89, 97, 101, 103, 107, 109, 113,
  127, 131, 137, 139, 149, 151, 157, 163,
  167, 173, 179, 181, 191, 193, 197, 199
], growable: false);
// dart format on

  int initPrime = 0;
  int initPrimeStartingPoint = 4;
  int lastInitPrime = 199;
  int lastIndex = 45;

  //========================================================================
  // PRIME STORAGE
  //========================================================================

  Int64List primeCache = Int64List(156000000);
  int walker = 0;

  Int64List buffer1 = Int64List(13000000);
  int b1Walker = 0;

  Int64List buffer2 = Int64List(13000000);
  int b2Walker = 0;

  int maxBufferPrimes = 13000000;

  //String primeStorageFolderName;
  //String currentDriveLetter;
  //========================================================================
  // WHEELS
  //========================================================================

  // Used for numbers 21 - 199
  final miniWheel = List<int>.of([2, 4, 2, 2], growable: false);

  int miniWalker = 0;
  final int lastMini = 3;

  // Used for numbers > 199
  // dart format off
final primeWheel = List<int>.of([
  10,2,10,2,4,2,4,6,2,6,4,2,4,6,6,2,6,4,2,6,4,
  6,8,4,2,4,2,4,8,6,4,6,2,4,6,2,6,6,4,2,4,6,
  2,6,4,2,4,2
], growable: false);
// dart format on

  //int wheelPosition = 0;
  final int lastWalker = 47;

  //========================================================================
  // DISCOVERY STATE
  //========================================================================
  //String searchAlgorithm;

  bool firstRun = true;
  bool cycleStartTime = true;
  bool isPrime = true;

  bool time10Seconds = false;
  bool time1Minute = false;

  //first time application run this Cycle
  //(cycle being all runs included through recovery)
  DateTime initialCycleRunTime = DateTime.now();
  //Start time of this session when started from last break
  DateTime initialSessionRunTime = DateTime.now();

  int maxInt64 = 9223372036854775807;

  DateTime recoveryState = DateTime.now(); //initialize initial run point
  int startingTime = DateTime.now().millisecondsSinceEpoch;
  //========================================================================
  // BIGINT SUPPORT (FUTURE)
  //========================================================================

  final List<BigInt> megaPrimes = List<BigInt>.filled(10, BigInt.zero);
  // #endregion

  Future<void> discoverPrimes() async {
    //DateTime start = DateTime.now();

    // DateTime runStats = DateTime.now(); //Initialize statistics update time
    // Duration recoverTime = DateTime.now().difference(recoveryState);
    // int time10SecStart = DateTime.now().millisecondsSinceEpoch;
    // int time1MinStart = DateTime.now().millisecondsSinceEpoch;

    await primeTiny();
    await primeSmall();
    await primeAverage();
  }

  //==============================================================
  //primeTiny handles determination for numbers from 3 - 20
  //it only avoids even numbers by primeTiny +=2 in the for loop
  //==============================================================
  Future<void> primeTiny() async {
    for (int primeTiny = 3; primeTiny < 21; primeTiny += 2) {
      recoveryData.numGaps++; //each pass we have a gap of 2
      perMillionStatisticsModel.millNumGaps++;
      // gapSum += 2;
      // millGapSum += 2;
      while (primeTiny > initialPrimes[initPrime] && isPrime) {
        if (primeTiny % initialPrimes[initPrime] == 0) {
          initPrime = 0;
          isPrime = false;
        } else {
          initPrime++;
        }
      }
      if (isPrime) {
        processDeterminedPrime(
          primeTiny,
          recoveryData,
          sessionData,
          per1MinuteStatisticsModel,
          perTenSecondsStatisticsModel,
        );
      } else {
        isPrime = true;
        initPrime = 0;
        processCandidateNotPrime();
      }

      initPrime = 0;
    }
  }
  //=============
  //End primeTiny
  //=============

  //==========================================================
  //PrimeSmall handles determination for ints between 21 - 198
  //primeSmall uses a wheel to avoid multiples of 2 & 5
  //==========================================================
  Future<void> primeSmall() async {
    bool firstRun = true;

    for (
      int primeSmall = 21;
      primeSmall < lastInitPrime; //lastInitPrime = 199
      primeSmall += miniWheel[miniWalker]
    ) {
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
        processDeterminedPrime(
          primeSmall,
          recoveryData,
          sessionData,
          per1MinuteStatisticsModel,
          perTenSecondsStatisticsModel,
        );
      } else {
        isPrime = true;
        initPrime = 0;
        processCandidateNotPrime();
      }
      //======================================
      //Wheel for primeSmall
      //miniWalker points to the correct index
      //in List miniWheel
      //avoiding mutiples of 2 & 5
      //======================================
      if (!firstRun) {
        if (recoveryData.wheelPosition < lastMini) {
          recoveryData.wheelPosition++;
        } else {
          recoveryData.wheelPosition = 0;
        }
        recoveryData.numGaps++;
        perMillionStatisticsModel.millNumGaps++;
      }
      firstRun = false;
    }
  }
  //==============
  //End primeSmall
  //==============

  //============================================
  //primeAverage handles ints
  //199 - 9223372036854775807 aka maxInt64
  //uses a wheel to avoid multiples of 2,3,5 & 7
  //CREATED additional wheels to avoid multiples
  //of 11,13,17 & 19 forgot to write down when they
  //kick in.
  //============================================
  Future<void> primeAverage() async {
    firstRun = true;

    for (
      int primeAverage = lastInitPrime;
      primeAverage < maxInt64;
      primeAverage += primeWheel[recoveryData.wheelPosition]
    ) {
      //for each candidate
      //recoveryData.currentCandidateCount++;
      // gapSum += primeWheel[primeWalker];
      // millGapSum += miniWheel[miniWalker];
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
        processDeterminedPrime(
          primeAverage,
          recoveryData,
          sessionData,
          per1MinuteStatisticsModel,
          perTenSecondsStatisticsModel,
        );
        walker++;

        if (walker % 13000000 == 0) {
          print(
            'Writing file ${recoveryData.fileCount.toString().padLeft(5, '0')} '
            'with primes: ${commas(walker - 1000000)} thru ${commas(walker)} || The last determined prime was ${commas(primeAverage)}',
          );
          Duration recoverTime = DateTime.now().difference(recoveryState);

          print(
            'first Million Determined in: ${recoverTime.inSeconds} seconds',
          );

          await jsonWrite(
            recoveryData,
            configData,
            perMillionStatisticsModel,
          ); //UPDATE recovery json file every time new bin file is created.

          recoveryState = DateTime.now(); //reset json update time
          //call function to asynchronously write to file
          await writeFile(recoveryData, configData, primeCache);
          recoveryData.fileCount++;
        }
        //End Create File
      } else {
        isPrime = true;
        initPrime = 4;
        processCandidateNotPrime();
      }

      //=====================================
      //Wheel for primeAverage
      //following this pattern reduces
      //       numbers to check for primality
      //skipping numbers divisible by 2,3,5,7
      //=====================================
      if (!firstRun) {
        if (recoveryData.wheelPosition < lastWalker) {
          recoveryData.wheelPosition++;
        } else {
          recoveryData.wheelPosition = 0;
        }
        recoveryData.numGaps += 1;
        perMillionStatisticsModel.millNumGaps += 1;
      }

      firstRun = false;
    }
  }
  //================
  //End primeAverage
  //================

  //============================================
  //Smooth List transitions when reading primes
  //From buffers
  //============================================
  int getNextRead(int initPrime) {
    if (initPrime > 45 && initPrime <= 26000045) {
      return primeCache[initPrime - 46];
    }
    if (initPrime <= 45) {
      return initialPrimes[initPrime];
    }
    if (initPrime > 26000045 && initPrime <= 39000045) {
      return buffer1[initPrime - 26000046];
    }
    if (initPrime > 39000045 && initPrime <= 52000045) {
      return buffer2[initPrime - 39000046];
    }

    throw Exception('getNextRead() unsupported index: $initPrime');
  }

  int seconds(int ms) {
    return (ms / 1000).floor();
  }

  Future<void> recoveryRestart() async {
    //assign critical variables
    await jsonRecovery(recoveryData, configData, perMillionStatisticsModel);
  }

  void processCandidateNotPrime() {
    //10 SECOND
    perTenSecondsStatisticsModel.candidateCount10Sec++;
    //1 MINUTE
    per1MinuteStatisticsModel.candidateCount1Min++;
    //1 MILLION
    perMillionStatisticsModel.currentMillionCandidateCount++;
    //SESSION

    //CYCLE - RECOVERY
    recoveryData.currentCandidateCount++;

    //Time Check
    timeCheckController(
      perTenSecondsStatisticsModel,
      per1MinuteStatisticsModel,
      recoveryData,
    );
  }

  //to be handled by statistics
  /*   void largestGapBetweenPrimes() {
    if (gapSum > recoveryData.largestGap) {
      recoveryData.largestGap = recoveryData.gapSumTotal;
    }
  } */
}
