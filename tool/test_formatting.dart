String commas(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

String decimalFormatting(double num) {
  int myInt = num.toInt();

  //get and process the decimal portion
  double remains = num - myInt;
  //remains = double.parse(remains.toStringAsFixed(3));
  String formatted = (remains.toStringAsFixed(3))
      .replaceFirst(RegExp(r'^0'), '');
  String withCommas = commas(myInt);

  return (withCommas + formatted);
}

void main() {
  print(decimalFormatting(123456789.456321));
}
