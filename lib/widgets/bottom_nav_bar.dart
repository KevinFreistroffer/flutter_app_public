import 'package:flutter/material.dart';
import '../services/consumables_storage.service.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void routeTo(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/list');
        break;
      case 1:
        Navigator.pushNamed(context, '/totals');
        break;
      case 2:
        Navigator.pushNamed(context, '/macros');
        break;
      case 3:
        Storage calc = new Storage();
        calc.reset();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color.fromRGBO(51, 51, 51, 1),
      currentIndex: _selectedIndex,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.list,
            color: Color.fromRGBO(241, 165, 34, 1),
          ),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.assessment,
            size: 28,
            color: Color.fromRGBO(137, 209, 133, 1),
          ),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.favorite,
            size: 28,
            color: Color.fromRGBO(244, 135, 113, 1),
          ),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.refresh,
            color: Colors.black,
          ),
          title: Text(''),
        ),
      ],
      onTap: routeTo,
      selectedItemColor: Color.fromRGBO(33, 150, 143, 1),
    );
  }
}
