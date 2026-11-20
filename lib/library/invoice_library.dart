import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:inpdf/invoices/invoice_catalog.dart';
import 'package:inpdf/invoices/invoice_data.dart';
import 'package:inpdf/library/saved_invoice.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceLibrary extends ChangeNotifier {
  InvoiceLibrary._();

  static final InvoiceLibrary instance = InvoiceLibrary._();

  static const _indexFileName = 'index.json';

  final List<SavedInvoice> _items = [];
  bool _loaded = false;

  List<SavedInvoice> get items => List.unmodifiable(_items);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (kIsWeb) {
      _loaded = true;
      return;
    }

    try {
      final file = await _indexFile();
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        final rows = decoded is List ? decoded : const [];
        _items
          ..clear()
          ..addAll([
            for (final row in rows)
              SavedInvoice.fromJson(Map<String, dynamic>.from(row as Map)),
          ]);
      }
    } catch (_) {
      _items.clear();
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<SavedInvoice> save({
    required InvoiceFormat format,
    required InvoiceData invoice,
    required Uint8List bytes,
  }) async {
    await ensureLoaded();

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final fileName =
        '${safeFileName(format.id)}-${safeFileName(invoice.invoiceNumber)}.pdf';
    final record = SavedInvoice(
      id: id,
      formatId: format.id,
      fileName: fileName,
      savedAt: DateTime.now(),
      invoice: invoice,
    );

    if (!kIsWeb) {
      final pdfFile = File('${(await _libraryDir()).path}/$id.pdf');
      await pdfFile.writeAsBytes(bytes, flush: true);
      _items.insert(0, record);
      await _writeIndex();
    } else {
      _items.insert(0, record);
    }

    try {
      await saveToPhoneFiles(bytes: bytes, fileName: fileName);
    } catch (_) {
      // Keep the in-app copy even if the device Files/Downloads save fails.
    }
    notifyListeners();
    return record;
  }

  Future<void> saveToPhoneFiles({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final name = fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  Future<Uint8List> readPdf(SavedInvoice record) async {
    if (kIsWeb) {
      throw StateError('Saved files are not stored on web.');
    }
    final file = File('${(await _libraryDir()).path}/${record.id}.pdf');
    return file.readAsBytes();
  }

  Future<void> delete(SavedInvoice record) async {
    await ensureLoaded();
    _items.removeWhere((item) => item.id == record.id);
    if (!kIsWeb) {
      final file = File('${(await _libraryDir()).path}/${record.id}.pdf');
      if (await file.exists()) {
        await file.delete();
      }
      await _writeIndex();
    }
    notifyListeners();
  }

  Future<Directory> _libraryDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/library');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _indexFile() async {
    return File('${(await _libraryDir()).path}/$_indexFileName');
  }

  Future<void> _writeIndex() async {
    final file = await _indexFile();
    await file.writeAsString(
      jsonEncode(_items.map((item) => item.toJson()).toList()),
      flush: true,
    );
  }
}
