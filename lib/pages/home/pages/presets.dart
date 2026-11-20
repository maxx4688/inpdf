import 'package:flutter/material.dart';
import 'package:inpdf/invoices/invoice_catalog.dart';
import 'package:inpdf/invoices/invoice_preview.dart';
import 'package:inpdf/pages/home/pages/view.dart';
import 'package:inpdf/utils.dart';

class PresetsPage extends StatefulWidget {
  const PresetsPage({super.key});

  @override
  State<PresetsPage> createState() => _PresetsPageState();
}

class _PresetsPageState extends State<PresetsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Center(child: Image.asset("lib/assets/icons/print_clr.png")),
          const Center(
            child: Text(
              "Explore formats",
              style: TextStyle(fontFamily: "Magic", fontSize: 40),
            ),
          ),
          const Divider(color: primaryColor, thickness: 1, height: 0),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoiceFormats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final format = invoiceFormats[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, ViewPage.route(format));
                },
                child: Hero(
                  tag: format.id,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InvoicePreviewCard(format: format),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
