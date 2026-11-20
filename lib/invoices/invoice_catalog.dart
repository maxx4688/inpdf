import 'package:flutter/material.dart';

enum InvoiceLayout {
  classic,
  minimal,
  corporate,
  aqua,
  crimson,
  boxed,
  sidebar,
  elegant,
  creative,
  receipt,
}

class InvoiceFormat {
  const InvoiceFormat({
    required this.id,
    required this.name,
    required this.description,
    required this.layout,
    required this.accent,
    required this.surface,
  });

  final String id;
  final String name;
  final String description;
  final InvoiceLayout layout;
  final Color accent;
  final Color surface;
}

const invoiceFormats = <InvoiceFormat>[
  InvoiceFormat(
    id: 'classic',
    name: 'Classic',
    description: 'Navy letterhead & table',
    layout: InvoiceLayout.classic,
    accent: Color(0xFF1B365D),
    surface: Color(0xFFF4F7FB),
  ),
  InvoiceFormat(
    id: 'minimal',
    name: 'Minimal',
    description: 'Quiet lines, open space',
    layout: InvoiceLayout.minimal,
    accent: Color(0xFF5B6B63),
    surface: Color(0xFFF7F7F5),
  ),
  InvoiceFormat(
    id: 'corporate',
    name: 'Corporate',
    description: 'Dark band, gold total',
    layout: InvoiceLayout.corporate,
    accent: Color(0xFF111827),
    surface: Color(0xFFF3F4F6),
  ),
  InvoiceFormat(
    id: 'aqua',
    name: 'Aqua',
    description: 'Teal accent, modern grid',
    layout: InvoiceLayout.aqua,
    accent: Color(0xFF2FC7FE),
    surface: Color(0xFFEFFAFF),
  ),
  InvoiceFormat(
    id: 'crimson',
    name: 'Crimson',
    description: 'Bold red, high contrast',
    layout: InvoiceLayout.crimson,
    accent: Color(0xFFC81E1E),
    surface: Color(0xFFFFF5F5),
  ),
  InvoiceFormat(
    id: 'boxed',
    name: 'Boxed',
    description: 'Cards for every section',
    layout: InvoiceLayout.boxed,
    accent: Color(0xFF334155),
    surface: Color(0xFFF1F5F9),
  ),
  InvoiceFormat(
    id: 'sidebar',
    name: 'Sidebar',
    description: 'Left rail with details',
    layout: InvoiceLayout.sidebar,
    accent: Color(0xFF0F172A),
    surface: Color(0xFFF8FAFC),
  ),
  InvoiceFormat(
    id: 'elegant',
    name: 'Elegant',
    description: 'Centered serif letter',
    layout: InvoiceLayout.elegant,
    accent: Color(0xFF7A1F3D),
    surface: Color(0xFFFAF6F2),
  ),
  InvoiceFormat(
    id: 'creative',
    name: 'Creative',
    description: 'Asymmetric coral header',
    layout: InvoiceLayout.creative,
    accent: Color(0xFFE85D04),
    surface: Color(0xFFFFF7F0),
  ),
  InvoiceFormat(
    id: 'receipt',
    name: 'Receipt',
    description: 'Mono, dashed, compact',
    layout: InvoiceLayout.receipt,
    accent: Color(0xFF1F2937),
    surface: Color(0xFFF3F4F6),
  ),
];

InvoiceFormat invoiceFormatById(String id) {
  return invoiceFormats.firstWhere(
    (format) => format.id == id,
    orElse: () => invoiceFormats.first,
  );
}
