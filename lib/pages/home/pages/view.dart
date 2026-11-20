import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inpdf/invoices/invoice_catalog.dart';
import 'package:inpdf/invoices/invoice_data.dart';
import 'package:inpdf/invoices/invoice_pdf.dart';
import 'package:inpdf/library/invoice_library.dart';
import 'package:inpdf/pages/home/pages/invoice_edit.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ViewPage extends StatefulWidget {
  final InvoiceFormat format;
  final InvoiceData invoice;
  const ViewPage({
    super.key,
    required this.format,
    this.invoice = sampleInvoice,
  });

  static Route<void> route(
    InvoiceFormat format, {
    InvoiceData invoice = sampleInvoice,
  }) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, _) => ViewPage(
        format: format,
        invoice: invoice,
      ),
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, _, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final _transform = TransformationController();
  Uint8List? _pdfBytes;
  final _pages = <PdfRaster>[];
  bool _loading = true;
  String? _error;
  double _scale = 1;
  int _pageIndex = 0;
  bool _busy = false;
  late InvoiceData _invoice = widget.invoice;

  InvoiceFormat get format => widget.format;

  String get _filename {
    final number = _invoice.invoiceNumber.trim().replaceAll(RegExp(r'[^\w\-]+'), '_');
    return '${format.id}-${number.isEmpty ? 'invoice' : number}.pdf';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  Future<Uint8List> _buildPdf() {
    return buildInvoicePdf(
      format: format,
      invoice: _invoice,
      pageFormat: PdfPageFormat.a4,
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await _buildPdf();
      final dpi = mounted
          ? (72 * MediaQuery.devicePixelRatioOf(context).clamp(1.5, 2.5))
          : 150.0;
      final rasters = <PdfRaster>[];
      await for (final page in Printing.raster(bytes, dpi: dpi)) {
        rasters.add(page);
      }
      if (!mounted) return;
      _transform.value = Matrix4.identity();
      setState(() {
        _pdfBytes = bytes;
        _pages
          ..clear()
          ..addAll(rasters);
        _loading = false;
        _scale = 1;
        _pageIndex = 0;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Color get _onAccent {
    return format.accent.computeLuminance() > 0.45
        ? const Color(0xFF101218)
        : Colors.white;
  }

  void _onInteraction() {
    final next = _transform.value.getMaxScaleOnAxis();
    if ((next - _scale).abs() < 0.02) return;
    setState(() => _scale = next);
  }

  void _nudgeZoom(double factor) {
    HapticFeedback.selectionClick();
    final box = context.findRenderObject() as RenderBox?;
    final focal = box == null
        ? Offset.zero
        : Offset(box.size.width / 2, box.size.height / 2);
    final current = _transform.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(1.0, 4.0);
    if (next == current) return;
    final scene = _transform.toScene(focal);
    _transform.value = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(next, next, next, 1)
      ..translateByDouble(-scene.dx, -scene.dy, 0, 1);
    setState(() => _scale = next);
  }

  void _resetZoom() {
    HapticFeedback.selectionClick();
    _transform.value = Matrix4.identity();
    setState(() => _scale = 1);
  }

  Future<void> _download() async {
    if (_pdfBytes == null || _busy) return;
    setState(() => _busy = true);
    try {
      await InvoiceLibrary.instance.save(
        format: format,
        invoice: _invoice,
        bytes: _pdfBytes!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to library and device files')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveAndShare() async {
    if (_pdfBytes == null || _busy) return;
    setState(() => _busy = true);
    try {
      await InvoiceLibrary.instance.save(
        format: format,
        invoice: _invoice,
        bytes: _pdfBytes!,
      );
      await Printing.sharePdf(bytes: _pdfBytes!, filename: _filename);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openEditor() async {
    final updated = await Navigator.push<InvoiceData>(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceEditPage(
          format: format,
          invoice: _invoice,
        ),
      ),
    );
    if (updated == null || !mounted) return;
    setState(() => _invoice = updated);
    await _load();
  }

  Future<void> _print() async {
    final bytes = _pdfBytes;
    if (bytes == null || _busy) return;
    setState(() => _busy = true);
    try {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF101218),
        body: Stack(
          children: [
            _AmbientBackground(accent: format.accent),
            Column(
              children: [
                _ViewerHeader(
                  format: format,
                  onBack: () => Navigator.maybePop(context),
                  onAddData: _openEditor,
                ),
                Expanded(child: _buildCanvas()),
              ],
            ),
            if (!_loading && _error == null)
              Positioned(
                right: 16,
                bottom: 118,
                child: _ZoomCapsule(
                  scale: _scale,
                  onZoomIn: () => _nudgeZoom(1.25),
                  onZoomOut: () => _nudgeZoom(0.8),
                  onReset: _resetZoom,
                ),
              ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 22,
              child: SafeArea(
                top: false,
                child: _ActionDock(
                  accent: format.accent,
                  onAccent: _onAccent,
                  enabled: !_loading && _error == null && !_busy,
                  onPrint: _print,
                  onDownload: _download,
                  onSaveAndShare: _saveAndShare,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    if (_error != null) {
      return _ErrorState(
        message: _error!,
        accent: format.accent,
        onRetry: _load,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 108),
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 4,
        clipBehavior: Clip.none,
        onInteractionUpdate: (_) => _onInteraction(),
        onInteractionEnd: (_) => _onInteraction(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Center(
                child: _PaperStage(
                  format: format,
                  loading: _loading,
                  pages: _pages,
                  pageIndex: _pageIndex,
                  invoiceNumber: _invoice.invoiceNumber,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.7, -0.85),
          radius: 1.15,
          colors: [
            accent.withValues(alpha: 0.34),
            const Color(0xFF101218),
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ViewerHeader extends StatelessWidget {
  const _ViewerHeader({
    required this.format,
    required this.onBack,
    required this.onAddData,
  });

  final InvoiceFormat format;
  final VoidCallback onBack;
  final VoidCallback onAddData;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            _GlassIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format.name,
                    style: const TextStyle(
                      fontFamily: 'Magic',
                      fontSize: 28,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
            _AddDataButton(accent: format.accent, onTap: onAddData),
          ],
        ),
      ),
    );
  }
}

class _PaperStage extends StatelessWidget {
  const _PaperStage({
    required this.format,
    required this.loading,
    required this.pages,
    required this.pageIndex,
    required this.invoiceNumber,
  });

  final InvoiceFormat format;
  final bool loading;
  final List<PdfRaster> pages;
  final int pageIndex;
  final String invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontal = 28.0;
        final maxW = math.max(120.0, constraints.maxWidth - horizontal * 2);
        final maxH = math.max(160.0, constraints.maxHeight - 36);
        const aspect = 1 / 1.4142;
        var width = maxW;
        var height = width / aspect;
        if (height > maxH) {
          height = maxH;
          width = height * aspect;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: format.id,
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: _PaperSheet(
                    accent: format.accent,
                    loading: loading,
                    raster: pages.isEmpty ? null : pages[pageIndex],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pages.length > 1
                  ? '$invoiceNumber  ·  ${pageIndex + 1} / ${pages.length}'
                  : invoiceNumber,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PaperSheet extends StatelessWidget {
  const _PaperSheet({
    required this.accent,
    required this.loading,
    required this.raster,
  });

  final Color accent;
  final bool loading;
  final PdfRaster? raster;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: raster == null
            ? _PaperPlaceholder(accent: accent, loading: loading)
            : Image(
                image: PdfRasterImage(raster!),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }
}

class _PaperPlaceholder extends StatelessWidget {
  const _PaperPlaceholder({required this.accent, required this.loading});

  final Color accent;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7F8),
      child: Center(
        child: loading
            ? SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: accent,
                ),
              )
            : Icon(Icons.picture_as_pdf_outlined, color: accent, size: 36),
      ),
    );
  }
}

class _ZoomCapsule extends StatelessWidget {
  const _ZoomCapsule({
    required this.scale,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final double scale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomHit(icon: Icons.add, onTap: onZoomIn),
          GestureDetector(
            onTap: onReset,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Text(
                '${(scale * 100).round()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
            ),
          ),
          _ZoomHit(icon: Icons.remove, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _ZoomHit extends StatelessWidget {
  const _ZoomHit({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _ActionDock extends StatelessWidget {
  const _ActionDock({
    required this.accent,
    required this.onAccent,
    required this.enabled,
    required this.onPrint,
    required this.onDownload,
    required this.onSaveAndShare,
  });

  final Color accent;
  final Color onAccent;
  final bool enabled;
  final VoidCallback onPrint;
  final VoidCallback onDownload;
  final VoidCallback onSaveAndShare;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            _DockIcon(
              icon: Icons.print_outlined,
              label: 'Print',
              onTap: enabled ? onPrint : null,
            ),
            _DockIcon(
              icon: Icons.download_rounded,
              label: 'Download',
              onTap: enabled ? onDownload : null,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: FilledButton(
                onPressed: enabled ? onSaveAndShare : null,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  'Save & share',
                  style: TextStyle(fontFamily: 'Magic', fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _AddDataButton extends StatelessWidget {
  const _AddDataButton({required this.accent, required this.onTap});

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_note_rounded, color: accent, size: 20),
                const SizedBox(width: 6),
                const Text(
                  'Add data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({required this.child, required this.radius});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xE61B1E27),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.accent,
    required this.onRetry,
  });

  final String message;
  final Color accent;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: accent, size: 40),
          const SizedBox(height: 12),
          Text(
            'Could not open this invoice',
            style: const TextStyle(
              fontFamily: 'Magic',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
