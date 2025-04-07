import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

class FileUtils {
  static Future<bool> saveBase64File(BuildContext context, String base64String, String fileName) async {
    try {
      // Handle empty or null filename
      if (fileName.isEmpty) {
        fileName = 'evidence_file';
      }

      // Extract original extension or detect from data
      String extension = path.extension(fileName).toLowerCase();

      // Clean up the base64 string (remove data URL prefix if present)
      String cleanBase64 = base64String;
      if (base64String.contains(';base64,')) {
        cleanBase64 = base64String.split(';base64,').last;
      }

      // Decode base64
      Uint8List bytes;
      try {
        bytes = base64.decode(cleanBase64);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error decodificando el archivo: formato base64 inválido')),
        );
        return false;
      }

      // If no extension, detect from file content
      if (extension.isEmpty) {
        extension = _detectFileTypeFromBytes(bytes);
        fileName = '$fileName$extension';
      }

      // Get temp directory that's more accessible for sharing
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${path.basename(fileName)}';

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Log for debugging
      print('File saved to: $filePath');

      // Show saving message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abriendo archivo: ${path.basename(fileName)}')),
      );

      // Open the file using open_file
      try {
        final result = await OpenFile.open(filePath);
        print('OpenFile result: ${result.message}');
        return true;
      } catch (e) {
        print('Exception when opening file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el archivo: $e')),
        );
        return false;
      }

    } catch (e) {
      print('Exception in saveBase64File: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el archivo: $e')),
      );
      return false;
    }
  }

  // Detect file type from bytes (unchanged)
  static String _detectFileTypeFromBytes(Uint8List bytes) {
    if (bytes.length < 8) return '.bin';

    // Check file signatures
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return '.jpg';
    }

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return '.png';
    }

    // PDF: 25 50 44 46
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
      return '.pdf';
    }

    // MP4/MPEG-4: various signatures
    if (bytes.length >= 8 &&
        ((bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70) ||
         (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00))) {
      return '.mp4';
    }

    // DOCX/XLSX/PPTX (ZIP-based formats): 50 4B 03 04
    if (bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04) {
      return '.docx';
    }

    return '.bin';
  }
}