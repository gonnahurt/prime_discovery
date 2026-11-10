class SessionData {

  int priorPrime;
  int sessionStartTime;
  int currentGap;

  SessionData({
    required this.priorPrime,
    required this.sessionStartTime,
    required this.currentGap,
  });

  SessionData.initial()
  : priorPrime = 2,
    sessionStartTime = DateTime.now().millisecondsSinceEpoch,
    currentGap = 0;
}