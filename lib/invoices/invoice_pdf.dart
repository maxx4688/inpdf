import 'dart:typed_data';

import 'package:inpdf/invoices/invoice_catalog.dart';
import 'package:inpdf/invoices/invoice_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> buildInvoicePdf({
  required InvoiceFormat format,
  required InvoiceData invoice,
  required PdfPageFormat pageFormat,
}) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      margin: format.layout == InvoiceLayout.sidebar ||
              format.layout == InvoiceLayout.corporate
          ? pw.EdgeInsets.zero
          : const pw.EdgeInsets.all(32),
      build: (context) => _buildLayout(format.layout, invoice),
    ),
  );
  return pdf.save();
}

pw.Widget _buildLayout(InvoiceLayout layout, InvoiceData invoice) {
  switch (layout) {
    case InvoiceLayout.classic:
      return _classic(invoice);
    case InvoiceLayout.minimal:
      return _minimal(invoice);
    case InvoiceLayout.corporate:
      return _corporate(invoice);
    case InvoiceLayout.aqua:
      return _aqua(invoice);
    case InvoiceLayout.crimson:
      return _crimson(invoice);
    case InvoiceLayout.boxed:
      return _boxed(invoice);
    case InvoiceLayout.sidebar:
      return _sidebar(invoice);
    case InvoiceLayout.elegant:
      return _elegant(invoice);
    case InvoiceLayout.creative:
      return _creative(invoice);
    case InvoiceLayout.receipt:
      return _receipt(invoice);
  }
}

pw.Widget _classic(InvoiceData invoice) {
  const navy = PdfColor.fromInt(0xFF1B365D);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  invoice.companyName.toUpperCase(),
                  style: pw.TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.companyTagline,
                  style: const pw.TextStyle(
                    color: PdfColors.blueGrey600,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 8),
                _mutedBlock(
                  '${invoice.companyAddress}\n${invoice.companyEmail}\n${invoice.companyPhone}',
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: navy,
            child: pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 22),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _billTo(invoice)),
          pw.SizedBox(width: 24),
          pw.Container(
            width: 180,
            child: pw.Column(
              children: [
                _kv('Invoice', invoice.invoiceNumber, navy),
                _kv('Issued', invoice.issueDate, navy),
                _kv('Due', invoice.dueDate, navy),
                _kv('PO', invoice.poNumber, navy),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 22),
      _table(
        invoice,
        headerColor: navy,
        headerText: PdfColors.white,
        rowAlt: const PdfColor.fromInt(0xFFEEF2F7),
      ),
      pw.SizedBox(height: 16),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionLabel('Notes', navy),
                pw.Text(
                  invoice.notes,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 12),
                _sectionLabel('Payment', navy),
                pw.Text(
                  invoice.paymentDetails,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                    lineSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          _totalsCard(invoice, accent: navy, fill: const PdfColor.fromInt(0xFFEEF2F7)),
        ],
      ),
      pw.Spacer(),
      pw.Divider(color: navy, thickness: 2),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page 1 of 1',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ),
    ],
  );
}

pw.Widget _minimal(InvoiceData invoice) {
  const ink = PdfColor.fromInt(0xFF3D4741);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'INVOICE',
        style: pw.TextStyle(
          fontSize: 11,
          letterSpacing: 6,
          color: ink,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Container(height: 0.6, color: ink),
      pw.SizedBox(height: 18),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  invoice.companyName,
                  style: pw.TextStyle(fontSize: 16, color: ink),
                ),
                pw.SizedBox(height: 6),
                _mutedBlock(
                  '${invoice.companyAddress}\n${invoice.companyEmail}',
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                invoice.invoiceNumber,
                style: pw.TextStyle(
                  fontSize: 14,
                  color: ink,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '${invoice.issueDate}  |  due ${invoice.dueDate}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 28),
      pw.Text(
        'Billed to',
        style: const pw.TextStyle(
          fontSize: 8,
          letterSpacing: 1.4,
          color: PdfColors.grey500,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        invoice.clientCompany,
        style: pw.TextStyle(fontSize: 12, color: ink),
      ),
      pw.Text(
        '${invoice.clientName}\n${invoice.clientAddress}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700, lineSpacing: 2),
      ),
      pw.SizedBox(height: 28),
      _lineItems(invoice, ink),
      pw.SizedBox(height: 20),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _totalLine('Subtotal', money(invoice.subtotal)),
              _totalLine('Tax 10%', money(invoice.tax)),
              pw.SizedBox(height: 6),
              pw.Container(height: 0.6, color: ink),
              pw.SizedBox(height: 6),
              _totalLine('Amount due', money(invoice.total), bold: true, size: 13),
            ],
          ),
        ),
      ),
      pw.Spacer(),
      pw.Text(
        invoice.notes,
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    ],
  );
}

pw.Widget _corporate(InvoiceData invoice) {
  const dark = PdfColor.fromInt(0xFF111827);
  const gold = PdfColor.fromInt(0xFFD4A017);
  return pw.Column(
    children: [
      pw.Container(
        width: double.infinity,
        color: dark,
        padding: const pw.EdgeInsets.fromLTRB(36, 28, 36, 24),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    invoice.companyName.toUpperCase(),
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    invoice.companyTagline.toUpperCase(),
                    style: const pw.TextStyle(
                      color: PdfColor.fromInt(0xFFD4A017),
                      fontSize: 8,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'TAX INVOICE',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  invoice.invoiceNumber,
                  style: const pw.TextStyle(color: gold, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(36, 24, 36, 28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _infoTile('Bill to', '${invoice.clientCompany}\n${invoice.clientName}\n${invoice.clientAddress}'),
                  ),
                  pw.Expanded(
                    child: _infoTile('From', '${invoice.companyAddress}\n${invoice.companyEmail}\n${invoice.companyPhone}'),
                  ),
                  pw.Expanded(
                    child: _infoTile(
                      'Dates',
                      'Issued  ${invoice.issueDate}\nDue     ${invoice.dueDate}\nPO      ${invoice.poNumber}',
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              _table(
                invoice,
                headerColor: dark,
                headerText: PdfColors.white,
                rowAlt: const PdfColor.fromInt(0xFFF3F4F6),
              ),
              pw.SizedBox(height: 18),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      invoice.paymentDetails,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                        lineSpacing: 2,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 210,
                    color: dark,
                    padding: const pw.EdgeInsets.all(14),
                    child: pw.Column(
                      children: [
                        _totalLine(
                          'Subtotal',
                          money(invoice.subtotal),
                          color: PdfColors.grey300,
                        ),
                        _totalLine(
                          'Tax',
                          money(invoice.tax),
                          color: PdfColors.grey300,
                        ),
                        pw.SizedBox(height: 8),
                        _totalLine(
                          'TOTAL DUE',
                          money(invoice.total),
                          bold: true,
                          size: 14,
                          color: gold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                invoice.notes,
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

pw.Widget _aqua(InvoiceData invoice) {
  const teal = PdfColor.fromInt(0xFF0AA4D4);
  const deep = PdfColor.fromInt(0xFF0B5F75);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFEFFAFF),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        padding: const pw.EdgeInsets.all(18),
        child: pw.Row(
          children: [
            pw.Container(width: 8, height: 48, color: teal),
            pw.SizedBox(width: 14),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    invoice.companyName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: deep,
                    ),
                  ),
                  pw.Text(
                    invoice.companyEmail,
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Invoice',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: teal,
                  ),
                ),
                pw.Text(
                  invoice.invoiceNumber,
                  style: const pw.TextStyle(fontSize: 10, color: deep),
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      pw.Row(
        children: [
          pw.Expanded(child: _pill('Issued', invoice.issueDate, teal)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _pill('Due date', invoice.dueDate, teal)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _pill('PO number', invoice.poNumber, teal)),
        ],
      ),
      pw.SizedBox(height: 18),
      _billTo(invoice, labelColor: deep),
      pw.SizedBox(height: 16),
      _table(
        invoice,
        headerColor: teal,
        headerText: PdfColors.white,
        rowAlt: const PdfColor.fromInt(0xFFEFFAFF),
      ),
      pw.SizedBox(height: 16),
        pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Text(
              invoice.paymentDetails,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.blueGrey600,
                lineSpacing: 2,
              ),
            ),
          ),
          _totalsCard(invoice, accent: deep, fill: const PdfColor.fromInt(0xFFEFFAFF)),
        ],
      ),
      pw.Spacer(),
      pw.Text(
        invoice.notes,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600),
      ),
    ],
  );
}

pw.Widget _crimson(InvoiceData invoice) {
  const red = PdfColor.fromInt(0xFFC81E1E);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'INVOICE',
        style: pw.TextStyle(
          fontSize: 36,
          fontWeight: pw.FontWeight.bold,
          color: red,
        ),
      ),
      pw.Container(height: 6, width: 120, color: red),
      pw.SizedBox(height: 16),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  invoice.companyName,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                _mutedBlock(
                  '${invoice.companyAddress}\n${invoice.companyPhone}',
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('# ${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Date  ${invoice.issueDate}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Due   ${invoice.dueDate}', style: const pw.TextStyle(fontSize: 9, color: red)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 18),
      pw.Container(
        width: double.infinity,
        color: const PdfColor.fromInt(0xFFFFF1F1),
        padding: const pw.EdgeInsets.all(12),
        child: _billTo(invoice, labelColor: red),
      ),
      pw.SizedBox(height: 16),
      _table(
        invoice,
        headerColor: red,
        headerText: PdfColors.white,
        rowAlt: const PdfColor.fromInt(0xFFFFF5F5),
      ),
      pw.SizedBox(height: 16),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Container(
          width: 220,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: red, width: 2)),
          child: pw.Column(
            children: [
              _totalLine('Subtotal', money(invoice.subtotal)),
              _totalLine('Tax', money(invoice.tax)),
              pw.SizedBox(height: 8),
              _totalLine('TOTAL', money(invoice.total), bold: true, size: 16, color: red),
            ],
          ),
        ),
      ),
      pw.Spacer(),
      pw.Text(invoice.notes, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
    ],
  );
}

pw.Widget _boxed(InvoiceData invoice) {
  const slate = PdfColor.fromInt(0xFF334155);
  return pw.Column(
    children: [
      pw.Row(
        children: [
          pw.Expanded(
            child: _box(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FROM', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, letterSpacing: 1)),
                  pw.SizedBox(height: 4),
                  pw.Text(invoice.companyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: slate)),
                  pw.Text(invoice.companyAddress, style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: _box(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TO', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, letterSpacing: 1)),
                  pw.SizedBox(height: 4),
                  pw.Text(invoice.clientCompany, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: slate)),
                  pw.Text('${invoice.clientName}\n${invoice.clientAddress}', style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
                ],
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        children: [
          pw.Expanded(child: _box(child: _centerMeta('INVOICE', invoice.invoiceNumber, slate))),
          pw.SizedBox(width: 10),
          pw.Expanded(child: _box(child: _centerMeta('ISSUED', invoice.issueDate, slate))),
          pw.SizedBox(width: 10),
          pw.Expanded(child: _box(child: _centerMeta('DUE', invoice.dueDate, slate))),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Expanded(
        child: _box(
          child: _table(
            invoice,
            headerColor: slate,
            headerText: PdfColors.white,
            rowAlt: const PdfColor.fromInt(0xFFF8FAFC),
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _box(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PAYMENT', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, letterSpacing: 1)),
                  pw.SizedBox(height: 6),
                  pw.Text(invoice.paymentDetails, style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            width: 200,
            child: _box(
              fill: const PdfColor.fromInt(0xFFF1F5F9),
              child: pw.Column(
                children: [
                  _totalLine('Subtotal', money(invoice.subtotal)),
                  _totalLine('Tax', money(invoice.tax)),
                  pw.Divider(color: slate),
                  _totalLine('Total', money(invoice.total), bold: true, size: 13, color: slate),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _sidebar(InvoiceData invoice) {
  const navy = PdfColor.fromInt(0xFF0F172A);
  const mint = PdfColor.fromInt(0xFF5EEAD4);
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Container(
        width: 168,
        color: navy,
        padding: const pw.EdgeInsets.fromLTRB(18, 28, 18, 24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              invoice.companyName,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              invoice.companyTagline,
              style: const pw.TextStyle(color: mint, fontSize: 8),
            ),
            pw.SizedBox(height: 20),
            _sideLabel('From'),
            pw.Text(
              '${invoice.companyAddress}\n${invoice.companyEmail}\n${invoice.companyPhone}',
              style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8, lineSpacing: 2),
            ),
            pw.SizedBox(height: 18),
            _sideLabel('Invoice'),
            pw.Text(
              invoice.invoiceNumber,
              style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Issued ${invoice.issueDate}', style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 8)),
            pw.Text('Due ${invoice.dueDate}', style: const pw.TextStyle(color: mint, fontSize: 8)),
            pw.Spacer(),
            _sideLabel('Pay to'),
            pw.Text(
              invoice.paymentDetails,
              style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8, lineSpacing: 2),
            ),
          ],
        ),
      ),
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice',
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: navy),
              ),
              pw.SizedBox(height: 16),
              _billTo(invoice, labelColor: navy),
              pw.SizedBox(height: 18),
              _table(
                invoice,
                headerColor: navy,
                headerText: PdfColors.white,
                rowAlt: const PdfColor.fromInt(0xFFF1F5F9),
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: _totalsCard(invoice, accent: navy, fill: const PdfColor.fromInt(0xFFECFDF5)),
              ),
              pw.Spacer(),
              pw.Text(invoice.notes, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ),
      ),
    ],
  );
}

pw.Widget _elegant(InvoiceData invoice) {
  const wine = PdfColor.fromInt(0xFF7A1F3D);
  final serif = pw.Font.times();
  final serifBold = pw.Font.timesBold();
  return pw.Column(
    children: [
      pw.Container(height: 1.2, color: wine),
      pw.SizedBox(height: 16),
      pw.Text(
        invoice.companyName,
        style: pw.TextStyle(font: serifBold, fontSize: 22, color: wine),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        invoice.companyTagline,
        style: pw.TextStyle(font: serif, fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        'I N V O I C E',
        style: pw.TextStyle(font: serif, fontSize: 12, letterSpacing: 6, color: wine),
      ),
      pw.SizedBox(height: 16),
      pw.Container(height: 0.6, color: wine),
      pw.SizedBox(height: 18),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              children: [
                pw.Text('Prepared for', style: pw.TextStyle(font: serif, fontSize: 9, color: wine)),
                pw.Text(invoice.clientCompany, style: pw.TextStyle(font: serifBold, fontSize: 12)),
                pw.Text(
                  '${invoice.clientName}\n${invoice.clientAddress}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: serif, fontSize: 9, lineSpacing: 2),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              children: [
                pw.Text('No. ${invoice.invoiceNumber}', style: pw.TextStyle(font: serifBold, fontSize: 11)),
                pw.SizedBox(height: 4),
                pw.Text('Issued ${invoice.issueDate}', style: pw.TextStyle(font: serif, fontSize: 9)),
                pw.Text('Payable by ${invoice.dueDate}', style: pw.TextStyle(font: serif, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 22),
      _table(
        invoice,
        headerColor: wine,
        headerText: PdfColors.white,
        rowAlt: const PdfColor.fromInt(0xFFF8F1F4),
      ),
      pw.SizedBox(height: 18),
      pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Container(
          width: 240,
          child: pw.Column(
            children: [
              _totalLine('Subtotal', money(invoice.subtotal)),
              _totalLine('Tax', money(invoice.tax)),
              pw.SizedBox(height: 6),
              pw.Container(height: 0.6, color: wine),
              pw.SizedBox(height: 6),
              pw.Text(
                'Amount due  ${money(invoice.total)}',
                style: pw.TextStyle(font: serifBold, fontSize: 13, color: wine),
              ),
            ],
          ),
        ),
      ),
      pw.Spacer(),
      pw.Text(
        invoice.notes,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: serif, fontSize: 9, fontStyle: pw.FontStyle.italic),
      ),
      pw.SizedBox(height: 12),
      pw.Container(height: 1.2, color: wine),
    ],
  );
}

pw.Widget _creative(InvoiceData invoice) {
  const coral = PdfColor.fromInt(0xFFE85D04);
  const ink = PdfColor.fromInt(0xFF3D1F0A);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 18,
            height: 90,
            color: coral,
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'hello from',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text(
                  invoice.companyName,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: ink),
                ),
                pw.Text(invoice.companyEmail, style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: coral,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('INVOICE', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text(invoice.invoiceNumber, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 22),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('FOR', style: pw.TextStyle(color: coral, fontSize: 9, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                pw.Text(invoice.clientCompany, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: ink)),
                pw.Text('${invoice.clientName}\n${invoice.clientAddress}', style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('issued  ${invoice.issueDate}', style: const pw.TextStyle(fontSize: 9)),
                pw.Text('due  ${invoice.dueDate}', style: pw.TextStyle(fontSize: 9, color: coral, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      _lineItems(invoice, ink, accent: coral),
      pw.SizedBox(height: 18),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(invoice.notes, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ),
          pw.Container(
            width: 190,
            padding: const pw.EdgeInsets.all(12),
            color: const PdfColor.fromInt(0xFFFFF0E5),
            child: pw.Column(
              children: [
                _totalLine('Subtotal', money(invoice.subtotal)),
                _totalLine('Tax', money(invoice.tax)),
                pw.SizedBox(height: 8),
                _totalLine('Please pay', money(invoice.total), bold: true, size: 13, color: coral),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _receipt(InvoiceData invoice) {
  final mono = pw.Font.courier();
  final monoBold = pw.Font.courierBold();
  return pw.Center(
    child: pw.Container(
      width: 360,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(invoice.companyName.toUpperCase(), style: pw.TextStyle(font: monoBold, fontSize: 14)),
          pw.Text(invoice.companyAddress.replaceAll('\n', ' | '), style: pw.TextStyle(font: mono, fontSize: 8)),
          pw.Text(invoice.companyPhone, style: pw.TextStyle(font: mono, fontSize: 8)),
          pw.SizedBox(height: 10),
          pw.Text('- - - - - - - - - - - - - - - - - - - -', style: pw.TextStyle(font: mono, fontSize: 10)),
          pw.Text('INVOICE  ${invoice.invoiceNumber}', style: pw.TextStyle(font: monoBold, fontSize: 11)),
          pw.Text('${invoice.issueDate}    DUE ${invoice.dueDate}', style: pw.TextStyle(font: mono, fontSize: 8)),
          pw.Text('- - - - - - - - - - - - - - - - - - - -', style: pw.TextStyle(font: mono, fontSize: 10)),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'SOLD TO: ${invoice.clientCompany}\n${invoice.clientName}',
              style: pw.TextStyle(font: mono, fontSize: 8),
            ),
          ),
          pw.SizedBox(height: 10),
          ...invoice.items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(item.description.toUpperCase(), style: pw.TextStyle(font: monoBold, fontSize: 8)),
                      ),
                      pw.Text(money(item.total), style: pw.TextStyle(font: mono, fontSize: 8)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${item.quantity} x ${money(item.unitPrice)}', style: pw.TextStyle(font: mono, fontSize: 7, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          pw.Text('- - - - - - - - - - - - - - - - - - - -', style: pw.TextStyle(font: mono, fontSize: 10)),
          _receiptTotal('SUBTOTAL', money(invoice.subtotal), mono),
          _receiptTotal('TAX 10%', money(invoice.tax), mono),
          _receiptTotal('TOTAL', money(invoice.total), monoBold),
          pw.Text('- - - - - - - - - - - - - - - - - - - -', style: pw.TextStyle(font: mono, fontSize: 10)),
          pw.SizedBox(height: 10),
          pw.Text(invoice.notes.toUpperCase(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: mono, fontSize: 7)),
          pw.SizedBox(height: 8),
          pw.Text('*** END OF INVOICE ***', style: pw.TextStyle(font: monoBold, fontSize: 8)),
        ],
      ),
    ),
  );
}

pw.Widget _billTo(InvoiceData invoice, {PdfColor labelColor = PdfColors.blueGrey800}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'BILL TO',
        style: pw.TextStyle(
          fontSize: 8,
          letterSpacing: 1.2,
          fontWeight: pw.FontWeight.bold,
          color: labelColor,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(invoice.clientCompany, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.Text(invoice.clientName, style: const pw.TextStyle(fontSize: 9)),
      pw.Text(invoice.clientAddress, style: const pw.TextStyle(fontSize: 9, lineSpacing: 2, color: PdfColors.grey700)),
    ],
  );
}

pw.Widget _mutedBlock(String text) {
  return pw.Text(
    text,
    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700, lineSpacing: 2),
  );
}

pw.Widget _sectionLabel(String text, PdfColor color) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      text.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 8,
        letterSpacing: 1.1,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    ),
  );
}

pw.Widget _kv(String label, String value, PdfColor color) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: color)),
        pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

pw.Widget _table(
  InvoiceData invoice, {
  required PdfColor headerColor,
  required PdfColor headerText,
  required PdfColor rowAlt,
}) {
  return pw.Table(
    columnWidths: {
      0: const pw.FlexColumnWidth(3.2),
      1: const pw.FlexColumnWidth(0.8),
      2: const pw.FlexColumnWidth(1.1),
      3: const pw.FlexColumnWidth(1.1),
    },
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: headerColor),
        children: [
          _th('Description', headerText),
          _th('Qty', headerText, align: pw.TextAlign.center),
          _th('Price', headerText, align: pw.TextAlign.right),
          _th('Total', headerText, align: pw.TextAlign.right),
        ],
      ),
      ...invoice.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return pw.TableRow(
          decoration: pw.BoxDecoration(color: index.isOdd ? rowAlt : PdfColors.white),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(item.description, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text(item.detail, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ),
            _td('${item.quantity}', align: pw.TextAlign.center),
            _td(money(item.unitPrice), align: pw.TextAlign.right),
            _td(money(item.total), align: pw.TextAlign.right, bold: true),
          ],
        );
      }),
    ],
  );
}

pw.Widget _th(String text, PdfColor color, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Text(
      text.toUpperCase(),
      textAlign: align,
      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: color, letterSpacing: 0.6),
    ),
  );
}

pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
    ),
  );
}

pw.Widget _lineItems(InvoiceData invoice, PdfColor ink, {PdfColor? accent}) {
  return pw.Column(
    children: [
      pw.Row(
        children: [
          pw.Expanded(flex: 4, child: pw.Text('Item', style: pw.TextStyle(fontSize: 8, color: accent ?? PdfColors.grey500, letterSpacing: 1))),
          pw.SizedBox(width: 40, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, color: accent ?? PdfColors.grey500))),
          pw.SizedBox(width: 70, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, color: accent ?? PdfColors.grey500))),
        ],
      ),
      pw.SizedBox(height: 6),
      pw.Container(height: 0.5, color: ink),
      ...invoice.items.map(
        (item) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.4)),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.description, style: pw.TextStyle(fontSize: 10, color: ink)),
                    pw.Text(item.detail, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  ],
                ),
              ),
              pw.SizedBox(width: 40, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
              pw.SizedBox(width: 70, child: pw.Text(money(item.total), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            ],
          ),
        ),
      ),
    ],
  );
}

pw.Widget _totalsCard(InvoiceData invoice, {required PdfColor accent, required PdfColor fill}) {
  return pw.Container(
    width: 190,
    padding: const pw.EdgeInsets.all(12),
    color: fill,
    child: pw.Column(
      children: [
        _totalLine('Subtotal', money(invoice.subtotal)),
        _totalLine('Tax 10%', money(invoice.tax)),
        pw.SizedBox(height: 8),
        _totalLine('Total due', money(invoice.total), bold: true, size: 13, color: accent),
      ],
    ),
  );
}

pw.Widget _totalLine(
  String label,
  String value, {
  bool bold = false,
  double size = 9,
  PdfColor color = PdfColors.grey800,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: size, color: color, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value, style: pw.TextStyle(fontSize: size, color: color, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    ),
  );
}

pw.Widget _infoTile(String title, String body) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title.toUpperCase(), style: const pw.TextStyle(fontSize: 8, letterSpacing: 1, color: PdfColors.grey500)),
      pw.SizedBox(height: 4),
      pw.Text(body, style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
    ],
  );
}

pw.Widget _pill(String label, String value, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: color, width: 0.6),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label.toUpperCase(), style: pw.TextStyle(fontSize: 7, color: color, letterSpacing: 0.8)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

pw.Widget _box({required pw.Widget child, PdfColor? fill}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: fill ?? PdfColors.white,
      border: pw.Border.all(color: PdfColors.blueGrey200, width: 0.8),
    ),
    child: child,
  );
}

pw.Widget _centerMeta(String label, String value, PdfColor color) {
  return pw.Column(
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 8, color: color, letterSpacing: 1)),
      pw.SizedBox(height: 4),
      pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
    ],
  );
}

pw.Widget _sideLabel(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      text.toUpperCase(),
      style: const pw.TextStyle(fontSize: 7, letterSpacing: 1.2, color: PdfColor.fromInt(0xFF5EEAD4)),
    ),
  );
}

pw.Widget _receiptTotal(String label, String value, pw.Font font) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 9)),
      ],
    ),
  );
}
