import 'package:inpdf/invoices/invoice_catalog.dart';
import 'package:inpdf/invoices/invoice_data.dart';

class SavedInvoice {
  const SavedInvoice({
    required this.id,
    required this.formatId,
    required this.fileName,
    required this.savedAt,
    required this.invoice,
  });

  final String id;
  final String formatId;
  final String fileName;
  final DateTime savedAt;
  final InvoiceData invoice;

  InvoiceFormat get format => invoiceFormatById(formatId);

  String get title {
    final number = invoice.invoiceNumber.trim();
    return number.isEmpty ? format.name : number;
  }

  String get caption {
    return '${format.name}  ·  ${_shortDate(savedAt)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'formatId': formatId,
        'fileName': fileName,
        'savedAt': savedAt.toIso8601String(),
        'invoice': invoice.toJson(),
      };

  factory SavedInvoice.fromJson(Map<String, dynamic> json) {
    return SavedInvoice(
      id: json['id'] as String,
      formatId: json['formatId'] as String? ?? invoiceFormats.first.id,
      fileName: json['fileName'] as String? ?? 'invoice.pdf',
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.now(),
      invoice: InvoiceData.fromJson(
        Map<String, dynamic>.from(json['invoice'] as Map? ?? const {}),
      ),
    );
  }
}

String _shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = date.day.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}';
}

String safeFileName(String value) {
  final cleaned = value.trim().replaceAll(RegExp(r'[^\w\-.]+'), '_');
  return cleaned.isEmpty ? 'invoice' : cleaned;
}
