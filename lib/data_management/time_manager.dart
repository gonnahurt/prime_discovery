//times I want to see
//time since initial run
//time app actively running over time without a complete restart but pausing and stopping and restarting
//time current sessions running without break
//time between last 2 primes located
//number of primes found in last second
//number of candidates reviewed in last second
//estimated time to next file

import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/config_model.dart';
import 'package:prime_discovery/models/statistics_model.dart';
import 'package:prime_discovery/models/session_model.dart';
import 'package:prime_discovery/data_management/statistics_manager.dart';

import '../constants/time_constants.dart';

int getCurrentTime() {
  final current = DateTime.now().millisecondsSinceEpoch;
  return (current);
}

//TIME passed between values sent
Future<String> calculatedRunTime(
  int timeStart,
  int timeEnd,
  String printHeader,
) async {
  int ms = timeEnd - timeStart;
  //int ms = calculatedTime;
  String headerLine = printHeader;

  if (printHeader == "session") {
    headerLine = 'The current session has been running for:';
  } else if (printHeader == "cycle") {
    headerLine = 'The cycle has run off and on for:';
  } else if (printHeader == "activity") {
    headerLine = 'The cumalitive cycle activity has been:';
  }

  int years = (ms / 31795200000).floor();
  int months = ((ms % 31795200000) / 2419200000).floor();
  int weeks = ((ms % 2419200000) / 604800000).floor();
  int days = ((ms % 604800000) / 86400000).floor();
  int hours = ((ms % 86400000) / 3600000).floor();
  int mins = ((ms % 3600000) / 60000).floor();
  int secs = ((ms % 60000) / 1000).floor();
  int milli = (ms % 1000).floor();
  int micro = 0;

  return ('''$printHeader 
          $years years : $months months : $weeks weeks : $days days 
          $hours hours : $mins minutes : $secs seconds : $milli ms''');
}

//Determines when to call Statistics methods every 10 seconds & every minute
void timeCheckController(
  //int timeInMS
  PerTenSecondsStatisticsModel perTenSecondsStatisticsModel,
  Per1MinuteStatisticsModel per1MinuteStatisticsModel,
  RecoveryData recoveryData,
) {
  int synchronizedTime = getCurrentTime();

  Run10SecondStatistics run10SecStats = Run10SecondStatistics(
    recoveryData,
    perTenSecondsStatisticsModel,
  );
  time10SecCheck(
    synchronizedTime,
    perTenSecondsStatisticsModel,
    run10SecStats,
    recoveryData,
  );

  Run1MinuteStatistics runMinStats = Run1MinuteStatistics(
    recoveryData,
    per1MinuteStatisticsModel,
  );
  time1MinCheck(
    synchronizedTime,
    per1MinuteStatisticsModel,
    runMinStats,
    recoveryData,
  );
}

void time10SecCheck(
  //int time10SecStart,
  int synchronizedTime,
  perTenSecondsStatisticsModel,
  run10SecStats,
  recoveryData,
) {
  if ((synchronizedTime - perTenSecondsStatisticsModel.time10SecStart) >=
      tenSecondsMS) {
    String results = run10SecStats.display10SecondStatistics(
      perTenSecondsStatisticsModel: perTenSecondsStatisticsModel,
      recoveryData: recoveryData,
    );
    print(results);
    perTenSecondsStatisticsModel.time10SecStart =
        perTenSecondsStatisticsModel.time10SecStart + tenSecondsMS;
  }
}

//   Run1MinuteStatistics run1MinuteStats = Run1MinuteStatistics(
//     recoveryData,
//     per1MinuteStatisticsModel,
//   );
//   time1MinCheck(synchronizedTime, per1MinuteStatisticsModel, recoveryData);
// }

void time1MinCheck(
  int synchronizedTime,
  per1MinuteStatisticsModel,
  runMinStats,
  recoveryData,
) {
  if ((synchronizedTime - per1MinuteStatisticsModel.prior1MinTime) >=
      oneMinuteMS) {
    String results = runMinStats.display1MinuteStatistics(
      per1MinuteStatisticsModel: per1MinuteStatisticsModel,
      recoveryData: recoveryData,
    );
    print(results);
    per1MinuteStatisticsModel.prior1MinTime =
        per1MinuteStatisticsModel.prior1MinTime + oneMinuteMS;
  }
}
// void setAndGetAllStartTimes() {
//   {}
//   Future<void> wheelSelect() async {}
// }
