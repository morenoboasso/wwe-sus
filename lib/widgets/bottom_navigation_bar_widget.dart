import 'package:flutter/material.dart';
import '../pages/create_match_card_page.dart';
import '../style/color_style.dart';
class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});
  @override
  BottomNavigationBarWidgetState createState() => BottomNavigationBarWidgetState();
}

class BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const CreateMatchCardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 45, right: 45, top: 5),
        child: Container(
          decoration: BoxDecoration(
            color: ColorsBets.whiteHD,
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(color: ColorsBets.whiteHD, width: 1.8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7.0),
            child: BottomNavigationBar(
              elevation: 0,
              iconSize: 24,
              selectedIconTheme: const IconThemeData(size: 28),
              unselectedIconTheme: const IconThemeData(size: 24),
              items: <BottomNavigationBarItem>[
                _buildNavigationBarItem(Icons.add_box, 'Crea', 0),
                _buildNavigationBarItem(Icons.add_box, 'Crea', 1),
                _buildNavigationBarItem(Icons.add_box, 'Crea', 2),

              ],
              currentIndex: _selectedIndex,
              selectedItemColor: ColorsBets.blackHD,
              unselectedItemColor: ColorsBets.blackHD.withOpacity(0.4),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              onTap: _onItemTapped,
              backgroundColor: ColorsBets.whiteHD,
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}