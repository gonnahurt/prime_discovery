//times I want to see
//time since initial run
//time app actively running over time without a complete restart but pausing and stopping and restarting
//time current sessions running without break
//time between last 2 primes located
//number of primes found in last second
//number of candidates reviewed in last second
//estimated time to next file

import 'package:prime_discovery/models/recovery_model.dart';
//import ../models/configData;
import '../models/config_model.dart';

import 'json_manager.dart';
//import../models/RecoveryData

int getCurrentTime() {
  final current = DateTime.now().millisecondsSinceEpoch;
  return (current);
}

//time Since initial run includes all gaps in activity
//Essentially time from initial run to right now
Future<String> timeSinceFirstRun(
  RecoveryData recoveryData,
  ConfigData configData,
) async {

  int currentTime = getCurrentTime();
  int ms = currentTime - recoveryData.cycleStartTime;
  int years = (ms / 31795200000).floor();
  int months = ((ms % 31795200000)/2419200000).floor();
  int weeks = ((ms % 2419200000) /604800000).floor();
  int days = ((ms % 604800000) / 86400000).floor();
  int hours = ((ms % 86400000) / 3600000).floor();
  int mins = ((ms % 3600000) / 60000).floor();
  int secs = ((ms % 60000) / 1000).floor();

  return ('''This cycle has been running off and on for... 
$years years : $months months : $weeks weeks : $days days 
$hours hours : $mins minutes : $secs seconds ''');
}

//time Since initial run DOES NOT INCLUDE gaps of inactivity
//Essentially active session + active session + active session...
Future<String> totTimeActivelyRunning (
  RecoveryData recoveryData,
  ConfigData configData,
) async {
  
  int currentTime = getCurrentTime();
  int activeTime = currentTime - configData.sessionStartTime + recoveryData.activeRunTime;
  int ms = recoveryData.activeRunTime + activeTime;

  int years = (ms / 31795200000).floor();
  int months = ((ms % 31795200000)/2419200000).floor();
  int weeks = ((ms % 2419200000) /604800000).floor();
  int days = ((ms % 604800000) / 86400000).floor();
  int hours = ((ms % 86400000) / 3600000).floor();
  int mins = ((ms % 3600000) / 60000).floor();
  int secs = ((ms % 60000) / 1000).floor();

  return ('''This cycle has actively worked on determining primes for...
$years years : $months months : $weeks weeks : $days days 
$hours hours : $mins minutes : $secs seconds ''');
}

//Time this session has been active
Future<String> currentRunTime(RecoveryData recoveryData, ConfigData configData) async {
  
  int currentTime = getCurrentTime();
  int sessionTime = currentTime - configData.sessionStartTime;
  int ms = sessionTime;

  int years = (ms / 31795200000).floor();
  int months = ((ms % 31795200000)/2419200000).floor();
  int weeks = ((ms % 2419200000) /604800000).floor();
  int days = ((ms % 604800000) / 86400000).floor();
  int hours = ((ms % 86400000) / 3600000).floor();
  int mins = ((ms % 3600000) / 60000).floor();
  int secs = ((ms % 60000) / 1000).floor();

  return ('''The current session has been running for... 
$years years : $months months : $weeks weeks : $days days 
$hours hours : $mins minutes : $secs seconds ''');
}
