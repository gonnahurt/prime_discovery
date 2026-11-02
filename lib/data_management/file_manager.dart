//import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
//import '../engine/prime_discovery_engine.dart';
  
  //======================
  //Function Write to File
  //======================
  Future<void> writeFile({
    required int fileCount, 
    required String primeStoragePath,
    required Int64List primeCache}) async {
    // Create a space-separated string from the array
    try {
      DateTime start = DateTime.now();

      //format numeric part of file name to always be 5 digits
      String formatted = fileCount.toString().padLeft(5, '0');
      String fileName = '${formatted}prime.dat';

      File file = File('$primeStoragePath\\$fileName');

      // Write asynchronously to .dat file
      await file.writeAsBytes(primeCache.buffer.asUint8List());

      DateTime end = DateTime.now();

      print('Write time: ${end.difference(start).inMilliseconds} ms');
    } catch (e) {
      print('error writing file: $e');
    }
  } //END Write to File

  //=======================
  //Function Read from file
  //=======================
  Future<List<int>> readBinary({
    required int fileCount,
    required String primeStoragePath,
    Endian endian = Endian.little}) async {
    //format numeric part of file name to always be 5 digits
    String formatted = fileCount.toString().padLeft(5, '0');
    String fileName = '${formatted}prime.dat';
    File file = File('$primeStoragePath\\$fileName');

    // Validate file existence
    if (!await file.exists()) {
      throw FileSystemException("File not found", primeStoragePath);
    }

    // Read all bytes from the file
    final bytes = await file.readAsBytes();

    // Ensure file length is a multiple of 8 bytes (64-bit integers)
    if (bytes.length % 8 != 0) {
      throw FormatException("File length is not a multiple of 8 bytes.");
    }

    // Wrap bytes in ByteData for easy integer extraction
    final byteData = ByteData.sublistView(bytes);

    // Extract integers
    final intCount = bytes.length ~/ 8;
    final List<int> integers = List<int>.generate(
      intCount,
      (i) => byteData.getInt64(i * 8, endian),
    );

    return integers;
  } //END Read from file
