import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:drag_pdf/helper/file_helper.dart';
import 'package:drag_pdf/helper/pdf_helper.dart';
import 'package:drag_pdf/model/file_read.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;

extension FileNameExtension on String {
  /// Elimina la extensión de un nombre de archivo.
  /// Si no hay extensión, devuelve el string original.
  String removeExtension() {
    int lastDotIndex = lastIndexOf('.');

    // Si no se encuentra un punto o está al principio (oculto), devuelve el original
    if (lastDotIndex == -1 || lastDotIndex == 0) {
      return this;
    }

    // Devuelve la parte sin la extensión
    return substring(0, lastDotIndex);
  }
}

class FileManager {
  final List<FileRead> _filesInMemory = [];
  final FileHelper fileHelper;

  FileManager(this.fileHelper);

  bool hasAnyFile() => _filesInMemory.isNotEmpty;

  List<FileRead> getFiles() => _filesInMemory;

  FileRead getFile(int index) => _filesInMemory[index];

  FileRead removeFileFromDisk(int index) {
    fileHelper.removeFile(_filesInMemory[index]);
    return _filesInMemory.removeAt(index);
  }

  void removeFileFromDiskByFile(FileRead file) {
    fileHelper.removeFile(file);
    _filesInMemory.remove(file);
  }

  FileRead removeFileFromList(int index) {
    return _filesInMemory.removeAt(index);
  }

  void reset() => _filesInMemory.clear();

  bool isNameUsedInOtherLoadedFile(String name) =>
      _filesInMemory.indexWhere((element) => element.getName() == name) != -1;

  Future<void> renameFile(FileRead file, String newFileName) async {
    var path = file.getFile().path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    final newFile = await file.getFile().rename(newPath);
    file.setFile(newFile);
    file.setName(newFileName);
  }

  void insertFile(int index, FileRead file) =>
      _filesInMemory.insert(index, file);

  int numberOfFiles() => _filesInMemory.length;

  List<FileRead> addMultipleFiles(List<File> files, String localPath) {
    for (File file in files) {
      final fileRead = FileRead(file, _nameOfNextFile(), null,
          file.lengthSync(), file.path.split('.').last);
      _addSingleFile(fileRead, localPath);
    }
    return _filesInMemory;
  }

  List<FileRead> addMultiplePlatformFiles(
      List<PlatformFile> files, String localPath) {
    for (PlatformFile file in files) {
      final fileRead = FileRead(File(file.path!), _nameOfNextFile(), null,
          file.size, file.extension?.toLowerCase() ?? "");
      _addSingleFile(fileRead, localPath);
    }
    return _filesInMemory;
  }

  Future<List<FileRead>> addMultipleImagesOnDisk(
      List<XFile> files, String localPath, List<String> names) async {
    List<FileRead> finalFiles = [];
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final FileRead fileRead;
      final bytes = await file.readAsBytes();
      Image? image = decodeNamedImage(file.name, bytes);
      final size = await file.length();
      final format = FileHelper.singleton.getFormatOfFile(file.path);
      fileRead = FileRead(File(file.path), names[i], image, size, format);
      final fileSaved = saveFileOnDisk(fileRead, localPath);
      finalFiles.add(fileSaved);
    }
    return finalFiles;
  }

  void _addSingleFile(FileRead file, String localPath) {
    final localFile = saveFileOnDisk(file, localPath);
    _filesInMemory.add(localFile);
  }

  void addFilesInMemory(List<FileRead> files) {
    for (FileRead file in files) {
      _filesInMemory.add(file);
    }
  }

  FileRead saveFileOnDisk(FileRead file, String localPath) =>
      fileHelper.saveFileInLocalPath(file, localPath);

  void rotateImageInMemoryAndFile(FileRead file) {
    fileHelper.rotateImageInFile(file);
  }

  void resizeImageInMemoryAndFile(FileRead file, int width, int height) {
    fileHelper.resizeImageInFile(file, width, height);
  }

  String _nameOfNextFile({int value = 1}) =>
      "File-${_filesInMemory.length + value}";

  List<String> nextNames(int numberOfFiles) {
    List<String> names = [];
    for (int i = 1; i <= numberOfFiles; i++) {
      names.add(_nameOfNextFile(value: i));
    }
    return names;
  }

  Future<FileRead?> scanDocument() async {
    FileRead? fileRead;
    List<String>? paths = await CunningDocumentScanner.getPictures();
    if (paths != null && paths.isNotEmpty) {
      final pdf = pw.Document();
      File file;
      for (String path in paths) {
        final image = pw.MemoryImage(
          File(path).readAsBytesSync(),
        );

        pdf.addPage(pw.Page(build: (pw.Context context) {
          return pw.Image(image);
        }));
      }
      file = File('${fileHelper.localPath}${_nameOfNextFile()}');
      await file.writeAsBytes(await pdf.save());

      final size = await file.length();
      fileRead = FileRead(file, _nameOfNextFile(), null, size, "pdf");
      _addSingleFile(fileRead, fileHelper.localPath);
    }
    return fileRead;
  }

  /// Generates a preview PDF document by converting and merging files in memory.
  ///
  /// - [outputPath]: The directory where the preview PDF will be saved.
  /// - [nameOutputFile]: The desired name of the output PDF file.
  ///
  /// Returns a [FileRead] object representing the merged PDF document.
  Future<FileRead> generatePreviewPdfDocument(
      String outputPath, String nameOutputFile) async {
    List<String> files = _filesInMemory.map((e) => e.getFile().path).toList();
    return await PDFHelper.createPdfDocuments(
        files, outputPath, nameOutputFile);
  }

  @override
  String toString() {
    String text = "-------LOADED FILES -------- \n";
    for (FileRead file in _filesInMemory) {
      text += "$file \n";
    }
    return text;
  }
}
