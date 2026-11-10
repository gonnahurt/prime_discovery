import 'dart:convert';
import 'dart:io';

import 'package:prime_discovery/models/config_model.dart';

import '../models/recovery_model.dart';

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
    '${recoveryData.primeStorageFolderName}\\${configData.fileNameJson}',
  );
  // Validate file existence
  return !await file.exists();
} //End jsonSearch

//Create JSON file
Future<void> jsonCreate(
  RecoveryData recoveryData,
  ConfigData configData,
  DateTime initialRunTime,
) async {
  final Map<String, dynamic> stateData = {
    "version": recoveryData.versionNum,
    "fileCount": recoveryData.fileCount,
    "numPrimes": recoveryData.numPrimes,
    "lastPrime": recoveryData.currentPrime,
    "currentPrime": recoveryData.currentPrime,
    "wheelPosition": recoveryData.wheelPosition,
    "dateTimeCycleRun": recoveryData.cycleStartTime,
    "totalTimeActive": recoveryData.totalRuntime,
    "primeStorageFolderName": recoveryData.primeStorageFolderName,
    "currentDriveLetter": recoveryData.currentDriveLetter,    
    "numberOfGaps": recoveryData.numGaps,
    "sumOfAllGaps": recoveryData.gapSumTotal,
    "numOfGapsInLastMillion": recoveryData.millNumGaps,
    "sumOfGapsInLastMillion": recoveryData.millGapSumTotal,
    "largestGapFound": recoveryData.largestGap,
  };

  File jsonFile = File(
    '${recoveryData.currentDriveLetter}${recoveryData.primeStorageFolderName}\\${configData.fileNameJson}',
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
Future<void> jsonWrite(RecoveryData recoveryData, ConfigData configData) async {
  final Map<String, dynamic> stateData = {
    "version": recoveryData.versionNum,
    "fileCount": recoveryData.fileCount,
    "numPrimes": recoveryData.numPrimes,
    "lastPrime": recoveryData.currentPrime,
    "wheelPosition": recoveryData.wheelPosition,
    "dateTimeCycleRun": recoveryData.cycleStartTime,
    //"dateTimeSessionRun": configData.sessionStartTime,
    "totalTimeActive": recoveryData.totalRuntime,
    "primeStorageFolderName": recoveryData.primeStorageFolderName,
    "primeStorageDriveLetter": recoveryData.currentDriveLetter,
    "numberOfGaps": recoveryData.numGaps,
    "sumOfAllGaps": recoveryData.gapSumTotal,
    "numOfGapsInLastMillion": recoveryData.millNumGaps,
    "sumOfGapsInLastMillion": recoveryData.millGapSumTotal,
    "largestGapFound": recoveryData.largestGap,
  }; 

  final File jsonFile = File(
    '${recoveryData.currentDriveLetter}${recoveryData.primeStorageFolderName}\\${configData.fileNameJson}',
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
Future<Map<String, dynamic>> jsonRead(
  RecoveryData recoveryData,
  ConfigData configData,
) async {
  final String jsonString = await File(
    '${recoveryData.currentDriveLetter}${recoveryData.primeStorageFolderName}\\${configData.fileNameJson}',
  ).readAsString();
  return jsonDecode(jsonString) as Map<String, dynamic>;
} //End jsonRead
//End - File
