import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class EvidenceUploader extends StatefulWidget {
  final Function(String fileName, String base64Data) onFileSelected;
  final Function() onFileRemoved;
  final String? currentFileName;

  const EvidenceUploader({
    Key? key,
    required this.onFileSelected,
    required this.onFileRemoved,
    this.currentFileName,
  }) : super(key: key);

  @override
  State<EvidenceUploader> createState() => _EvidenceUploaderState();
}

class _EvidenceUploaderState extends State<EvidenceUploader> {
  String? selectedFileName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedFileName = widget.currentFileName;
  }

  Future<void> _pickFile() async {
    setState(() {
      isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = path.basename(file.path);

        // Read file as bytes and convert to base64
        List<int> fileBytes = await file.readAsBytes();
        String base64Data = base64Encode(fileBytes);

        setState(() {
          selectedFileName = fileName;
        });

        widget.onFileSelected(fileName, base64Data);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar archivo: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeFile() {
    setState(() {
      selectedFileName = null;
    });
    widget.onFileRemoved();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidencia de Entrega',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),

        if (selectedFileName != null)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.description, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedFileName!,
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _removeFile,
                ),
              ],
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.file_upload_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text('No se ha seleccionado ningún archivo'),
              ],
            ),
          ),

        SizedBox(height: 12),

        isLoading
            ? Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                onPressed: _pickFile,
                icon: Icon(Icons.upload_file),
                label: Text(selectedFileName != null
                    ? 'Cambiar archivo'
                    : 'Seleccionar archivo'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
      ],
    );
  }
}