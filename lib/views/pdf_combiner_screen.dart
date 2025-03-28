import 'package:desktop_drop/desktop_drop.dart';
import 'package:drag_pdf/core/extensions/uint8list_extension.dart';
import 'package:drag_pdf/views/widgets/file_type_icon.dart';
import 'package:file_magic_number/file_magic_number.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:pdf_combiner/pdf_combiner_delegate.dart';
import 'package:platform_detail/platform_detail.dart';

import '../core/extensions/dialog_extension.dart';
import '../view_models/pdf_combiner_view_model.dart';
import 'components/loading.dart';

class PdfCombinerScreen extends StatefulWidget {
  const PdfCombinerScreen({super.key});

  @override
  State<PdfCombinerScreen> createState() => _PdfCombinerScreenState();
}

class _PdfCombinerScreenState extends State<PdfCombinerScreen> {
  final PdfCombinerViewModel _viewModel = PdfCombinerViewModel();
  double _progress = 0.0;
  late PdfCombinerDelegate delegate;

  @override
  void initState() {
    super.initState();
    initDelegate();
  }

  void initDelegate() {
    delegate = PdfCombinerDelegate(
      onProgress: (updatedValue) {
        setState(() {
          _progress = updatedValue;
        });
      },
      onError: (error) {
        _showSnackbarSafely(error.toString());
      },
      onSuccess: (paths) {
        setState(() {
          _viewModel.outputFiles = paths;
        });
        _showSnackbarSafely('File/s generated successfully: $paths');
      },
    );
  }

  bool isLoading() => _progress != 0.0 && _progress != 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drag PDF'), actions: menuToolbar()),
      body: SafeArea(
        child:
            isLoading()
                ? const LoadingScreen()
                : DropTarget(
                  onDragDone: (details) {
                    setState(() {
                      _viewModel.addFilesDragAndDrop(details.files);
                    });
                  },
                  child:
                      (_viewModel.isEmpty())
                          ? Center(child: Image.asset('assets/files/home.png'))
                          : Column(
                            spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (_viewModel.outputFiles.isNotEmpty) ...[
                                // HERE IS THE OUTPUT SECTION
                                const SizedBox(),
                                const Text(
                                  'OUTPUT FILES',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                getOutputhFiles(),
                                const Divider(),
                              ],
                              // HERE IS THE INPUT SECTION
                              const SizedBox(),
                              const Text(
                                'INPUT FILES',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              getInputFiles(),
                              // Buttons Section
                              getBottombarOptions(),
                              const SizedBox(height: 20),
                            ],
                          ),
                ),
      ),
    );
  }

  /// Calculates the flex size for the input files.
  ///
  /// This function determines the appropriate size or layout parameters for the input files
  /// based on the available space, ensuring they are displayed correctly in a flexible layout.
  ///
  /// @return Integer value representing the flex size for the input files.
  int calculateFlexInputFiles() =>
      _viewModel.outputFiles.isEmpty ||
              _viewModel.selectedFiles.length <= _viewModel.outputFiles.length
          ? 1
          : 2;

  /// Calculates the flex size for the output files.
  ///
  /// This function determines the appropriate size or layout parameters for the output files
  /// based on the available space, ensuring they are displayed correctly in a flexible layout.
  ///
  /// @return Integer value representing the flex size for the output files.
  int calculateFlexOutputFiles() =>
      _viewModel.outputFiles.length <= _viewModel.selectedFiles.length ? 1 : 2;

  /// Creates a widget for the top-right menu.
  ///
  /// This function returns a widget that prepares and displays
  /// the options available in the top-right menu of the application.
  ///
  /// @return A `Widget` representing the configured top-right menu.
  List<Widget> menuToolbar() {
    return [
      IconButton(
        onPressed: _restart,
        icon: const Icon(Icons.restart_alt),
        tooltip: "Restart app",
      ),
      IconButton(
        onPressed: () {
          if (PlatformDetail.isMobile) {
            context.showFilePickerDialog((FilePickerResult? result) {
              if (result != null) {
                _pickFiles(result: result);
              }
            });
          } else {
            _pickFiles();
          }
        },
        icon: const Icon(Icons.add),
        tooltip: "Add new files",
      ),
    ];
  }

  /// Generates the output file resulting from the combination of the input files.
  ///
  /// This function takes the selected input files, processes their content,
  /// and creates a new file that merges or transforms them according to the application's logic.
  ///
  /// @return A widget with the combination of input files into one output file
  Widget getOutputhFiles() {
    return Expanded(
      flex: calculateFlexOutputFiles(),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _viewModel.outputFiles.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: FileTypeIcon(filePath: _viewModel.outputFiles[index]),
              title: Text(
                p.basename(_viewModel.outputFiles[index]),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _openOutputFile(index),
              subtitle: FutureBuilder(
                future: FileMagicNumber.getBytesFromPathOrBlob(
                  _viewModel.outputFiles[index],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading size...");
                  } else if (snapshot.hasError) {
                    return const Icon(Icons.error);
                  } else {
                    return Text(snapshot.data?.size() ?? "Unknown Size");
                  }
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyOutputToClipboard(index),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Prepares the files selected by the user using File Picker.
  ///
  /// This function processes the list of files obtained from the file picker,
  /// validates their existence, and converts them into a suitable format for further use.
  ///
  /// @return A widget with a list of the selected files
  Widget getInputFiles() {
    return Expanded(
      flex: calculateFlexInputFiles(),
      child: ReorderableListView.builder(
        itemCount: _viewModel.selectedFiles.length,
        onReorder: _onReorderFiles,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_viewModel.selectedFiles[index]),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              final path = p.basename(_viewModel.selectedFiles[index]);
              setState(() {
                _viewModel.removeFileAt(index);
              });
              _showSnackbarSafely('File $path removed.');
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: FileTypeIcon(
                  filePath: _viewModel.selectedFiles[index],
                ),
                title: Text(
                  p.basename(_viewModel.selectedFiles[index]),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async => await _openInputFile(index),
                subtitle: FutureBuilder(
                  future: FileMagicNumber.getBytesFromPathOrBlob(
                    _viewModel.selectedFiles[index],
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading size...");
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    } else {
                      return Text(snapshot.data?.size() ?? "Unknown Size");
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Creates a bottom bar with buttons that perform actions on the input files.
  ///
  /// This function returns a widget representing a bottom bar,
  /// where each button triggers a specific action related to the input files,
  /// such as processing, validating, or modifying them.
  ///
  /// @return A `Widget` representing the bottom bar with action buttons for input files.
  Widget getBottombarOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          const SizedBox(),
          ElevatedButton(
            onPressed:
                _viewModel.selectedFiles.isNotEmpty ? _createPdfFromMix : null,
            child: const Text('Create PDF'),
          ),
          ElevatedButton(
            onPressed:
                _viewModel.selectedFiles.isNotEmpty ? _combinePdfs : null,
            child: const Text('Combine PDFs'),
          ),
          ElevatedButton(
            onPressed:
                _viewModel.selectedFiles.isNotEmpty
                    ? _createPdfFromImages
                    : null,
            child: const Text('PDF from images'),
          ),
          ElevatedButton(
            onPressed:
                _viewModel.selectedFiles.isNotEmpty
                    ? _createImagesFromPDF
                    : null,
            child: const Text('Images from PDF'),
          ),
          const SizedBox(),
        ],
      ),
    );
  }

  /// Allows the user to select a file or scan an image using the camera (on mobile devices).
  ///
  /// This function opens a file picker dialog with 2 options if the device is mobile,
  /// provides the option to scan an image using the camera or another to pick a file.
  ///
  /// @return Void
  Future<void> _pickFiles({FilePickerResult? result}) async {
    await _viewModel.pickFiles(result);
    setState(() {});
  }

  /// Resets the input and output files.
  ///
  /// This function clears any previously selected input files and output files,
  /// returning the application to its initial state, ready for new file selection and processing.
  ///
  /// @return Void
  void _restart() {
    _viewModel.restart();
    setState(() {
      _progress = 0.0;
    });
    _showSnackbarSafely('App restarted!');
  }

  /// Combines multiple PDFs into a single output file.
  ///
  /// This function takes the selected input PDF files, merges them into a single PDF,
  /// and saves the combined result to the specified output file location.
  ///
  /// @return Void
  Future<void> _combinePdfs() async {
    await _viewModel.combinePdfs(delegate);
  }
  /// Creates a PDF from a mixed set of input files.
  ///
  /// This function processes a combination of various input file types (e.g., text, images, or PDFs)
  /// and generates a new PDF document containing the combined content.
  ///
  /// @return Void
  Future<void> _createPdfFromMix() async {
    await _viewModel.createPDFFromDocuments(delegate);
  }
  /// Creates a PDF from a set of image files.
  ///
  /// This function takes a list of image files, converts them into PDF pages,
  /// and generates a new PDF document containing all the images in sequence.
  ///
  /// @return Void
  Future<void> _createPdfFromImages() async {
    await _viewModel.createPDFFromImages(delegate);
  }
  /// Extracts images from a PDF and saves them as separate image files.
  ///
  /// This function processes a PDF file, extracts each page as an image,
  /// and saves the images to the specified output location for further use.
  ///
  /// @return Void
  Future<void> _createImagesFromPDF() async {
    await _viewModel.createImagesFromPDF(delegate);
  }
  /// Copies the output data to the clipboard.
  ///
  /// This function takes the generated output (e.g., file paths, text, or results)
  /// and copies it to the clipboard, making it available for pasting into other applications.
  ///
  /// @return Void
  Future<void> _copyOutputToClipboard(int index) async {
    await _viewModel.copyOutputToClipboard(index);
    _showSnackbarSafely('Output path copied to clipboard');
  }
  /// Opens the output file for viewing or further processing.
  ///
  /// This function opens the generated output file (e.g., a PDF, image, or text file)
  /// using the appropriate application on the device, allowing the user to view or interact with it.
  ///
  /// @return Void
  Future<void> _openOutputFile(int index) async {
    if (index < _viewModel.outputFiles.length) {
      final result = await OpenFile.open(_viewModel.outputFiles[index]);
      if (result.type != ResultType.done) {
        _showSnackbarSafely('Failed to open file. Error: ${result.message}');
      }
    }
  }
  /// Opens the selected input file for viewing or editing.
  ///
  /// This function opens the specified input file (e.g., a document, image, or text file)
  /// using the appropriate application on the device, allowing the user to view or make changes to it.
  ///
  /// @return Void
  Future<void> _openInputFile(int index) async {
    if (index < _viewModel.selectedFiles.length) {
      final result = await OpenFile.open(_viewModel.selectedFiles[index]);
      if (result.type != ResultType.done) {
        _showSnackbarSafely('Failed to open file. Error: ${result.message}');
      }
    }
  }

  /// Handles the reordering of files in the list.
  ///
  /// This function allows the user to reorder the selected files, updating their sequence
  /// as per the new order. The file list is then refreshed to reflect the changes.
  ///
  /// @return Void
  void _onReorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final file = _viewModel.selectedFiles.removeAt(oldIndex);
      _viewModel.selectedFiles.insert(newIndex, file);
    });
  }
  /// Displays a snackbar message safely on the screen.
  ///
  /// This function shows a snackbar with a given message, ensuring that it is displayed correctly
  /// even if the app is in a transient state, such as during navigation or while other UI elements are active.
  ///
  /// @return Void
  void _showSnackbarSafely(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
