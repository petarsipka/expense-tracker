import 'package:flutter/material.dart';
import 'transactions.dart';
import 'dashboard.dart';

class PageNavigation extends StatefulWidget {
  const PageNavigation({super.key});

  @override
  State<PageNavigation> createState() => _PageNavigationState();
}

class _PageNavigationState extends State<PageNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const[
    DashboardPage(),
    TransactionsPage(),
    Placeholder(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'dashboard'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            label: 'transactions'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'in progress'
          ),
        ],
      ),
    );
  }
}