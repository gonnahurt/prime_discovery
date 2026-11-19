class RecoveryData {
  // Recovery / Versioning
  int versionNum;
  int fileCount;

  // Prime Discovery
  int currentPrime;
  int primesDiscoveredCount;
  int currentCandidate;
  int currentCandidateCount;

  // Wheel State
  int wheelPosition;

  // Runtime Tracking
  int cycleStartTime;
  int totalRuntime;
  int activeRunTime;

  // Lifetime Gap Tracking
  int numGaps;
  int gapSumTotal;
  int largestGap;

  RecoveryData({
    required this.versionNum,
    required this.fileCount,

    required this.currentPrime,
    required this.primesDiscoveredCount,
    required this.currentCandidate,
    required this.currentCandidateCount,

    required this.wheelPosition,

    required this.cycleStartTime,
    required this.totalRuntime,
    required this.activeRunTime,

    required this.numGaps,
    required this.gapSumTotal,
    required this.largestGap,
  });

  RecoveryData.initial()
    : versionNum = 1,
      fileCount = 1,

      currentPrime = 2,
      primesDiscoveredCount = 0,
      currentCandidate = 2,
      currentCandidateCount = 1,

      wheelPosition = 0,

      cycleStartTime = DateTime.now().millisecondsSinceEpoch,
      totalRuntime = 0,
      activeRunTime = 0,

      numGaps = 1,
      gapSumTotal = 1,
      largestGap = 2;
}
