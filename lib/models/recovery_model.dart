//import 'dart:convert';

class RecoveryData {
  int versionNum;
  int fileCount;
  int numPrimes;
  int currentPrime;
  //int priorPrime;
  int wheelPosition;
  int cycleStartTime;
  int totalRuntime;
  int activeRunTime;
  String primeStorageFolderName = r'PrimeDiscovery';
  String currentDriveLetter = r'P:\';
  int numGaps;
  int gapSumTotal;
  int millNumGaps;
  int millGapSumTotal;
  int largestGap;


  RecoveryData({
    required this.versionNum,
    required this.fileCount,
    required this.numPrimes,
    required this.currentPrime,
    //required this.priorPrime,
    required this.wheelPosition,
    required this.cycleStartTime,
    required this.totalRuntime,
    required this.activeRunTime,
    required this.primeStorageFolderName,
    required this.currentDriveLetter,
    required this.numGaps,
    required this.gapSumTotal,
    required this.millNumGaps,
    required this.millGapSumTotal,
    required this.largestGap,
  });

  RecoveryData.initial()
    : versionNum = 1,
      fileCount = 1,
      numPrimes = 1,
      currentPrime = 2,
      //priorPrime = 2,
      wheelPosition = 0,
      cycleStartTime = DateTime.now().millisecondsSinceEpoch,
      activeRunTime = DateTime.now().millisecondsSinceEpoch,
      totalRuntime = 0,
      primeStorageFolderName = r'PrimeDiscovery',
      currentDriveLetter = r'P:\',
      numGaps = 1,
      gapSumTotal = 1,
      millNumGaps = 1,
      millGapSumTotal = 1,
      largestGap = 2;



}
