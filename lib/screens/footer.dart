import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  const Footer({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/order');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/account');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/contact');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Increased height to prevent overflow and make the footer bigger.
      child: BottomNavigationBar(
        backgroundColor: Colors.brown,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF800000), // Maroon color for active page.
        unselectedItemColor: Colors.white,
        onTap: (index) => _onItemTapped(context, index),
        iconSize: 30,
        selectedLabelStyle: const TextStyle(fontSize: 16),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee_outlined),
            label: "Order",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Account",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.markunread_mailbox_outlined),
            label: "Contact",
          ),
        ],
      ),
    );
  }
}