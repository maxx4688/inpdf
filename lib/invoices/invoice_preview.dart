import 'package:flutter/material.dart';
import 'package:inpdf/invoices/invoice_catalog.dart';

class InvoicePreviewCard extends StatelessWidget {
  const InvoicePreviewCard({
    super.key,
    required this.format,
    this.title,
    this.caption,
  });

  final InvoiceFormat format;
  final String? title;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: format.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(10, 10),
                  ),
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: _PreviewBody(format: format),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                Text(
                  title ?? format.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Magic', fontSize: 18),
                ),
                Text(
                  caption ?? format.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({required this.format});

  final InvoiceFormat format;

  @override
  Widget build(BuildContext context) {
    switch (format.layout) {
      case InvoiceLayout.classic:
        return _ClassicPreview(color: format.accent);
      case InvoiceLayout.minimal:
        return _MinimalPreview(color: format.accent);
      case InvoiceLayout.corporate:
        return _CorporatePreview(color: format.accent);
      case InvoiceLayout.aqua:
        return _AquaPreview(color: format.accent);
      case InvoiceLayout.crimson:
        return _CrimsonPreview(color: format.accent);
      case InvoiceLayout.boxed:
        return _BoxedPreview(color: format.accent);
      case InvoiceLayout.sidebar:
        return _SidebarPreview(color: format.accent);
      case InvoiceLayout.elegant:
        return _ElegantPreview(color: format.accent);
      case InvoiceLayout.creative:
        return _CreativePreview(color: format.accent);
      case InvoiceLayout.receipt:
        return _ReceiptPreview(color: format.accent);
    }
  }
}

class _Line extends StatelessWidget {
  const _Line({this.width = double.infinity});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ClassicPreview extends StatelessWidget {
  const _ClassicPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: _Line(width: 48)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              color: color,
              child: const Text(
                'INVOICE',
                style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 10, color: color),
        const SizedBox(height: 6),
        ...List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              height: 8,
              color: i.isOdd ? color.withValues(alpha: 0.12) : Colors.white,
            ),
          ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: Container(width: 42, height: 16, color: color.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}

class _MinimalPreview extends StatelessWidget {
  const _MinimalPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INVOICE', style: TextStyle(fontSize: 7, letterSpacing: 2, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(height: 1, color: color),
        const SizedBox(height: 10),
        const _Line(width: 54),
        const SizedBox(height: 16),
        ...List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: _Line()),
                SizedBox(width: 16),
                SizedBox(width: 22, child: _Line()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CorporatePreview extends StatelessWidget {
  const _CorporatePreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 22,
          color: color,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 6),
          child: const Text('TAX INVOICE', style: TextStyle(color: Colors.white, fontSize: 7)),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(child: _Line()),
            SizedBox(width: 6),
            Expanded(child: _Line()),
            SizedBox(width: 6),
            Expanded(child: _Line()),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 8, color: color),
        const SizedBox(height: 4),
        const _Line(),
        const SizedBox(height: 4),
        const _Line(),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 48,
            height: 18,
            color: color,
            alignment: Alignment.center,
            child: const Text('DUE', style: TextStyle(color: Color(0xFFD4A017), fontSize: 7, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _AquaPreview extends StatelessWidget {
  const _AquaPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          color: color.withValues(alpha: 0.18),
          child: Row(
            children: [
              Container(width: 4, height: 18, color: color),
              const SizedBox(width: 6),
              const Expanded(child: _Line()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 8, color: color),
        const SizedBox(height: 4),
        const _Line(),
        const SizedBox(height: 4),
        const _Line(),
      ],
    );
  }
}

class _CrimsonPreview extends StatelessWidget {
  const _CrimsonPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INVOICE', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        Container(width: 36, height: 3, color: color),
        const SizedBox(height: 8),
        Container(
          height: 18,
          width: double.infinity,
          color: color.withValues(alpha: 0.12),
        ),
        const SizedBox(height: 8),
        Container(height: 8, color: color),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 50,
            height: 20,
            decoration: BoxDecoration(border: Border.all(color: color, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _BoxedPreview extends StatelessWidget {
  const _BoxedPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget cell() => Expanded(
      child: Container(
        height: 22,
        decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.35))),
      ),
    );
    return Column(
      children: [
        Row(children: [cell(), const SizedBox(width: 4), cell()]),
        const SizedBox(height: 4),
        Row(children: [cell(), const SizedBox(width: 4), cell(), const SizedBox(width: 4), cell()]),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.35))),
            child: Column(
              children: [
                Container(height: 8, color: color),
                const Padding(padding: EdgeInsets.all(4), child: _Line()),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: _Line()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarPreview extends StatelessWidget {
  const _SidebarPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          color: color,
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Container(height: 4, color: const Color(0xFF5EEAD4)),
              const SizedBox(height: 8),
              Container(height: 18, color: Colors.white24),
            ],
          ),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Line(width: 40),
              SizedBox(height: 8),
              _Line(),
              SizedBox(height: 4),
              _Line(),
              SizedBox(height: 4),
              _Line(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ElegantPreview extends StatelessWidget {
  const _ElegantPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 2, color: color),
        const SizedBox(height: 8),
        Text('Northline', style: TextStyle(color: color, fontSize: 11, fontStyle: FontStyle.italic)),
        const SizedBox(height: 2),
        Text('INVOICE', style: TextStyle(color: color, fontSize: 8, letterSpacing: 3)),
        const SizedBox(height: 8),
        Container(height: 1, color: color.withValues(alpha: 0.5)),
        const SizedBox(height: 10),
        Container(height: 8, color: color),
        const SizedBox(height: 6),
        const _Line(),
        const SizedBox(height: 4),
        const _Line(),
        const Spacer(),
        Container(height: 2, color: color),
      ],
    );
  }
}

class _CreativePreview extends StatelessWidget {
  const _CreativePreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 6, height: 28, color: color),
            const SizedBox(width: 6),
            const Expanded(child: _Line(width: 40)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              color: color,
              child: const Text('INV', style: TextStyle(color: Colors.white, fontSize: 7)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: _Line(),
          ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: Container(width: 44, height: 16, color: color.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Text('NORTHLINE', style: TextStyle(fontSize: 7, fontFamily: 'Courier', color: color, fontWeight: FontWeight.bold)),
            Text('- - - - - - -', style: TextStyle(fontSize: 8, color: color)),
            const _Line(),
            const SizedBox(height: 4),
            const _Line(),
            const SizedBox(height: 4),
            const _Line(),
            Text('- - - - - - -', style: TextStyle(fontSize: 8, color: color)),
            Text('TOTAL  \$8,800', style: TextStyle(fontSize: 7, fontFamily: 'Courier', color: color)),
          ],
        ),
      ),
    );
  }
}
