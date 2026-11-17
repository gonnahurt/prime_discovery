import 'dart:convert';
import 'dart:io';

import 'package:prime_discovery/models/config_model.dart';
import 'package:prime_discovery/models/recovery_model.dart';
import 'package:prime_discovery/models/statistics_model.dart';

//=======================
//All things JSON related
//=======================
//Verify JSON file exists or create it
//Called by startup_manager -  initial query calls determine first run
//first run calls json search
Future<bool> jsonSearch(
  RecoveryData recoveryData,
  ConfigData configData,
) async {
  File file = File(
    '${configData.primeStorageFolderName}\\${configData.fileNameJson}',
  );
  // Validate file existence
  return !await file.exists();
} //End jsonSearch

//Create JSON file
Future<void> jsonCreate(
  RecoveryData recoveryData,
  ConfigData configData,
  PerMillionStatisticsModel perMillionData,
  int initialRunTime,
) async {
  final Map<String, dynamic> stateData = {
    "version": recoveryData.versionNum,
    "fileCount": recoveryData.fileCount,
    "primesDiscoveredCount": recoveryData.primesDiscoveredCount,
    "lastPrime": recoveryData.currentPrime,
    "currentPrime": recoveryData.currentPrime,
    "wheelPosition": recoveryData.wheelPosition,
    "dateTimeCycleRun": recoveryData.cycleStartTime,
    "totalTimeActive": recoveryData.totalRuntime,
    "primeStorageFolderName": configData.primeStorageFolderName,
    "currentDriveLetter": configData.currentDriveLetter,
    "numberOfGaps": recoveryData.numGaps,
    "sumOfAllGaps": recoveryData.gapSumTotal,
    "numOfGapsInLastMillion": perMillionData.millNumGaps,
    "sumOfGapsInLastMillion": perMillionData.millGapSumTotal,
    "largestGapFound": recoveryData.largestGap,
  };

  File jsonFile = File(
    '${configData.currentDriveLetter}${configData.primeStorageFolderName}\\${configData.fileNameJson}',
  );

  try {
    // 3. Convert the Dart map into a pretty-printed JSON string
    // (Using JsonEncoder.withIndent('  ') adds clean line breaks and indents)
    final String jsonString = const JsonEncoder.withIndent('  ')
        .convert(stateData);

    // 4. Write the string asynchronously to the file
    await jsonFile.writeAsString(jsonString);

    print('Successfully created JSON file at: ${jsonFile.absolute.path}');
  } catch (e) {
    print('An error occurred while creating the file: $e');
  }
} //End jsonCreate

//Write to JSON file
Future<void> jsonWrite(
  RecoveryData recoveryData,
  ConfigData configData,
  PerMillionStatisticsModel perMillionData,
) async {
  final Map<String, dynamic> stateData = {
    "version": recoveryData.versionNum,
    "fileCount": recoveryData.fileCount,
    "primesDiscoveredCount": recoveryData.primesDiscoveredCount,
    //"lastPrime": recoveryData.currentPrime,
    "currentPrime": recoveryData.currentPrime,
    "wheelPosition": recoveryData.wheelPosition,
    "dateTimeCycleRun": recoveryData.cycleStartTime,
    "totalTimeActive": recoveryData.totalRuntime,
    "primeStorageFolderName": configData.primeStorageFolderName,
    "currentDriveLetter": configData.currentDriveLetter,
    "numberOfGaps": recoveryData.numGaps,
    "sumOfAllGaps": recoveryData.gapSumTotal,
    "numOfGapsInLastMillion": perMillionData.millNumGaps,
    "sumOfGapsInLastMillion": perMillionData.millGapSumTotal,
    "largestGapFound": recoveryData.largestGap,
  };

  final File jsonFile = File(
    '${configData.currentDriveLetter}${configData.primeStorageFolderName}\\${configData.fileNameJson}',
  );

  try {
    // 3. Convert the Dart map into a pretty-printed JSON string
    // (Using JsonEncoder.withIndent('  ') adds clean line breaks and indents)
    final String jsonString = const JsonEncoder.withIndent('  ')
        .convert(stateData);

    // 4. Write the string asynchronously to the file
    await jsonFile.writeAsString(jsonString);

    print('Successfully created JSON file at: ${jsonFile.absolute.path}');
  } catch (e) {
    print('An error occurred while creating the file: $e');
  }
} //End jsonWrite

//Read from JSON file
Future<void> jsonRecovery(
  RecoveryData recoveryData,
  ConfigData configData,
  PerMillionStatisticsModel perMillionStatisticsModel,
) async {
  final File jsonFile = File(
    '${configData.currentDriveLetter}'
    '${configData.primeStorageFolderName}\\'
    '${configData.fileNameJson}',
  );

  final String jsonString = await jsonFile.readAsString();

  final Map<String, dynamic> data = jsonDecode(jsonString);

  recoveryData.versionNum = data['version'];
  recoveryData.fileCount = data['fileCount'];
  recoveryData.primesDiscoveredCount = data['primesDiscoveredCount'];
  recoveryData.currentPrime = data['currentPrime'];
  recoveryData.wheelPosition = data['wheelPosition'];
  recoveryData.cycleStartTime = data['dateTimeCycleRun'];
  recoveryData.totalRuntime = data['totalTimeActive'];
  configData.primeStorageFolderName = data['primeStorageFolderName'];
  configData.currentDriveLetter = data['currentDriveLetter'];
  recoveryData.numGaps = data['numberOfGaps'];
  recoveryData.gapSumTotal = data['sumOfAllGaps'];
  perMillionStatisticsModel.millNumGaps = data['numOfGapsInLastMillion'];
  perMillionStatisticsModel.millGapSumTotal = data['sumOfGapsInLastMillion'];
  recoveryData.largestGap = data['largestGapFound'];
} //End jsonRead
//End - File
