import 'dart:convert';
import 'dart:io';

const String primeStoragePath = r'D:\PrimeDiscovery';
const String fileName = '00000state.json';

//=======================
//All things JSON related
//=======================
//Verify JSON file exists or create it
Future<bool> jsonSearch(String primeStoragePath) async {
  //String primeStoragePath = r'D:\PrimeDiscovery';
  //String fileName = 'state.json';
  File file = File('$primeStoragePath\\$fileName');

  // Validate file existence
  return !await file.exists();
}

//Create JSON file
Future<void> jsonCreate(String primeStoragePath) async {
  final Map<String, dynamic> recoveryData = {
    "version": 1,
    "fileCount": 1,
    "numPrimes": 1,
    "lastPrime": 2,
    "wheelPosition": 0,
  };

  final File jsonFile = File('$primeStoragePath\\$fileName');

  try {
    // 3. Convert the Dart map into a pretty-printed JSON string
    // (Using JsonEncoder.withIndent('  ') adds clean line breaks and indents)
    final String jsonString = const JsonEncoder.withIndent('  ')
        .convert(recoveryData);

    // 4. Write the string asynchronously to the file
    await jsonFile.writeAsString(jsonString);

    print('Successfully created JSON file at: ${jsonFile.absolute.path}');
  } catch (e) {
    print('An error occurred while creating the file: $e');
  }
}

//Write to JSON file
Future<void> jsonWrite(
  int versionNum,
  int fileCount,
  int numPrimes,
  int lastPrime,
  int primeWalker,
  String primeStoragePath,
) async {
  final Map<String, dynamic> recoveryData = {
    "version": versionNum,
    "fileCount": fileCount,
    "numPrimes": numPrimes,
    "lastPrime": lastPrime,
    "wheelPosition": primeWalker,
  }; //nothing yet

  final File jsonFile = File('$primeStoragePath\\$fileName');

  try {
    // 3. Convert the Dart map into a pretty-printed JSON string
    // (Using JsonEncoder.withIndent('  ') adds clean line breaks and indents)
    final String jsonString = const JsonEncoder.withIndent('  ')
        .convert(recoveryData);

    // 4. Write the string asynchronously to the file
    await jsonFile.writeAsString(jsonString);

    print('Successfully created JSON file at: ${jsonFile.absolute.path}');
  } catch (e) {
    print('An error occurred while creating the file: $e');
  }
}

//Read from JSON file
Future<Map<String, dynamic>> jsonRead(String primeStoragePath) async {
  final String jsonString = await File('$primeStoragePath\\$fileName')
      .readAsString();
  return jsonDecode(jsonString) as Map<String, dynamic>;
}
//=============================
//End - all things JSON related
//=============================
