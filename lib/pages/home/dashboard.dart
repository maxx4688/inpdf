import 'package:flutter/material.dart';
import 'package:inpdf/library/invoice_library.dart';
import 'package:inpdf/pages/home/pages/homepage.dart';
import 'package:inpdf/pages/home/pages/presets.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    InvoiceLibrary.instance.ensureLoaded();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        children: [HomePage(), PresetsPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: TextStyle(fontFamily: "Magic", fontSize: 14,),
        selectedLabelStyle: TextStyle(fontFamily: "Magic", fontSize: 14),
        currentIndex: _currentIndex,

        onTap: (value) {
          _pageController.animateToPage(
            value,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(
            activeIcon: Image.asset("lib/assets/icons/pdf_clr.png",height: 40,),
            icon: Image.asset("lib/assets/icons/pdf.png",height: 40,),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            activeIcon: Image.asset("lib/assets/icons/print_clr.png",height: 40,),
            icon: Image.asset("lib/assets/icons/print_out.png",height: 40,),
            label: "Explore",
          ),
        ],
      ),
    );
  }
}
