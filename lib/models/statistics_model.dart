//This will be the display data on the front end
class PerTenSecondsStatisticsModel {
  // Candidate Count
  int candidateCount10Sec;

  //wheel efficiency
  int startingInteger10Sec;
  int endingInteger10Sec;

  // Prime count
  //int time10SecStart;
  int current10SecondPrimeCount;

  int time10SecStart;
  int time10SecEnd;

  PerTenSecondsStatisticsModel({
    required this.candidateCount10Sec,
    required this.startingInteger10Sec,
    required this.endingInteger10Sec,
    required this.current10SecondPrimeCount,
    required this.time10SecStart,
    required this.time10SecEnd,
  });

  PerTenSecondsStatisticsModel.initial()
    : candidateCount10Sec = 1,
      startingInteger10Sec = 2,
      endingInteger10Sec = 2,
      current10SecondPrimeCount = 1,
      time10SecEnd = DateTime.now().millisecondsSinceEpoch,
      time10SecStart = DateTime.now().millisecondsSinceEpoch;
}

class Per1MinuteStatisticsModel {
  //track when 1 Min has passed
  int prior1MinTime;
  int current1MinTime;

  // Candidate tracking
  int candidateCount1Min;

  // Prime count tracking - primes determined in the last minute
  int primeCount1Min;

  //Track gap times - time it took to determine next prime
  int timeGapStart1Min;
  int timeGapEnd1Min;

  int priorMinuteInteger;
  int currentMinuteInteger;

  //time between prime determinations
  int gapTimeBetweenPrimesDetermined1MinLongest;
  int gapTimeBetweenPrimesDetermined1MinShortest;
  int gapTimeBetweenPrimesDetermined1MinAverage;
  int gapTimeSum1Min;

  Per1MinuteStatisticsModel({
    required this.prior1MinTime,
    required this.current1MinTime,
    required this.candidateCount1Min,
    required this.primeCount1Min,
    required this.timeGapStart1Min,
    required this.timeGapEnd1Min,
    required this.priorMinuteInteger,
    required this.currentMinuteInteger,
    required this.gapTimeBetweenPrimesDetermined1MinLongest,
    required this.gapTimeBetweenPrimesDetermined1MinShortest,
    required this.gapTimeBetweenPrimesDetermined1MinAverage,
    required this.gapTimeSum1Min,
    //required this.gapCount,
    //required this.timePriorMinuteStart,
  });

  Per1MinuteStatisticsModel.initial()
    : prior1MinTime = DateTime.now().millisecondsSinceEpoch,
      current1MinTime = DateTime.now().millisecondsSinceEpoch,
      candidateCount1Min = 1,
      primeCount1Min = 1,
      timeGapStart1Min = DateTime.now().millisecondsSinceEpoch,
      timeGapEnd1Min = DateTime.now().millisecondsSinceEpoch,
      priorMinuteInteger = 1,
      currentMinuteInteger = 1,
      gapTimeBetweenPrimesDetermined1MinLongest = 0,
      gapTimeBetweenPrimesDetermined1MinShortest = 5000000000000000,
      gapTimeBetweenPrimesDetermined1MinAverage = 0,
      gapTimeSum1Min = 0;
}

class PerMillionStatisticsModel {
  int prior1MllionTime;
  int current1MillionTime;

  // Million Statistics Tracking
  int millNumGaps;
  int millGapSumTotal;

  int currentMillionCandidateCount;

  int gapTimeBetweenPrimesDetermined1MillLongest;
  int gapTimeBetweenPrimesDetermined1MillShortest;
  int gapTimeBetweenPrimesDetermined1MillAverage;
  int gapTimeSum1Mill;

  PerMillionStatisticsModel({
    required this.prior1MllionTime,
    required this.current1MillionTime,
    required this.millNumGaps,
    required this.millGapSumTotal,
    required this.currentMillionCandidateCount,
    required this.gapTimeBetweenPrimesDetermined1MillLongest,
    required this.gapTimeBetweenPrimesDetermined1MillShortest,
    required this.gapTimeBetweenPrimesDetermined1MillAverage,
    required this.gapTimeSum1Mill,
  });

  PerMillionStatisticsModel.initial()
    : prior1MllionTime = 0,
      current1MillionTime = 0,
      millNumGaps = 1,
      millGapSumTotal = 1,

      currentMillionCandidateCount = 0,

      gapTimeBetweenPrimesDetermined1MillLongest = 0,
      gapTimeBetweenPrimesDetermined1MillShortest = 0,
      gapTimeBetweenPrimesDetermined1MillAverage = 0,
      gapTimeSum1Mill = 0;
}

class CycleStatisticsModel {
  int priorCycleTime;
  int currentCycleTime;
  double primeDensity;
  double averageLifetimeGap;
  double averageMillionGap;

  int timeBetweenPrimesDiscoveredLongest;
  int timeBetweenPrimesDiscoveredShortest;
  int timeBetweenPrimesDiscoveredAverage;

  CycleStatisticsModel({
    required this.priorCycleTime,
    required this.currentCycleTime,
    required this.primeDensity,
    required this.averageLifetimeGap,
    required this.averageMillionGap,

    required this.timeBetweenPrimesDiscoveredLongest,
    required this.timeBetweenPrimesDiscoveredShortest,
    required this.timeBetweenPrimesDiscoveredAverage,
  });

  CycleStatisticsModel.initial()
    : priorCycleTime = 0,
      currentCycleTime = 0,

      primeDensity = 0.0,
      averageLifetimeGap = 0.0,
      averageMillionGap = 0.0,

      timeBetweenPrimesDiscoveredLongest = 0,
      timeBetweenPrimesDiscoveredShortest = 0,
      timeBetweenPrimesDiscoveredAverage = 0;
}

class SessionStatisticsModel {
  int priorSessionTime;
  int currentSessionTime;
  double primeDensity;
  double averageLifetimeGap;
  double averageMillionGap;
  double timeBetweenPrimesDetermined;

  int timeBetweenPrimesDiscoveredSessionLongest;
  int timeBetweenPrimesDiscoveredSessionShortest;
  int timeBetweenPrimesDiscoveredSessionAverage;

  SessionStatisticsModel({
    required this.priorSessionTime,
    required this.currentSessionTime,
    required this.primeDensity,
    required this.averageLifetimeGap,
    required this.averageMillionGap,
    required this.timeBetweenPrimesDetermined,

    required this.timeBetweenPrimesDiscoveredSessionLongest,
    required this.timeBetweenPrimesDiscoveredSessionShortest,
    required this.timeBetweenPrimesDiscoveredSessionAverage,
  });

  SessionStatisticsModel.initial()
    : priorSessionTime = 0,
      currentSessionTime = 0,
      primeDensity = 0.0,
      averageLifetimeGap = 0.0,
      averageMillionGap = 0.0,
      timeBetweenPrimesDetermined = 0.0,

      timeBetweenPrimesDiscoveredSessionLongest = 0,
      timeBetweenPrimesDiscoveredSessionShortest = 0,
      timeBetweenPrimesDiscoveredSessionAverage = 0;
}
