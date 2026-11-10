class ConfigData {

  int sessionStartTime;
  String fileNameJson;
  String fileNameLog;

  ConfigData({
    required this.sessionStartTime,
    required this.fileNameJson,
    required this.fileNameLog,
  });

  ConfigData.initial()
  : sessionStartTime = DateTime.now().millisecondsSinceEpoch,
    fileNameJson = '00000state.Json',
    fileNameLog = '00000statistics.log';
}