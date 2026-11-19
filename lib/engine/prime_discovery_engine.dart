/*=============================
Author: Kvoc
Erosthenes Sieve
Date Started: 10/29/26
Complete Rewrite: 11/17/26
Last Worked:  11/18/26


=============================*/

import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import '../data_management/json_manager.dart';

import '../models/config_model.dart';
import '../models/recovery_model.dart';
import '../models/session_model.dart';
import '../models/statistics_model.dart';
import 'process_candidate_prime.dart';
import 'process_candidate_not_prime.dart';

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

  //int currentCandidate = 2;

  int skipInitialPrimes = 0;

  // List to store determined primes
  Int64List primeCache = Int64List(156000000);
  //List to store gaps to only evaluate candidates indivisible by numbers up to wheel number
  final primeWheel = List<int>.of([], growable: true);

  int candidateSqrt = 0;

  bool wheel_01 = false;
  bool wheel_02 = false;
  bool wheel_05 = false;
  bool wheel_07 = false;
  bool wheel_11 = false;
  bool wheel_13 = false;
  bool wheel_17 = false;
  bool wheel_19 = false;
  bool wheelChecksComplete = false;

  bool isPrime = true;

  int maxInt64 = 9223372036854775807;

  Future<void> primeDetermination() async {
    //while loop takes us through candidates 2 - maxInt64
    while (recoveryData.currentCandidate <= maxInt64) {
      isPrime = true;

      //Set the wheel if necessary
      if (!wheelChecksComplete) {
        await wheelDetermine();
      }
      candidateSqrt = sqrt(recoveryData.currentCandidate).floor();
      print(
        'Candidate=${recoveryData.currentCandidate} '
        'WheelPos=${recoveryData.wheelPosition}',
      );
      //Evaluate candidates for primality
      for (
        int i = skipInitialPrimes;
        i < recoveryData.primesDiscoveredCount;
        i++
      ) {
        //BENCHMARK AT LATER DATE
        // if (candidateSqrt == sqrt(recoveryData.currentCandidate).floorToDouble()) {
        //   isPrime = false;
        //   break;
        // } else {
        //   candidateSqrt = sqrt(recoveryData.currentCandidate).floorToDouble();
        // }

        if (primeCache[i] > candidateSqrt) {
          break;
        }
        if (recoveryData.currentCandidate % primeCache[i] == 0) {
          isPrime = false;
          break;
        }
      }
      if (isPrime) {
        //int determinedPrime = recoveryData.currentCandidate;
        primeCache[recoveryData.primesDiscoveredCount] =
            recoveryData.currentCandidate;
        if (recoveryData.primesDiscoveredCount < 100) {
          print(
            'Prime #${recoveryData.primesDiscoveredCount + 1}: '
            '${recoveryData.currentCandidate}',
          );
        }
        if (recoveryData.currentCandidate >= 199 &&
            recoveryData.currentCandidate < 300) {
          print(
            'Candidate=${recoveryData.currentCandidate} '
            'WheelPos=${recoveryData.wheelPosition}',
          );
        }
        processCandidatePrime(
          recoveryData.currentCandidate,
          recoveryData,
          sessionData,
          per1MinuteStatisticsModel,
          perTenSecondsStatisticsModel,
        );
      } else {
        //call process_candidate_not_prime
        processCandidateNotPrime(
          recoveryData,
          sessionData,
          per1MinuteStatisticsModel,
          perTenSecondsStatisticsModel,
        );
      }

      recoveryData.currentCandidate =
          recoveryData.currentCandidate +
          primeWheel[recoveryData.wheelPosition];
      wheelPositionLoop();
    } //END while
  } //END Method Prime Determination

  void wheelPositionLoop() {
    recoveryData.wheelPosition++;
    if (recoveryData.wheelPosition < primeWheel.length) {
    } else {
      recoveryData.wheelPosition = 0;
    }
  }

  //determine correct gap wheel and assign values from file 1 time
  Future<void> wheelDetermine() async {
    if (recoveryData.currentCandidate >= 2 &&
        recoveryData.currentCandidate < 5 &&
        !wheel_01) {
      recoveryData.currentCandidate = 2;
      skipInitialPrimes = 0;
      String filename = 'assets/wheels/wheel_01.bin';
      await wheelEmploy(filename);
      wheel_01 = true;
      return;
    }

    if (recoveryData.currentCandidate >= 5 &&
        recoveryData.currentCandidate < 19 &&
        !wheel_02) {
      recoveryData.currentCandidate = 5;
      skipInitialPrimes = 1;
      String filename = 'assets/wheels/wheel_02.bin';
      await wheelEmploy(filename);
      wheel_02 = true;
      return;
    }

    if (recoveryData.currentCandidate >= 19 &&
        recoveryData.currentCandidate < 199 &&
        !wheel_05) {
      recoveryData.currentCandidate = 19;
      skipInitialPrimes = 3;
      String filename = 'assets/wheels/wheel_05.bin';
      await wheelEmploy(filename);
      wheel_05 = true;
      return;
    }

    if (recoveryData.currentCandidate >= 199 &&
        recoveryData.currentCandidate < 2297 &&
        !wheel_07) {
      recoveryData.currentCandidate = 199;
      skipInitialPrimes = 4;
      String filename = 'assets/wheels/wheel_07.bin';
      await wheelEmploy(filename);
      wheel_07 = true;
      return;
    }

    if (recoveryData.currentCandidate >= 2297 &&
        recoveryData.currentCandidate < 30029 &&
        !wheel_11) {
      recoveryData.currentCandidate = 2297;
      skipInitialPrimes = 5;
      String filename = 'assets/wheels/wheel_11.bin';
      await wheelEmploy(filename);
      wheel_11 = true;
      return;
    }

    if (recoveryData.currentCandidate >= 30029 &&
        recoveryData.currentCandidate < 510491 &&
        !wheel_13) {
      recoveryData.currentCandidate = 30029;
      skipInitialPrimes = 6;
      String filename = 'assets/wheels/wheel_13.bin';
      await wheelEmploy(filename);
      wheel_13 = true;
      return;
    }

    if (recoveryData.currentCandidate >= 510491 &&
        recoveryData.currentCandidate < 9699669 &&
        !wheel_17) {
      recoveryData.currentCandidate = 510491;
      skipInitialPrimes = 7;
      String filename = 'assets/wheels/wheel_17.bin';
      await wheelEmploy(filename);
      wheel_17 = true;
      return;
    }

    if (recoveryData.currentCandidate >= 9699669 && !wheel_19) {
      recoveryData.currentCandidate = 9699669;
      skipInitialPrimes = 8;
      String filename = 'assets/wheels/wheel_19.bin';
      await wheelEmploy(filename);
      wheel_19 = true;
      wheelChecksComplete = true;
    }
  }

  //import the gaps from the file into primeWheel
  Future<void> wheelEmploy(String fileName) async {
    primeWheel.clear();

    final file = File(fileName);
    final Uint8List bytes = await file.readAsBytes();
    final ByteData byteData = ByteData.sublistView(bytes);

    final int count = bytes.lengthInBytes ~/ 2;

    // Step through 8 bytes at a time
    for (int offset = 0; offset < count; offset++) {
      // Change Endian.little to Endian.big if your file was written as big-endian
      int number = byteData.getUint16(offset * 2, Endian.little);
      primeWheel.add(number);
    }
    recoveryData.wheelPosition = 0;
  }

  Future<void> recoveryRestart() async {
    //assign critical variables
    await jsonRecovery(recoveryData, configData, perMillionStatisticsModel);
  }
} //END Class PrimeDiscoveryEngine
