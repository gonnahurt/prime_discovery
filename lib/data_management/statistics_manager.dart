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

import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/config_model.dart';
import 'package:prime_discovery/models/session_model.dart';

import 'time_manager.dart';

Future<String> runStatistics({
  required RecoveryData recoveryData,
  required ConfigData configData,
  required SessionData sessionData,
  required int currentPrime,
  required int candidatesCount,
  required int prevCandidateCount,
  required int prevDiscovered,
  required int primesDiscoveredLastSec,
}) async {
  String lastSec = inTheLastSecond(
    //this print is created in the function
    candidatesCount: candidatesCount,
    prevCandidateCount: prevCandidateCount,
    prevDiscovered: prevDiscovered,
    primesDiscoveredLastSec: primesDiscoveredLastSec,
  );

  //$pVarDensity% of all numbers up to $priorPrime are prime numbers
  String pVarDensity = pDensity(recoveryData: recoveryData);
  String pvdOut =
      ('$pVarDensity: % of all numbers up to ${recoveryData.currentPrime} are prime numbers ');

  //The average gap since prime 2 is: $lifetimeGap
  String lifetimeGap = gapAverageLifetime(recoveryData: recoveryData);

  String lgOut = ('$lifetimeGap: Average gap since prime 2');

  //$millionGap : Average gap size between current prime - 1000000 thru current prime
  String millionGap = gapAverageMillionPrimeLifespan(
    millNumGaps: recoveryData.millNumGaps,
    millGapSumTotal: recoveryData.millGapSumTotal,
  );
  String mgOut =
      ('$millionGap : Average gap size between current prime - 1000000 thru current prime');

  //$largestPrimeGap : Largest Gap between determined primes
  int largestPrimeGap = largestGapBetweenPrimes(
    recoveryData: recoveryData,
    sessionData: sessionData,
    
  );
  String lpgOut = ('$largestPrimeGap : Largest Gap between determined primes');
  String cycle = await timeSinceFirstRun(recoveryData, configData);
  String active = await totTimeActivelyRunning(recoveryData, configData);
  String session = await currentRunTime(recoveryData, configData);
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
}
//============
//END: runStatistics
//============

//===============================================================
//Prime density : Percentage of primed determined in Last integer
//can be run when ever we choose to display
//===============================================================
String pDensity({required RecoveryData recoveryData}) {
  double totPrimes = recoveryData.numPrimes.toDouble();
  double finalPrime = recoveryData.currentPrime.toDouble();
  double pDensityPercent = ((totPrimes / finalPrime * 100));
  return (formatToThreePlaces(pDensityPercent));
}
//==================
//END: Prime density
//==================

//============================================================================
//Lifetime average of gap size
//Average gap between primes over lifetime (starting from 2 - wherever we are
//============================================================================
String gapAverageLifetime({required RecoveryData recoveryData}) {
  double gapCount = recoveryData.numGaps.toDouble();
  double gapSum = recoveryData.gapSumTotal.toDouble();
  double lifetimeGap = gapSum / gapCount;
  return (formatToThreePlaces(lifetimeGap));
}
//=================================
//END: Lifetime average of gap size
//=================================

//=====================================
//Average gap size in the last 1million
//=====================================
String gapAverageMillionPrimeLifespan({
  required int millNumGaps,
  required int millGapSumTotal,
}) {
  double gapCount = millNumGaps.toDouble();
  double gapSum = millGapSumTotal.toDouble();
  double milLifespanGap = gapSum / gapCount;
  return (formatToThreePlaces(milLifespanGap));
}
//==========================================
//END: Average gap size in the last 1million
//==========================================

//===========================================
//Largest located gap between primes
//Must be run each time a prime is discovered
//===========================================
int largestGapBetweenPrimes({
  required RecoveryData recoveryData,
  required SessionData sessionData,  

}) {
  sessionData.currentGap = recoveryData.currentPrime - sessionData.priorPrime - 1;
  //int largestGap;
  if (sessionData.currentGap > recoveryData.largestGap) {
    recoveryData.largestGap = sessionData.currentGap;
  }
  return (recoveryData.largestGap);
}
//=======================================
//END: Largest located gap between primes
//=======================================

//=====================================================
//Candidates tested && Primes determined in last second
//=====================================================
String inTheLastSecond({
  required int candidatesCount,
  required int prevCandidateCount,
  required int prevDiscovered,
  required int primesDiscoveredLastSec,
}) {
  int candidatesTestedLastSec = candidatesCount - prevCandidateCount;
  int primedDiscoveredLastSec = primesDiscoveredLastSec - prevDiscovered;
  String inLastSecond =
      ('In the last second: $candidatesTestedLastSec were tested & $primedDiscoveredLastSec were determined');
  return (inLastSecond);
}
//==========================================================
//END: Candidates tested && Primes determined in last second
//==========================================================

//========================================
//format double to 3 spaces for continuity
//========================================
String formatToThreePlaces(double value) {
  return value.toStringAsFixed(3);
}
//=============================================
//END: format double to 3 spaces for continuity
//=============================================

//===================
//Function Create log
//===================
Future<void> logCreate(RecoveryData recoveryData, ConfigData configData) async {
  DateTime now = DateTime.now();
  String standardString = now.toString();
  //final separator = Platform.pathSeparator;
  final File logFile = File('${recoveryData.currentDriveLetter}${recoveryData.primeStorageFolderName}\\${configData.fileNameLog}');
  await logFile.writeAsString('''
Statistics-
File Created: $standardString
==================================================

''');
}

//Write to log
Future<void> appendToLog({
  required String formattedStats, required RecoveryData recoveryData, required ConfigData configData
}) async {
  //final separator = Platform.pathSeparator;
  final File logFile = File('${recoveryData.currentDriveLetter}${recoveryData.primeStorageFolderName}\\{$configData.fileNameLog}');
  try {
    await logFile.writeAsString(formattedStats, mode: FileMode.append);
    print('Content appended successfully.');
  } catch (e) {
    print('Error appending to file: $e');
  }
}
//END: Write to log
