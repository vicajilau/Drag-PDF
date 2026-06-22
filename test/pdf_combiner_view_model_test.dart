import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drag_pdf/view_models/pdf_combiner_view_model.dart';

void main() {
  group('PdfCombinerViewModel Tests', () {
    late PdfCombinerViewModel viewModel;

    setUp(() {
      viewModel = PdfCombinerViewModel();
    });

    test('Initial state should be empty', () {
      expect(viewModel.selectedFiles, isEmpty);
      expect(viewModel.outputFiles, isEmpty);
      expect(viewModel.isEmpty(), isTrue);
      expect(viewModel.isNotSinglePdfLoaded(), isTrue);
    });

    test(
      'prepareFiles should add files to selectedFiles and notify listeners',
      () async {
        bool notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        final file1 = PlatformFile(
          path: 'path/to/file1.pdf',
          name: 'file1.pdf',
          size: 100,
        );
        final file2 = PlatformFile(
          path: 'path/to/file2.png',
          name: 'file2.png',
          size: 200,
        );
        final result = FilePickerResult([file1, file2]);

        await viewModel.prepareFiles(result);

        expect(viewModel.selectedFiles.length, 2);
        expect(viewModel.selectedFiles[0], 'path/to/file1.pdf');
        expect(viewModel.selectedFiles[1], 'path/to/file2.png');
        expect(viewModel.isEmpty(), isFalse);
        expect(notified, isTrue);
      },
    );

    test('removeFileAt should remove file and notify listeners', () async {
      final file1 = PlatformFile(
        path: 'path/to/file1.pdf',
        name: 'file1.pdf',
        size: 100,
      );
      final file2 = PlatformFile(
        path: 'path/to/file2.png',
        name: 'file2.png',
        size: 200,
      );
      final result = FilePickerResult([file1, file2]);
      await viewModel.prepareFiles(result);

      bool notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      viewModel.removeFileAt(0);

      expect(viewModel.selectedFiles.length, 1);
      expect(viewModel.selectedFiles[0], 'path/to/file2.png');
      expect(notified, isTrue);
    });

    test(
      'reorderFiles should correctly reorder and notify listeners',
      () async {
        final file1 = PlatformFile(
          path: 'path/to/file1.pdf',
          name: 'file1.pdf',
          size: 100,
        );
        final file2 = PlatformFile(
          path: 'path/to/file2.png',
          name: 'file2.png',
          size: 200,
        );
        final result = FilePickerResult([file1, file2]);
        await viewModel.prepareFiles(result);

        bool notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.reorderFiles(0, 1);

        expect(viewModel.selectedFiles[0], 'path/to/file2.png');
        expect(viewModel.selectedFiles[1], 'path/to/file1.pdf');
        expect(notified, isTrue);
      },
    );

    test(
      'restart should clear selectedFiles and outputFiles and notify listeners',
      () async {
        final file1 = PlatformFile(
          path: 'path/to/file1.pdf',
          name: 'file1.pdf',
          size: 100,
        );
        final result = FilePickerResult([file1]);
        await viewModel.prepareFiles(result);

        bool notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.restart();

        expect(viewModel.selectedFiles, isEmpty);
        expect(viewModel.outputFiles, isEmpty);
        expect(notified, isTrue);
      },
    );

    test('isNotSinglePdfLoaded checks correct conditions', () async {
      // Empty: should return true
      expect(viewModel.isNotSinglePdfLoaded(), isTrue);

      // One non-pdf: should return true
      final fileImage = PlatformFile(
        path: 'path/to/file.png',
        name: 'file.png',
        size: 100,
      );
      await viewModel.prepareFiles(FilePickerResult([fileImage]));
      expect(viewModel.isNotSinglePdfLoaded(), isTrue);

      // One pdf: should return false
      viewModel.restart();
      final filePdf = PlatformFile(
        path: 'path/to/file.pdf',
        name: 'file.pdf',
        size: 100,
      );
      await viewModel.prepareFiles(FilePickerResult([filePdf]));
      expect(viewModel.isNotSinglePdfLoaded(), isFalse);

      // Multiple files including pdf: should return true
      await viewModel.prepareFiles(FilePickerResult([fileImage]));
      expect(viewModel.isNotSinglePdfLoaded(), isTrue);
    });
  });
}
