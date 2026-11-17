//Stats I want to see:
//Percent of numbers reviewed - wheel effectiveness : I want to see the difference our wheels make
//DONE: Percent of primes discovered - prime density : want to see how drastically this drops over time
//NO FUNTION REQUIRED: Last prime discovered count = last prime discovered ('the 500th prime is: 3571)
//DONE: Average gap between primes overtime (starting from 2 - wherever we are)
//DONE: Average gap between primes last 1million (starting from 1 - 1million, 1,000,001 - 2million, 2,000,001 - 3million  etc.)
//DONE: largest prime gap determined
//DONE: Search Rate: candidatesReviewed/sec * primesDiscoveredLastSec/sec
//Next File Count down - no biggie early on but when into bigInt territory could be interesting

/*
Prime Discovery

Wheel: wheel_19

Largest Number Tested:
12,456,882,731

Prime Count:
523,441,892

Last Prime:
12,456,882,719

Prime Density:
4.20%

Wheel Skip:
82.90%

Candidates/sec:
2,451,121
*/

//========================================
//Calls all calculations and generates the
//line to be printed or appended to log
//========================================
import 'dart:io';
import 'dart:async';
//import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/config_model.dart';
import 'package:prime_discovery/models/session_model.dart';
import 'package:prime_discovery/models/statistics_model.dart';
import 'package:prime_discovery/services/statistics_service.dart';

import '../utilities/formatters.dart';
import '../engine/process_determined_prime.dart';
import 'time_manager.dart';

// For All (10 Sec, 1 min, 1 million, cycle & session)
// DONE -- Candidates Tested //updated at is prime
// DONE -- Primes Determined
// DONE -- Candidates/sec
// DONE -- Primes/sec

// For All BUT 10 sec (1 min, 1 million, cycle & session)
// longest time between primes determined
// shortest time between primes determined //boring up front
// average time between primes determined
// wheel effectiveness

class Run10SecondStatistics {
  final RecoveryData recoveryData;
  final PerTenSecondsStatisticsModel perTenSecondsStatisticsModel;

  Run10SecondStatistics(this.recoveryData, this.perTenSecondsStatisticsModel);

  String concat = "";

  String display10SecondStatistics({
    required RecoveryData recoveryData,
    required PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  }) {
    return '''
        10 Second Statistics
        ==================== 
        ${getCycleTime()}         
        ${commas(recoveryData.primesDiscoveredCount)}: total primes discovered
        ${commas(recoveryData.currentPrime)}: largest prime discovered
        ${(candidatesTested_10SecManager(recoveryData: recoveryData, perTenSecondsStatisticsModel: perTenSecondsStatisticsModel))} 
        ${(candidatesEvaluatedPerSecond(recoveryData: recoveryData, perTenSecondsStatisticsModel: perTenSecondsStatisticsModel))} 
        ${(countPrimesDetermined_10SecManager(perTenSecondsStatisticsModel: perTenSecondsStatisticsModel))} 
        ${(primesDeterminedPerSecond(recoveryData: recoveryData, perTenSecondsStatisticsModel: perTenSecondsStatisticsModel))} 
        ${(wheelEffectivenessManager(recoveryData: recoveryData, perTenSecondsStatisticsModel: perTenSecondsStatisticsModel))} 
        ====================
        ''';
    //return (concat);
  }

  String getCycleTime() {
    int myTime = DateTime.now().millisecondsSinceEpoch;
    int cycleTime = 0;
    cycleTime = myTime - recoveryData.cycleStartTime;
    String cycleTimeDisplay = runtimeFormatting(
      cycleTime,
      "total cycle time: ",
    );
    return ('$cycleTimeDisplay\n');
  }

  String candidatesTested_10SecManager({
    //required RecoveryData recoveryData,
    required PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
    required RecoveryData recoveryData,
  }) {
    //RecoveryData recoveryData;
    int tested = perTenSecondsStatisticsModel.candidateCount10Sec;
    return ('Candidates Count: ${commas(tested)} candidates tested in last 10 seconds');
  }

  String candidatesEvaluatedPerSecond({
    required RecoveryData recoveryData,
    required PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  }) {
    PerTenSecondsStatisticsService service = PerTenSecondsStatisticsService();
    double averageCandidate = service.avgCandidatesEvaluatedPerSecondService(
      recoveryData,
      perTenSecondsStatisticsModel,
    );
    return ('Candidates Average: ${decimalFormatting(averageCandidate)} candidates were evaluated each second.');
  }

  String countPrimesDetermined_10SecManager({
    //required RecoveryData recoveryData,
    required PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
    //required PerTenSecondsStatisticsService erTenSecondsStatisticsService,
  }) {
    //PerTenSecondsStatisticsModel service = PerTenSecondsStatisticsModel();
    int testPrimeCount = perTenSecondsStatisticsModel.current10SecondPrimeCount;
    return ('Prime Count: ${commas(testPrimeCount)} primes determined in the last 10 seconds.');
  }

  String primesDeterminedPerSecond({
    required RecoveryData recoveryData,
    required PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  }) {
    PerTenSecondsStatisticsService service = PerTenSecondsStatisticsService();
    double averagePrime = service.avgPrimesDeterminedPerSecondService(
      recoveryData,
      perTenSecondsStatisticsModel,
    );
    return ('Prime Average: ${decimalFormatting(averagePrime)} primes were determined each second.');
  }

  String wheelEffectivenessManager({
    required RecoveryData recoveryData,
    required PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  }) {
    PerTenSecondsStatisticsService service = PerTenSecondsStatisticsService();
    double wheelEfficiency = service.wheelEffectivenessService(
      recoveryData,
      perTenSecondsStatisticsModel,
    );

    perTenSecondsStatisticsModel.candidateCount10Sec = 0;
    perTenSecondsStatisticsModel.current10SecondPrimeCount = 0;
    return ('The wheel structure decreased the candidates to be evaluated by ${wheelEfficiency}%');
  }

  // void display10secondsStatistics(
  //   RecoveryData recoveryData,
  //   PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  // ) {
  //   perTenSecondsStatisticsModel.prior10SecondPrimeCount =
  //       recoveryData.primesDiscoveredCount;
  // }
}

class Run1MinuteStatistics {
  final RecoveryData recoveryData;
  final Per1MinuteStatisticsModel per1MinuteStatisticsModel;

  Run1MinuteStatistics(this.recoveryData, this.per1MinuteStatisticsModel);

  String display1MinuteStatistics({
    required RecoveryData recoveryData,
    required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  }) {
    //RESET Values
    return '''
         1 Minute Statistics
         ==================== 
         ${getCycleTime()}
         ${commas(recoveryData.primesDiscoveredCount)}: total primes discovered
         ${commas(recoveryData.currentPrime)}: largest prime discovered
         ${(candidatesTested_1MinManager(recoveryData: recoveryData, per1MinuteStatisticsModel: per1MinuteStatisticsModel))}
         ${(candidatesEvaluatedPerSecond(recoveryData: recoveryData, per1MinuteStatisticsModel: per1MinuteStatisticsModel))}
         ${(countPrimesDetermined_1MinManager(per1MinuteStatisticsModel: per1MinuteStatisticsModel))}
         ${(primesDeterminedPerSecond(recoveryData: recoveryData, per1MinuteStatisticsModel: per1MinuteStatisticsModel))}
         ${(wheelEffectivenessManager(recoveryData: recoveryData, per1MinuteStatisticsModel: per1MinuteStatisticsModel))}
         ====================
         ''';

    //return ('');
    //return (concat);
  }

  String getCycleTime() {
    int myTime = DateTime.now().millisecondsSinceEpoch;
    int cycleTime = 0;
    cycleTime = myTime - recoveryData.cycleStartTime;
    String cycleTimeDisplay = runtimeFormatting(
      cycleTime,
      "total cycle time: ",
    );
    return ('$cycleTimeDisplay\n');
  }

  String candidatesTested_1MinManager({
    //required RecoveryData recoveryData,
    required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
    required RecoveryData recoveryData,
  }) {
    //RecoveryData recoveryData;
    int tested = per1MinuteStatisticsModel.candidateCount1Min;
    return ('Candidates Count: ${commas(tested)} candidates tested in last minute.');
  }

  String candidatesEvaluatedPerSecond({
    required RecoveryData recoveryData,
    required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  }) {
    PerMinuteStatisticsService service = PerMinuteStatisticsService();
    double averageCandidate = service.avgCandidatesEvaluatedPerSecondService(
      recoveryData,
      per1MinuteStatisticsModel,
    );
    return ('Candidates Average: ${decimalFormatting(averageCandidate)} candidates were evaluated each second.');
  }

  String countPrimesDetermined_1MinManager({
    //required RecoveryData recoveryData,
    required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
    //required PerTenSecondsStatisticsService erTenSecondsStatisticsService,
  }) {
    //PerTenSecondsStatisticsModel service = PerTenSecondsStatisticsModel();
    int testPrimeCount = per1MinuteStatisticsModel.primeCount1Min;
    return ('Prime Count: ${commas(testPrimeCount)} primes determined in the last Minute.');
  }

  String primesDeterminedPerSecond({
    required RecoveryData recoveryData,
    required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  }) {
    PerMinuteStatisticsService service = PerMinuteStatisticsService();
    double averagePrime = service.avgPrimesDeterminedPerSecondService(
      recoveryData,
      per1MinuteStatisticsModel,
    );
    return ('Prime Average: ${decimalFormatting(averagePrime)} primes were determined each second.');
  }

  String wheelEffectivenessManager({
    required RecoveryData recoveryData,
    required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  }) {
    PerMinuteStatisticsService service = PerMinuteStatisticsService();
    double wheelEfficiency = service.wheelEffectivenessService(
      recoveryData,
      per1MinuteStatisticsModel,
    );
    return ("");
  }

  // String longestTimeGap({
  //   required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  // }) {
  //   String header =
  //       "longest gap between 2 determined primes in the last minute:";
  //   PerMinuteStatisticsService service = PerMinuteStatisticsService();
  //   int longGap = service.longestTimeGapBetweenPrimes(
  //     per1MinuteStatisticsModel,
  //   );
  //   String longestPrimeGap = minuteFormatting(longGap, header);

  //   return (longestPrimeGap);
  // }

  // String shortestTimeGap({
  //   required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  // }) {
  //   String header =
  //       "Shortest gap between 2 determined primes in the last minute:";
  //   PerMinuteStatisticsService service = PerMinuteStatisticsService();
  //   int shortGap = service.shortestTimeGapBetweenPrimes(
  //     per1MinuteStatisticsModel,
  //   );
  //   String shortestPrimeGap = minuteFormatting(shortGap, header);

  //   return (shortestPrimeGap);
  // }

  // String averageTimeGap({
  //   required Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  // }) {
  //   String header =
  //       "Average gap time between determined primes in the last minute:";
  //   PerMinuteStatisticsService service = PerMinuteStatisticsService();
  //   double averageGap = service.averageTimeGapBetweenPrimes(
  //     per1MinuteStatisticsModel,
  //   );
  //   String averagePrimeGap = minuteFormatting(averageGap.toInt(), header);
  //   print("Average gap ms = $averageGap"); // For testing purposes
  //   return (averagePrimeGap);
  // }
}

// class runPerMillionPrimesStatistics {}

// class runSessionStatistics {}

// class runCycleStatistics {}

/* Future<String> runStatistics({
  required RecoveryData recoveryData,
  required ConfigData configData,
  required SessionData sessionData,
  required PerTenSecondsStatisticsModel perSecondData,
}) async {
  String lastSec = inTheLastSecond(
    perSecondData: perSecondData,
    recoveryData: recoveryData,
  );

  String session = await currentRunTime(recoveryData, sessionData, configData);

  String formattedStats =
      '''
      $lastSec
      $pvdOut
      $lgOut
      $mgOut
      $lpgOut
      $cycle
      $active
      $session
      =========================
      ''';
  recoveryData.currentPrime = sessionData.priorPrime;
  return (formattedStats);
} //END: runStatistics */

/* //===============================================================
//Prime density : Percentage of primed determined in Last integer
//calls primeDensity in statistics_service.dart
//===============================================================
String pDensity({required RecoveryData recoveryData}) {
  double pDensityPercent = primeDensity(recoveryData);
  return ('${formatToThreePlaces(pDensityPercent)}: % of all numbers up to ${recoveryData.currentPrime} are prime numbers ');
} //END: Prime density

//============================================================================
//Lifetime average of gap size
//Average gap between primes over lifetime (starting from 2 - wherever we are
//============================================================================
String gapAverageLifetime({required RecoveryData recoveryData}) {
  double lifetimeGap = lifetimeGapAverage(recoveryData);
  return ('${formatToThreePlaces(lifetimeGap)}: Average gap since prime 2');
} //END: Lifetime average of gap size

//Average gap size in the last 1million
String gapAverageMillionPrimeLifespan({required RecoveryData recoveryData}) {
  double milLifespanGap = millionPrimeGapAverage(recoveryData, perMillionData);
  return ('${formatToThreePlaces(milLifespanGap)}: Average gap size between current prime - 1000000 thru current prime');
} //END: Average gap size in the last 1million

//===========================================
//Largest located gap between primes
//Must be run each time a prime is discovered
//===========================================
String largestGapBetweenPrimes({
  required RecoveryData recoveryData,
  required SessionData sessionData,
}) {
  maxGapDetermined(recoveryData, sessionData);
  return ('${recoveryData.largestGap}: Largest Gap between determined primes');
} //END: Largest located gap between primes */

//=====================================================
//Candidates tested && Primes determined in last second
//=====================================================
/* String inTheLastSecond({
  required PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  required RecoveryData recoveryData,
}) {
  //String inLastSecond = buildLastSecondStatistics(recoveryData, perTenSecondsStatisticsModel);
  perTenSecondsStatisticsModel.prior10SecondCandidateCount =
      recoveryData.currentCandidateCount;
  perTenSecondsStatisticsModel.prior10SecondCandidateCount =
      recoveryData.primesDiscoveredCount;

  return (inLastSecond);
} //END: Candidates tested && Primes determined in last second */

//format double to 3 spaces for continuity
String formatToThreePlaces(double value) {
  return value.toStringAsFixed(3);
} //END: format double to 3 spaces for continuity

//Function Create log
Future<void> logCreate(RecoveryData recoveryData, ConfigData configData) async {
  DateTime now = DateTime.now();
  String standardString = now.toString();
  //final separator = Platform.pathSeparator;
  final File logFile = File(
    '${configData.currentDriveLetter}${configData.primeStorageFolderName}\\$configData.fileNameLog}',
  );
  await logFile.writeAsString('''
Statistics-
File Created: $standardString
==================================================

''');
} //END Create Log

//Write to log
Future<void> appendToLog({
  required String formattedStats,
  required RecoveryData recoveryData,
  required ConfigData configData,
}) async {
  //final separator = Platform.pathSeparator;
  final File logFile = File(
    '${configData.currentDriveLetter}${configData.primeStorageFolderName}\\{$configData.fileNameLog}',
  );
  try {
    await logFile.writeAsString(formattedStats, mode: FileMode.append);
    print('Content appended successfully.');
  } catch (e) {
    print('Error appending to file: $e');
  }
} //END: Write to log
