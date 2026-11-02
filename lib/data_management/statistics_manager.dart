//Stats I want to see:
//Percent of numbers reviewed - wheel effectiveness : I want to see the difference our wheels make
//DONE: Percent of primes discovered - prime density : want to see how drastically this drops over time
//NO FUNTION REQUIRED: Last prime discovered count = last prime discovered ('the 500th prime is: 3571)
//DONE: Average gap between primes overtime (starting from 2 - wherever we are)
//DONE: Average gap between primes last 1million (starting from 1 - 1million, 1,000,001 - 2million, 2,000,001 - 3million  etc.)
//DONE: largest prime gap determined
//DONE: Search Rate: candidatesReviewed/sec * primesDiscovered/sec
//Next File Count down - no biggie early on but when into bigInt territory could be interesting

/*
Prime Discovery

Wheel: wheel_19

Largest Number Tested:
12,456,882,731

Prime Count:
523,441,892

Last Prime:
12,456,882,719

Prime Density:
4.20%

Wheel Skip:
82.90%

Candidates/sec:
2,451,121
*/

//========================================
//Calls all calculations and generates the
//line to be printed or appended to log
//========================================
String runStats({
  required int numPrimes,
  required int lastPrime,
  required int numGaps,
  required int gapSumTotal,
  required int millNumGaps,
  required int millGapSumTotal,
  required int currentPrime,
  required int largestGap,
  required int candidatesCount,
  required int prevCandidateCount,
  required int prevDiscovered,
  required int primesDiscovered,
}) {
  String lastSec = inTheLastSecond(
    //this print is created in the function
    candidatesCount: candidatesCount,
    prevCandidateCount: prevCandidateCount,
    prevDiscovered: prevDiscovered,
    primesDiscovered: primesDiscovered,
  );

  //$pVarDensity% of all numbers up to $lastPrime are prime numbers
  String pVarDensity = pDensity(numPrimes: numPrimes, lastPrime: lastPrime);
  String pvdOut =
      ('$pVarDensity: % of all numbers up to $lastPrime are prime numbers ');

  //The average gap since prime 2 is: $lifetimeGap
  String lifetimeGap = gapAverageLifetime(
    numGaps: numGaps,
    gapSumTotal: gapSumTotal,
  );
  String lgOut = ('$lifetimeGap: Average gap since prime 2');

  //$millionGap : Average gap size between current prime - 1000000 thru current prime
  String millionGap = gapAverageMillionPrimeLifespan(
    millNumGaps: millNumGaps,
    millGapSumTotal: millGapSumTotal,
  );
  String mgOut =
      ('$millionGap : Average gap size between current prime - 1000000 thru current prime');

  //$largestPrimeGap : Largest Gap between determined primes
  int largestPrimeGap = largestGapBetweenPrimes(
    lastPrime: lastPrime,
    currentPrime: currentPrime,
    largestGap: largestGap,
  );
  String lpgOut = ('$largestPrimeGap : Largest Gap between determined primes');

  String formattedStats = '''
      $lastSec
      $pvdOut
      $lgOut
      $mgOut
      $lpgOut
      ''';

  return (formattedStats);
}
//============
//END: runStats
//============

//===============================================================
//Prime density : Percentage of primed determined in Last integer
//can be run when ever we choose to display
//===============================================================
String pDensity({required int numPrimes, required int lastPrime}) {
  double totPrimes = numPrimes.toDouble();
  double finalPrime = lastPrime.toDouble();
  double pDensityPercent = ((totPrimes / finalPrime * 100));
  return (formatToThreePlaces(pDensityPercent));
}
//==================
//END: Prime density
//==================

//============================================================================
//Lifetime average of gap size
//Average gap between primes over lifetime (starting from 2 - wherever we are
//============================================================================
String gapAverageLifetime({required int numGaps, required int gapSumTotal}) {
  double gapCount = numGaps.toDouble();
  double gapSum = gapSumTotal.toDouble();
  double lifetimeGap = gapSum / gapCount;
  return (formatToThreePlaces(lifetimeGap));
}
//=================================
//END: Lifetime average of gap size
//=================================

//=====================================
//Average gap size in the last 1million
//=====================================
String gapAverageMillionPrimeLifespan({
  required int millNumGaps,
  required int millGapSumTotal,
}) {
  double gapCount = millNumGaps.toDouble();
  double gapSum = millGapSumTotal.toDouble();
  double milLifespanGap = gapSum / gapCount;
  return (formatToThreePlaces(milLifespanGap));
}
//==========================================
//END: Average gap size in the last 1million
//==========================================

//===========================================
//Largest located gap between primes
//Must be run each time a prime is discovered
//===========================================
int largestGapBetweenPrimes({
  required int lastPrime,
  required int currentPrime,
  required int largestGap,
}) {
  int currentGap = currentPrime - lastPrime;
  //int largestGap;
  if (currentGap > largestGap) {
    largestGap = currentGap;
  }
  return (largestGap);
}
//=======================================
//END: Largest located gap between primes
//=======================================

//=====================================================
//Candidates tested && Primes determined in last second
//=====================================================
String inTheLastSecond({
  required int candidatesCount,
  required int prevCandidateCount,
  required int prevDiscovered,
  required int primesDiscovered,
}) {
  int candidatesTestedLastSec = candidatesCount - prevCandidateCount;
  int primedDiscoveredLastSec = primesDiscovered - prevDiscovered;
  String inLastSecond =
      ('In the last second: $candidatesTestedLastSec were tested & $primedDiscoveredLastSec were determined');
  return (inLastSecond);
}
//==========================================================
//END: Candidates tested && Primes determined in last second
//==========================================================

//========================================
//format double to 3 spaces for continuity
//========================================
String formatToThreePlaces(double value) {
  return value.toStringAsFixed(3);
}
//=============================================
//END: format double to 3 spaces for continuity
//=============================================

//Write to log
void writeToLog({required String formattedStats}) {

}
//END: Write to log