/*=============================
Author: Kvoc
Erosthenes Sieve
Date Started: 10/29/26
Last Worked:  11/01/26
=============================*/

//import 'dart:convert';
import 'dart:math';
//import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import '../data_management/json_manager.dart';
import '../data_management/file_manager.dart';
import '../data_management/statistics_manager.dart';

import '../models/config_model.dart';
import '../models/recovery_model.dart';
import '../models/session_model.dart';

class PrimeDiscoveryEngine {
  // #region Discovery State
  final RecoveryData recoveryData;
  final ConfigData configData;
  final SessionData sessionData;

  PrimeDiscoveryEngine(this.recoveryData, this.configData, this.sessionData);
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

  Int64List primeCache = Int64List(150000000);
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

  int wheelPosition = 0;
  final int lastWalker = 47;

  //========================================================================
  // DISCOVERY STATE
  //========================================================================
  //String searchAlgorithm;

  bool firstRun = true;
  bool cycleStartTime = true;
  bool isPrime = true;

  //first time application run this Cycle
  //(cycle being all runs included through recovery)
  DateTime initialCycleRunTime = DateTime.now();
  //Start time of this session when started from last break
  DateTime initialSessionRunTime = DateTime.now();
  int totalRuntime = 0;
  int currentRuntime = 0;

  int currentPrime = 2;
  int lastPrime = 2;

  int maxInt64 = 9223372036854775807;

  int gapSumTotal = 1;
  int millGapSumTotal = 1;
  //========================================================================
  // COUNTERS
  //========================================================================

  int candidatesCount = 0;
  int numPrimes = 1;

  int gapSum = 0;
  int numGaps = 1;
  int millNumGaps = 1;

  int prevCandidateCount = 3;
  int prevPrimeCount = 2;

  int wastedChecks = 0;

  //========================================================================
  // RECOVERY / FILE MANAGEMENT
  //========================================================================

  //static const String primeStoragePath = r'P:\PrimeDiscovery';

  //int fileCount = 1;
  //int version = 1;

  //String fileNameLog = "00000statistics.log";
  //String fileNameJSON = "00000state.json";

  Duration fiveMins = const Duration(milliseconds: 300000);

  //========================================================================
  // STATISTICS
  //========================================================================



  int prevCandidate = 1;
  int prevDiscovered = 1;

  //========================================================================
  // BIGINT SUPPORT (FUTURE)
  //========================================================================

  final List<BigInt> megaPrimes = List<BigInt>.filled(10, BigInt.zero);
  // #endregion

  Future<void> discoverPrimes() async {
    //DateTime start = DateTime.now();
    DateTime recoveryState = DateTime.now(); //initialize initial run point
    DateTime runStats = DateTime.now(); //Initialize statistics update time
    //DateTime current = DateTime.now(); //Initialize current runtime
    //DateTime total = DateTime.now(); //Initialize total runtime

    Duration recoverTime = DateTime.now().difference(recoveryState);
    //initialCycleRunTime = DateTime.now();

    //==============================================================
    //primeTiny handles determination for numbers from 3 - 20
    //it only avoids even numbers by primeTiny +=2 in the for loop
    //==============================================================
    for (int primeTiny = 3; primeTiny < 21; primeTiny += 2) {
      candidatesCount++;
      recoveryData.numGaps++; //each pass we have a gap of 2
      recoveryData.millNumGaps++;
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
        processLocatedPrime(primeTiny);
      } else {
        isPrime = true;
        initPrime = 0;
      }


      initPrime = 0;
    }
    // 20 - 3 = 17 total integers : 
    //candidatesCount = 9 : 
    //20 = last int checked : 
    //num primes = 7 : 
    //7 primes in 17 integers is 42% : 
    //9 candidates in 18 total integers is 50% of all integers processed
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
      //gapSum += miniWheel[miniWalker];
      //millGapSum += miniWheel[miniWalker];
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
        processLocatedPrime(primeSmall);
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
          recoveryData.wheelPosition++;
        } else {
          recoveryData.wheelPosition = 0;
        }
        recoveryData.numGaps++;
        recoveryData.millNumGaps++;
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
      primeAverage += primeWheel[wheelPosition]
    ) {
      //for each candidate
      candidatesCount++;
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
        processLocatedPrime(primeAverage);
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
          ); //UPDATE recovery json file every time new bin file is created.

          recoveryState = DateTime.now(); //reset json update time
          //call function to asynchronously write to file
          await writeFile(recoveryData, primeCache);
          recoveryData.fileCount++;
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
        if (wheelPosition < lastWalker) {
          recoveryData.wheelPosition++;
        } else {
          recoveryData.wheelPosition = 0;
        }
        recoveryData.numGaps += 1;
        recoveryData.millNumGaps += 1;
      }

      firstRun = false;

      //check if 5 minutes have passed and update json when it has
      DateTime end = DateTime.now();
      Duration recoverTime = end.difference(recoveryState);
      if (recoverTime >= fiveMins) {
        await jsonWrite(
          recoveryData,
          configData,
        ); //UPDATE recovery json file every time new bin file is created.}
        recoveryState = DateTime.now(); //reset json update time
      }

      Duration statsEverySec = end.difference(runStats);
      if (statsEverySec.inMilliseconds >= 1000) {
        //prevCandidate = candidatesCount;
        String display = await runStatistics(
          recoveryData: recoveryData,
          configData: configData,
          sessionData: sessionData,
          currentPrime: currentPrime,
          candidatesCount: candidatesCount,
          prevCandidateCount: prevCandidate,
          prevDiscovered: prevDiscovered,
          primesDiscoveredLastSec: numPrimes,
        );
        print(display);
        appendToLog(
          formattedStats: display,
          recoveryData: recoveryData,
          //'${recoveryData.currentDriveLetter}${recoveryData.primeStorageFolderName}',
          //currentDriveLetter: recoveryData.currentDriveLetter,
          //primeStorageFolderName: recoveryData.primeStorageFolderName,
          //fileName: configData.fileNameLog,
          configData: configData,
        );
        prevCandidate = candidatesCount;
        prevDiscovered = numPrimes;
        runStats = DateTime.now();
      }
      //recoverTime = DateTime.now().difference(recoveryState);
    }
    //================
    //End primeAverage
    //================

    print('$numPrimes primes determined');
    print('$candidatesCount numbers checked for primality');
    //Duration recoverTime = DateTime.now().difference(recoveryState);

    print('first 13 Million Determined in: ${recoverTime.inSeconds} seconds');
    //print('first 13 Million Determined in: ${end.difference(start).inMilliseconds} ms');
  }

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
    final Map<String, dynamic> data = await jsonRead(recoveryData, configData);
    recoveryData.versionNum = data['version'];
    recoveryData.fileCount = data['fileCount'];
    recoveryData.numPrimes = data['numPrimes'];
    recoveryData.currentPrime = data['currentPrime'];
    recoveryData.wheelPosition = data['wheelPosition'];
    recoveryData.cycleStartTime = data['dateTimeCycleRun']; //First Time application ran for this cycle where cycle = on again off again usage without a restart from scratch
    recoveryData.totalRuntime = data['totalTimeActive'];
    recoveryData.primeStorageFolderName = data['primeStorageFolderName'];
    recoveryData.currentDriveLetter = data['currentDriveLetter'];
    //recoveryData.primeStoragePath:  '${recoveryData.currentDriveLetter}${recoveryData.primeStorageFolderName}',
    recoveryData.numGaps = data['numGaps'];
    recoveryData.gapSumTotal = data['gapSumTotal'];
    recoveryData.millNumGaps = data['millNumGaps'];
    recoveryData.millGapSumTotal = data['millGapSumTotal'];
    recoveryData.largestGap = data['largestGap'];
  }

      void processLocatedPrime(int determinedPrime) {
        recoveryData.numPrimes = recoveryData.numPrimes++;
        lastPrime = currentPrime;
        sessionData.priorPrime = recoveryData.currentPrime;
        recoveryData.currentPrime = determinedPrime;
        recoveryData.numGaps = recoveryData.numGaps++;
        gapSum += (currentPrime - lastPrime);
        largestGapBetweenPrimes();
      }
      
  void largestGapBetweenPrimes() {
    if (gapSum > recoveryData.largestGap) {
      recoveryData.largestGap = recoveryData.gapSumTotal;
    }
  }

  Future<void> wheelSelect() async {}
}
