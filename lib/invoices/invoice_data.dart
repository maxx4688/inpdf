class InvoiceItem {
  const InvoiceItem({
    required this.description,
    required this.detail,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final String detail;
  final int quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'description': description,
        'detail': detail,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

class InvoiceData {
  const InvoiceData({
    required this.companyName,
    required this.companyTagline,
    required this.companyAddress,
    required this.companyEmail,
    required this.companyPhone,
    required this.clientName,
    required this.clientCompany,
    required this.clientAddress,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.poNumber,
    required this.items,
    required this.taxRate,
    required this.notes,
    required this.paymentDetails,
  });

  final String companyName;
  final String companyTagline;
  final String companyAddress;
  final String companyEmail;
  final String companyPhone;
  final String clientName;
  final String clientCompany;
  final String clientAddress;
  final String invoiceNumber;
  final String issueDate;
  final String dueDate;
  final String poNumber;
  final List<InvoiceItem> items;
  final double taxRate;
  final String notes;
  final String paymentDetails;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  double get tax => subtotal * taxRate;

  double get total => subtotal + tax;

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'companyTagline': companyTagline,
        'companyAddress': companyAddress,
        'companyEmail': companyEmail,
        'companyPhone': companyPhone,
        'clientName': clientName,
        'clientCompany': clientCompany,
        'clientAddress': clientAddress,
        'invoiceNumber': invoiceNumber,
        'issueDate': issueDate,
        'dueDate': dueDate,
        'poNumber': poNumber,
        'items': items.map((item) => item.toJson()).toList(),
        'taxRate': taxRate,
        'notes': notes,
        'paymentDetails': paymentDetails,
      };

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      companyName: json['companyName'] as String? ?? '',
      companyTagline: json['companyTagline'] as String? ?? '',
      companyAddress: json['companyAddress'] as String? ?? '',
      companyEmail: json['companyEmail'] as String? ?? '',
      companyPhone: json['companyPhone'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientCompany: json['clientCompany'] as String? ?? '',
      clientAddress: json['clientAddress'] as String? ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      issueDate: json['issueDate'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      poNumber: json['poNumber'] as String? ?? '',
      items: [
        for (final item in (json['items'] as List? ?? const []))
          InvoiceItem.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      paymentDetails: json['paymentDetails'] as String? ?? '',
    );
  }
}

const sampleInvoice = InvoiceData(
  companyName: 'ASH Stores',
  companyTagline: 'Clothing, Shoes, and Accessories',
  companyAddress: '234 Main Street, Patna, Bihar',
  companyEmail: 'ashish.maxx4688@gmail.com',
  companyPhone: '+91 9876543210',
  clientName: 'Alleson Burgess',
  clientCompany: 'Burgess & Co.',
  clientAddress: '420 Pine Avenue\nSeattle, WA 98101',
  invoiceNumber: 'INV-2048',
  issueDate: '14 Sep 2026',
  dueDate: '28 Sep 2026',
  poNumber: 'PO-7712',
  items: [
    InvoiceItem(
      description: 'Brand identity package',
      detail: 'Logo, type, color system',
      quantity: 1,
      unitPrice: 2400,
    ),
    InvoiceItem(
      description: 'Website design',
      detail: 'Six-page marketing site',
      quantity: 1,
      unitPrice: 3800,
    ),
    InvoiceItem(
      description: 'Social media kit',
      detail: 'Templates for two platforms',
      quantity: 2,
      unitPrice: 450,
    ),
    InvoiceItem(
      description: 'Photography session',
      detail: 'Half-day studio shoot',
      quantity: 1,
      unitPrice: 900,
    ),
  ],
  taxRate: 0.10,
  notes: 'Thank you for your business. Please pay within 14 days.',
  paymentDetails: 'Bank: First National\nACC: 8821 4409 3310\nSWIFT: FNBOUS44',
);

String money(double value) => '\$${value.toStringAsFixed(2)}';
