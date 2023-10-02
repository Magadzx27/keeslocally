import 'package:flutter/material.dart';
import 'package:kees/screen/mainPage.dart';
import 'package:kees/screen/newMemberspage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, Key});

  @override
  Widget build(BuildContext context) {
    return Keespage();
  }
}

class Keespage extends StatefulWidget {
  const Keespage({super.key, Key});

  @override
  _KeespageState createState() => _KeespageState();
}

class _KeespageState extends State<Keespage> {
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كيس'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 1, 78, 70),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'كيس',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.balance),
            label: 'القوانين',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          mainPage(),
          const NewMemberPage(),
        ],
      ),
    );
  }
}
