String commas(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

String decimalFormatting(double num) {
  int myInt = num.toInt();

  //get and process the decimal portion
  double remains = num % myInt;
  //remains = double.parse(remains.toStringAsFixed(3));
  String formatted = (remains.toStringAsFixed(3))
      .replaceFirst(RegExp(r'^0'), '');
  String withCommas = commas(myInt);

  return (withCommas + formatted);
}

String runtimeFormatting(int ms, String printHeader) {
  int years = (ms / 31795200000).floor();
  int months = ((ms % 31795200000) / 2419200000).floor();
  int weeks = ((ms % 2419200000) / 604800000).floor();
  int days = ((ms % 604800000) / 86400000).floor();
  int hours = ((ms % 86400000) / 3600000).floor();
  int mins = ((ms % 3600000) / 60000).floor();
  int secs = ((ms % 60000) / 1000).floor();
  int milli = (ms % 1000).floor();
  //int micro = ((ms % 1000) * 1000);

  return ('''$printHeader 
          $years years : $months months : $weeks weeks : $days days 
          $hours hours : $mins minutes : $secs seconds ''');
}

//All timing for minute statistics would be under 60 seconds
String minuteFormatting(int ms, String printHeader) {
  // int years = (ms / 31795200000).floor();
  // int months = ((ms % 31795200000) / 2419200000).floor();
  // int weeks = ((ms % 2419200000) / 604800000).floor();
  // int days = ((ms % 604800000) / 86400000).floor();
  // int hours = ((ms % 86400000) / 3600000).floor();
  // int mins = ((ms % 3600000) / 60000).floor();
  int secs = ((ms % 60000) / 1000).floor();
  int ms1 = (ms % 1000);

  return ('''$printHeader $secs seconds : $ms1 milliseconds''');
}

//All timing for million statistics would be under 1 day?
String millionFormatting(int ms, String printHeader) {
  int years = (ms / 31795200000).floor();
  int months = ((ms % 31795200000) / 2419200000).floor();
  int weeks = ((ms % 2419200000) / 604800000).floor();
  int days = ((ms % 604800000) / 86400000).floor();
  int hours = ((ms % 86400000) / 3600000).floor();
  int mins = ((ms % 3600000) / 60000).floor();
  int secs = ((ms % 60000) / 1000).floor();
  int ms1 = (ms % 1000);

  return ('''$printHeader $secs seconds : $ms1 milliseconds''');
}
