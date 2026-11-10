//import 'package:prime_discovery/engine/prime_discovery_engine.dart';
import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/config_model.dart';
import 'package:prime_discovery/models/session_model.dart';

import 'json_manager.dart';
import 'statistics_manager.dart';

import 'dart:async';

class Query {
  RecoveryData recoveryData = RecoveryData.initial();
  ConfigData configData = ConfigData.initial();
  SessionData sessionData = SessionData.initial();

  bool initialRun = true;
  int initialRunTime = 0;

  Future<void> initialRunQuery() async {
    DateTime initial = DateTime.now();
    initialRun = await determineFirstRun();

    if (initialRun) {
      await jsonCreate(
        recoveryData,
        configData,
        //sessionData,
        initial,
      );
      await logCreate(recoveryData, configData,);
      //PrimeDiscoveryEngine();
      //return (0);
    } else {
      //DateTime current = DateTime.now();
      //extract last run data from JSON
      //feed data to primeDiscovery
      //return (0);
    }
  }

  Future<bool> determineFirstRun() async {
      initialRun = await jsonSearch(
      recoveryData,
      configData,
      //sessionData,
    );
    return (initialRun);
  }
}
