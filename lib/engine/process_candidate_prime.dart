import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/session_model.dart';
import 'package:prime_discovery/models/statistics_model.dart';
import 'package:prime_discovery/data_management/time_manager.dart';

void processCandidatePrime(
  int determinedPrime,
  RecoveryData recoveryData,
  SessionData sessionData,
  Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
) {
  //increment prime count
  recoveryData.primesDiscoveredCount = recoveryData.primesDiscoveredCount + 1;

  //priorPrime assigned currentPrime value - unsure if I need this
  sessionData.priorPrime = recoveryData.currentPrime;

  //Store new prime in recovery Data
  recoveryData.currentPrime = determinedPrime;

  //increment numGaps
  recoveryData.numGaps++;

  //10sec
  perTenSecondsStatisticsModel.candidateCount10Sec =
      perTenSecondsStatisticsModel.candidateCount10Sec + 1;
  perTenSecondsStatisticsModel.current10SecondPrimeCount =
      perTenSecondsStatisticsModel.current10SecondPrimeCount + 1;

  //1min
  per1MinuteStatisticsModel.candidateCount1Min =
      per1MinuteStatisticsModel.candidateCount1Min + 1;
  //per1MinuteStatisticsModel.candidateCount1Min++;
  per1MinuteStatisticsModel.primeCount1Min =
      per1MinuteStatisticsModel.primeCount1Min + 1;

  per1MinuteStatisticsModel.timeGapEnd1Min =
      DateTime.now().millisecondsSinceEpoch;

  int timeGap =
      per1MinuteStatisticsModel.timeGapEnd1Min -
      per1MinuteStatisticsModel.timeGapStart1Min;

  //if shortest Gap
  if (timeGap <
      per1MinuteStatisticsModel.gapTimeBetweenPrimesDetermined1MinShortest) {
    per1MinuteStatisticsModel.gapTimeBetweenPrimesDetermined1MinShortest =
        timeGap;
  }

  //if longest Gap
  if (timeGap >
      per1MinuteStatisticsModel.gapTimeBetweenPrimesDetermined1MinLongest) {
    per1MinuteStatisticsModel.gapTimeBetweenPrimesDetermined1MinLongest =
        timeGap;
  }

  //increment sum of timeGap to obtain average
  per1MinuteStatisticsModel.gapTimeSum1Min =
      per1MinuteStatisticsModel.gapTimeSum1Min + timeGap;

  //reset values for next prime gap
  per1MinuteStatisticsModel.timeGapStart1Min =
      DateTime.now().millisecondsSinceEpoch;

  //1million

  //Session

  //Cycle - Recovery
  recoveryData.currentCandidateCount = recoveryData.currentCandidateCount + 1;

  //Time Check
  timeCheckController(
    perTenSecondsStatisticsModel,
    per1MinuteStatisticsModel,
    recoveryData,
  );
}
