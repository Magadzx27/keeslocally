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

  @override
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      mainPage(),
      const newMemberPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('كيس'),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color(0xFF110F1A),
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
            _onNavItemTapped;
          });
        },
        selectedIndex: _selectedIndex,
        indicatorColor: const Color.fromARGB(255, 255, 255, 255),
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(
              Icons.home_outlined,
              color: Colors.lightBlueAccent,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.group_add),
            icon: Icon(
              Icons.group_add_outlined,
              color: Colors.lightBlueAccent,
            ),
            label: 'Add Member',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
    );
  }
}
