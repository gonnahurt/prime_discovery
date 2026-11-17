import 'dart:io';
import 'dart:async';

import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/config_model.dart';
import 'package:prime_discovery/models/session_model.dart';
import 'package:prime_discovery/models/statistics_model.dart';

import '../constants/time_constants.dart';

import '../engine/process_determined_prime.dart';

//***10 SECONDS***\\
class PerTenSecondsStatisticsService {
  //Candidates reviewed in last 10 seconds
  void candidates10SecTestedService(
    RecoveryData recoveryData,
    PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  ) {
    //updated in prime_discovery_engine - see processLocatedPrime() & processCandidateNotPrime()
  }

  void count10SecPrimesDeterminedService(
    RecoveryData recoveryData,
    PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  ) {
    //updated in prime_discovery_engine - see processLocatedPrime() & processCandidateNotPrime()
  }

  double avgCandidatesEvaluatedPerSecondService(
    RecoveryData recoveryData,
    PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  ) {
    return (perTenSecondsStatisticsModel.candidateCount10Sec / tenSeconds);
  }

  double avgPrimesDeterminedPerSecondService(
    RecoveryData recoveryData,
    PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  ) {
    return (perTenSecondsStatisticsModel.current10SecondPrimeCount /
        tenSecondsMS);
  }

  double wheelEffectivenessService(
    RecoveryData recoveryData,
    PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  ) {
    int countStart = perTenSecondsStatisticsModel.startingInteger10Sec;
    int countFinish = perTenSecondsStatisticsModel.endingInteger10Sec;
    int count = countFinish - countStart;
    return ((count - perTenSecondsStatisticsModel.candidateCount10Sec) /
        count *
        100);
  }
}

//***1 MINUTE***\\
class PerMinuteStatisticsService {
  void candidates1MinTestedService(
    RecoveryData recoveryData,
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    //Place Holder
    //updated in prime_discovery_engine -
    //see processLocatedPrime() & processCandidateNotPrime()
  }

  void count1MinPrimesDeterminedService(
    RecoveryData recoveryData,
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    //Place Holder
    //updated in prime_discovery_engine -
    //see processLocatedPrime() & processCandidateNotPrime()
  }

  double avgCandidatesEvaluatedPerSecondService(
    RecoveryData recoveryData,
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    return ((per1MinuteStatisticsModel.candidateCount1Min / tenSeconds));
  }

  double avgPrimesDeterminedPerSecondService(
    RecoveryData recoveryData,
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    return (per1MinuteStatisticsModel.primeCount1Min / tenSecondsMS);
  }

  double wheelEffectivenessService(
    RecoveryData recoveryData,
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    int countStart = per1MinuteStatisticsModel.priorMinuteInteger;
    int countFinish = per1MinuteStatisticsModel.currentMinuteInteger;
    int count = countFinish - countStart;
    return ((count - per1MinuteStatisticsModel.candidateCount1Min) /
        count *
        100);
  }

  // int timeBetweenPrimesLongest(
  //   RecoveryData recoveryData,
  //   Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  // ) {
  //   //PlaceHolder - determined in process_determined_prime.dart
  //   return (per1MinuteStatisticsModel
  //       .gapTimeBetweenPrimesDetermined1MinLongest);
  // }

  // //PlaceHolder - determined in process_determined_prime.dart
  // int timeBetweenPrimesShortest(
  //   RecoveryData recoveryData,
  //   Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  // ) {
  //   return (per1MinuteStatisticsModel
  //       .gapTimeBetweenPrimesDetermined1MinShortest);
  // }

  // double timeBetweenPrimesAverage(
  //   RecoveryData recoveryData,
  //   Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  // ) {
  //   double primeAvg = (per1MinuteStatisticsModel.gapTimeSum1Min / oneMinute);
  //   return (primeAvg);
  // }

  int shortestTimeGapBetweenPrimes(
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    return (per1MinuteStatisticsModel
        .gapTimeBetweenPrimesDetermined1MinShortest);
  }

  int longestTimeGapBetweenPrimes(
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    return (per1MinuteStatisticsModel
        .gapTimeBetweenPrimesDetermined1MinLongest);
  }

  double averageTimeGapBetweenPrimes(
    Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  ) {
    double gapAverage =
        (per1MinuteStatisticsModel.gapTimeSum1Min /
        (per1MinuteStatisticsModel.primeCount1Min - 1));
    return (gapAverage);
  }
}

//***1 MILLION***\\
class PerMillionStatisticsService {}

//***SESSION***\\
class SessionStatisticsService {}

//***CYCLE***\\
class CycleStatisticsService {}

double primeDensity(RecoveryData recoveryData) {
  double primePercent =
      (recoveryData.primesDiscoveredCount.toDouble() -
      recoveryData.currentPrime.toDouble());
  return (primePercent);
}

double lifetimeGapAverage(RecoveryData recoveryData) {
  double gapAverage =
      recoveryData.numGaps.toDouble() / recoveryData.gapSumTotal.toDouble();
  return (gapAverage);
}

double millionPrimeGapAverage(
  RecoveryData recoveryData,
  PerMillionStatisticsModel perMillionData,
) {
  double mGapAverage =
      (perMillionData.millGapSumTotal / perMillionData.millNumGaps);
  return (mGapAverage);
}

void maxGapDetermined(RecoveryData recoveryData, SessionData sessionData) {
  sessionData.currentGap =
      recoveryData.currentPrime - sessionData.priorPrime - 1;
  if (sessionData.currentGap > recoveryData.largestGap) {
    recoveryData.largestGap = sessionData.currentGap;
  }
}
