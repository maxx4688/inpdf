import 'package:flutter/material.dart';
import 'package:inpdf/invoices/invoice_catalog.dart';
import 'package:inpdf/invoices/invoice_data.dart';
import 'package:inpdf/utils.dart';

class InvoiceEditPage extends StatefulWidget {
  const InvoiceEditPage({
    super.key,
    required this.format,
    required this.invoice,
  });

  final InvoiceFormat format;
  final InvoiceData invoice;

  @override
  State<InvoiceEditPage> createState() => _InvoiceEditPageState();
}

class _InvoiceEditPageState extends State<InvoiceEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyName;
  late final TextEditingController _companyTagline;
  late final TextEditingController _companyAddress;
  late final TextEditingController _companyEmail;
  late final TextEditingController _companyPhone;
  late final TextEditingController _clientName;
  late final TextEditingController _clientCompany;
  late final TextEditingController _clientAddress;
  late final TextEditingController _invoiceNumber;
  late final TextEditingController _issueDate;
  late final TextEditingController _dueDate;
  late final TextEditingController _poNumber;
  late final TextEditingController _taxPercent;
  late final TextEditingController _notes;
  late final TextEditingController _paymentDetails;
  late final List<_ItemControllers> _items;

  InvoiceFormat get format => widget.format;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    _companyName = TextEditingController(text: invoice.companyName);
    _companyTagline = TextEditingController(text: invoice.companyTagline);
    _companyAddress = TextEditingController(text: invoice.companyAddress);
    _companyEmail = TextEditingController(text: invoice.companyEmail);
    _companyPhone = TextEditingController(text: invoice.companyPhone);
    _clientName = TextEditingController(text: invoice.clientName);
    _clientCompany = TextEditingController(text: invoice.clientCompany);
    _clientAddress = TextEditingController(text: invoice.clientAddress);
    _invoiceNumber = TextEditingController(text: invoice.invoiceNumber);
    _issueDate = TextEditingController(text: invoice.issueDate);
    _dueDate = TextEditingController(text: invoice.dueDate);
    _poNumber = TextEditingController(text: invoice.poNumber);
    _taxPercent = TextEditingController(
      text: (invoice.taxRate * 100).toStringAsFixed(0),
    );
    _notes = TextEditingController(text: invoice.notes);
    _paymentDetails = TextEditingController(text: invoice.paymentDetails);
    _items = [
      for (final item in invoice.items) _ItemControllers.fromItem(item),
    ];
    if (_items.isEmpty) {
      _items.add(_ItemControllers.empty());
    }
  }

  @override
  void dispose() {
    _companyName.dispose();
    _companyTagline.dispose();
    _companyAddress.dispose();
    _companyEmail.dispose();
    _companyPhone.dispose();
    _clientName.dispose();
    _clientCompany.dispose();
    _clientAddress.dispose();
    _invoiceNumber.dispose();
    _issueDate.dispose();
    _dueDate.dispose();
    _poNumber.dispose();
    _taxPercent.dispose();
    _notes.dispose();
    _paymentDetails.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Color get _onAccent {
    return format.accent.computeLuminance() > 0.45
        ? const Color(0xFF101218)
        : Colors.white;
  }

  void _addItem() {
    setState(() => _items.add(_ItemControllers.empty()));
  }

  void _removeItem(int index) {
    if (_items.length == 1) return;
    setState(() {
      _items.removeAt(index).dispose();
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = _tryParseDate(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  InvoiceData? _collect() {
    if (!(_formKey.currentState?.validate() ?? false)) return null;

    final items = <InvoiceItem>[];
    for (final row in _items) {
      final description = row.description.text.trim();
      if (description.isEmpty) continue;
      items.add(
        InvoiceItem(
          description: description,
          detail: row.detail.text.trim(),
          quantity: int.tryParse(row.quantity.text.trim()) ?? 1,
          unitPrice: double.tryParse(row.unitPrice.text.trim()) ?? 0,
        ),
      );
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one line item.')),
      );
      return null;
    }

    final tax = double.tryParse(_taxPercent.text.trim()) ?? 0;
    return InvoiceData(
      companyName: _companyName.text.trim(),
      companyTagline: _companyTagline.text.trim(),
      companyAddress: _companyAddress.text.trim(),
      companyEmail: _companyEmail.text.trim(),
      companyPhone: _companyPhone.text.trim(),
      clientName: _clientName.text.trim(),
      clientCompany: _clientCompany.text.trim(),
      clientAddress: _clientAddress.text.trim(),
      invoiceNumber: _invoiceNumber.text.trim(),
      issueDate: _issueDate.text.trim(),
      dueDate: _dueDate.text.trim(),
      poNumber: _poNumber.text.trim(),
      items: items,
      taxRate: tax / 100,
      notes: _notes.text.trim(),
      paymentDetails: _paymentDetails.text.trim(),
    );
  }

  void _preview() {
    final invoice = _collect();
    if (invoice == null) return;
    Navigator.pop(context, invoice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F9),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Invoice data',
          style: TextStyle(fontFamily: 'Magic', fontSize: 28),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _SectionTitle(title: 'Your business', color: format.accent),
            _Field(controller: _companyName, label: 'Company name', requiredField: true),
            _Field(controller: _companyTagline, label: 'Tagline'),
            _Field(controller: _companyAddress, label: 'Address', maxLines: 3),
            _Field(
              controller: _companyEmail,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            _Field(
              controller: _companyPhone,
              label: 'Phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Bill to', color: format.accent),
            _Field(controller: _clientCompany, label: 'Client company', requiredField: true),
            _Field(controller: _clientName, label: 'Client name'),
            _Field(controller: _clientAddress, label: 'Client address', maxLines: 3),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Invoice', color: format.accent),
            _Field(controller: _invoiceNumber, label: 'Invoice number', requiredField: true),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _issueDate,
                    label: 'Issue date',
                    readOnly: true,
                    onTap: () => _pickDate(_issueDate),
                    suffix: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    controller: _dueDate,
                    label: 'Due date',
                    readOnly: true,
                    onTap: () => _pickDate(_dueDate),
                    suffix: Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),
            _Field(controller: _poNumber, label: 'PO number'),
            _Field(
              controller: _taxPercent,
              label: 'Tax %',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SectionTitle(title: 'Line items', color: format.accent),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: format.accent),
                ),
              ],
            ),
            for (var i = 0; i < _items.length; i++)
              _ItemCard(
                index: i,
                item: _items[i],
                accent: format.accent,
                canRemove: _items.length > 1,
                onRemove: () => _removeItem(i),
              ),
            const SizedBox(height: 10),
            _SectionTitle(title: 'Notes & payment', color: format.accent),
            _Field(controller: _notes, label: 'Notes', maxLines: 3),
            _Field(
              controller: _paymentDetails,
              label: 'Payment details',
              maxLines: 4,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: _preview,
              style: FilledButton.styleFrom(
                backgroundColor: format.accent,
                foregroundColor: _onAccent,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Preview',
                style: TextStyle(fontFamily: 'Magic', fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Magic',
          fontSize: 26,
          color: color,
          height: 1,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.requiredField = false,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool requiredField;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffix == null ? null : Icon(suffix, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: primaryColor, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.index,
    required this.item,
    required this.accent,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final _ItemControllers item;
  final Color accent;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Item ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: canRemove ? onRemove : null,
                icon: const Icon(Icons.close_rounded),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          _Field(controller: item.description, label: 'Description', requiredField: true),
          _Field(controller: item.detail, label: 'Detail'),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: item.quantity,
                  label: 'Qty',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _Field(
                  controller: item.unitPrice,
                  label: 'Unit price',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemControllers {
  _ItemControllers({
    required this.description,
    required this.detail,
    required this.quantity,
    required this.unitPrice,
  });

  factory _ItemControllers.fromItem(InvoiceItem item) {
    return _ItemControllers(
      description: TextEditingController(text: item.description),
      detail: TextEditingController(text: item.detail),
      quantity: TextEditingController(text: '${item.quantity}'),
      unitPrice: TextEditingController(text: item.unitPrice.toStringAsFixed(2)),
    );
  }

  factory _ItemControllers.empty() {
    return _ItemControllers(
      description: TextEditingController(),
      detail: TextEditingController(),
      quantity: TextEditingController(text: '1'),
      unitPrice: TextEditingController(text: '0.00'),
    );
  }

  final TextEditingController description;
  final TextEditingController detail;
  final TextEditingController quantity;
  final TextEditingController unitPrice;

  void dispose() {
    description.dispose();
    detail.dispose();
    quantity.dispose();
    unitPrice.dispose();
  }
}

DateTime? _tryParseDate(String value) {
  const months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = months[parts[1]];
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

String _formatDate(DateTime date) {
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
