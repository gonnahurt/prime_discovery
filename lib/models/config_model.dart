class ConfigData {
  //int sessionStartTime;
  String fileNameJson;
  String fileNameLog;
  String primeStorageFolderName = r'PrimeDiscovery';
  String currentDriveLetter = r'P:\';

  ConfigData({
    //required this.sessionStartTime,
    required this.fileNameJson,
    required this.fileNameLog,
    required this.primeStorageFolderName,
    required this.currentDriveLetter,
  });

  ConfigData.initial()
    : //sessionStartTime = DateTime.now().millisecondsSinceEpoch,
      fileNameJson = '00000state.Json',
      fileNameLog = '00000statistics.log',
      primeStorageFolderName = r'PrimeDiscovery',
      currentDriveLetter = r'P:\';
}
