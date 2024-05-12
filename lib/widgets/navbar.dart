import 'package:flutter/material.dart';

class Navbar extends StatefulWidget{
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar>{

  void _onItemTapped(int index){
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.fromLTRB(64, 0, 64, 32),
      child: SizedBox(height: 48, child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped
        )
      )),
    );
  }
}