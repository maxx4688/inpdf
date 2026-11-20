import 'package:flutter/material.dart';
import 'package:inpdf/invoices/invoice_preview.dart';
import 'package:inpdf/library/invoice_library.dart';
import 'package:inpdf/library/saved_invoice.dart';
import 'package:inpdf/pages/home/pages/view.dart';
import 'package:inpdf/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _library = InvoiceLibrary.instance;

  @override
  void initState() {
    super.initState();
    _library.ensureLoaded();
  }

  Future<void> _open(SavedInvoice record) async {
    await Navigator.push(
      context,
      ViewPage.route(record.format, invoice: record.invoice),
    );
  }

  Future<void> _delete(SavedInvoice record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove PDF?'),
          content: Text('Delete ${record.title} from your library?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await _library.delete(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _library,
        builder: (context, _) {
          final items = _library.items;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              Center(child: Image.asset("lib/assets/icons/pdf_clr.png")),
              const Center(
                child: Text(
                  "Saved library",
                  style: TextStyle(
                    fontFamily: "Magic",
                    fontSize: 40,
                  ),
                ),
              ),
              const Divider(color: primaryColor, thickness: 1, height: 0),
              if (items.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final record = items[index];
                    return GestureDetector(
                      onTap: () => _open(record),
                      onLongPress: () => _delete(record),
                      child: InvoicePreviewCard(
                        format: record.format,
                        title: record.title,
                        caption: record.caption,
                      ),
                    );
                  },
                )
              else
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.2,
                  ),
                  child: const Center(
                    child: Text(
                      "No PDFs found",
                      style: TextStyle(
                        fontFamily: "Magic",
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
