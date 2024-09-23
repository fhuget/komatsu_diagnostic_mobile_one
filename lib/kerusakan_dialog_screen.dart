import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class KerusakanDialogScreen extends StatefulWidget {
  final DocumentSnapshot? document;

  const KerusakanDialogScreen({super.key, this.document});

  @override
  State<KerusakanDialogScreen> createState() => _KerusakanDialogScreenState();
}

class _KerusakanDialogScreenState extends State<KerusakanDialogScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeController;
  late TextEditingController _namaController;
  List<File>? _imageFiles;
  List<Uint8List>? _webImageFiles;
  List<String>? _fileNames;
  List<String>? _imageUrls;

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(
        text: widget.document != null ? widget.document!['KodeError'] : '');
    _namaController = TextEditingController(
        text: widget.document != null ? widget.document!['NamaError'] : '');
    if (widget.document != null) {
      _imageUrls = List<String>.from(widget.document!['imageUrls'] ?? []);
    } else {
      _imageUrls = [];
    }
    _imageFiles = [];
    _webImageFiles = [];
    _fileNames = [];
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImageFiles = result.files.map((file) => file.bytes!).toList();
          _fileNames = result.files.map((file) => file.name).toList();
        });
      } else {
        setState(() {
          _imageFiles = result.files.map((file) => File(file.path!)).toList();
        });
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> urls = [];
    if (kIsWeb) {
      if (_webImageFiles != null && _fileNames != null) {
        for (int i = 0; i < _webImageFiles!.length; i++) {
          final ref = FirebaseStorage.instance.ref().child(
              'images/${DateTime.now().toIso8601String()}_${_fileNames![i]}');
          final uploadTask = ref.putData(_webImageFiles![i]);
          final snapshot = await uploadTask;
          urls.add(await snapshot.ref.getDownloadURL());
        }
      }
    } else {
      if (_imageFiles != null) {
        for (File file in _imageFiles!) {
          final ref = FirebaseStorage.instance.ref().child(
              'images/${DateTime.now().toIso8601String()}_${file.path.split('/').last}');
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          urls.add(await snapshot.ref.getDownloadURL());
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.document == null ? 'Tambah Kerusakan' : 'Edit Kerusakan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _kodeController,
              decoration: const InputDecoration(labelText: 'Kode Kerusakan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode tidak boleh kosong';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Kerusakan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Pilih Gambar'),
            ),
            _imageUrls != null && _imageUrls!.isNotEmpty
                ? Column(
                    children: _imageUrls!.map((url) => Text('Gambar terpilih: $url')).toList(),
                  )
                : const Text('Tidak ada gambar terpilih'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final kodeError = _kodeController.text;
              final namaError = _namaController.text;

              if (_imageFiles != null || _webImageFiles != null) {
                final urls = await _uploadImages();
                _imageUrls!.addAll(urls);
              }

              if (widget.document == null) {
                await FirebaseFirestore.instance.collection('CRUDItems').add({
                  'KodeError': kodeError,
                  'NamaError': namaError,
                  'imageUrls': _imageUrls,
                });
              } else {
                await FirebaseFirestore.instance.collection('CRUDItems').doc(widget.document!.id).update({
                  'KodeError': kodeError,
                  'NamaError': namaError,
                  'imageUrls': _imageUrls,
                });
              }

              Navigator.of(context).pop();
            }
          },
          child: Text(widget.document == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
  }
}
