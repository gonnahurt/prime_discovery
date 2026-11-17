//import 'package:prime_discovery/engine/prime_discovery_engine.dart';
import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/config_model.dart';
import 'package:prime_discovery/models/statistics_model.dart';
import 'package:prime_discovery/models/session_model.dart';

import 'json_manager.dart';
import 'statistics_manager.dart';

import 'dart:async';

class Query {
  RecoveryData recoveryData = RecoveryData.initial();
  ConfigData configData = ConfigData.initial();
  SessionData sessionData = SessionData.initial();
  PerTenSecondsStatisticsModel perSecondData =
      PerTenSecondsStatisticsModel.initial();
  Per1MinuteStatisticsModel per1MinuteData =
      Per1MinuteStatisticsModel.initial();
  PerMillionStatisticsModel perMillionData =
      PerMillionStatisticsModel.initial();
  CycleStatisticsModel cycleStatisticsData = CycleStatisticsModel.initial();
  SessionStatisticsModel sessionStatisticsData =
      SessionStatisticsModel.initial();

  bool initialRun = true;
  int initialRunTime = 0;

  Future<void> initialRunQuery() async {
    int initial = DateTime.now().millisecondsSinceEpoch;
    initialRun = await jsonSearch(
      recoveryData,
      configData,
      // sessionData,
      // perSecondData,
      // perMillionData,
    );

    if (initialRun) {
      await ifFirstRunProtocols(initial);
    } else {
      await subsequentRunProtocol(initial);
    }
  }

  Future<void> ifFirstRunProtocols(int initial) async {
    //int currTime = DateTime.now().millisecondsSinceEpoch;
    recoveryData.cycleStartTime = initial;
    sessionData.sessionStartTime = initial;
    perSecondData.time10SecStart = initial;
    per1MinuteData.timeGapStart1Min = initial;
    perMillionData.prior1MllionTime = initial;
    cycleStatisticsData.priorCycleTime = initial;
    sessionStatisticsData.priorSessionTime = initial;

    await jsonCreate(recoveryData, configData, perMillionData, initial);
    await logCreate(recoveryData, configData);
  }

  Future<void> subsequentRunProtocol(int initial) async {
    //int currTime = DateTime.now().millisecondsSinceEpoch;
    sessionData.sessionStartTime = initial;
    perSecondData.time10SecStart = initial;
    per1MinuteData.timeGapStart1Min = initial;
    perMillionData.prior1MllionTime = initial;
    cycleStatisticsData.priorCycleTime = initial;
    sessionStatisticsData.priorSessionTime = initial;

    //grab data from 00000state.json
    //load into recoveryData
    //run time_manager
    //import primes into Lists
  }
}
