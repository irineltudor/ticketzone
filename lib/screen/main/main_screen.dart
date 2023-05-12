import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ticketzone/screen/home/home_screen.dart';
import 'package:ticketzone/screen/inventory/inventory_screen.dart';
import 'package:ticketzone/screen/settings/settings_screen.dart';
import 'package:ticketzone/screen/tournament/tournaments_screen.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:ticketzone/widget/menu_widget.dart';

import '../../item/menu_item.dart';
import '../menu/menu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<MenuItem> menuItem = MenuItems.all;

  int index = 0;
  final screens = [
    const HomeScreen(),
    const TournamentsScreen(),
    const InventoryScreen(),
    const SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        color: Colors.white,
        index: index,
        items: const [
          Icon(Icons.home),
          Icon(Icons.gamepad),
          Icon(Icons.inventory),
          Icon(Icons.settings)
        ],
        onTap: (value) => setState(() {
          index = value;
        }),
      ),
      body: ZoomDrawer(
        borderRadius: 30,
        angle: -15,
        slideWidth: width / 1.75,
        style: DrawerStyle.Style1,
        showShadow: true,
        backgroundColor: Colors.white,
        mainScreen: screens[index],
        menuScreen: Builder(builder: (context) {
          return MenuScreen(
              currentItem: menuItem[index],
              onSelectedItem: (item) {
                setState(() {
                  index = menuItem.indexOf(item);
                });
                ZoomDrawer.of(context)!.close();
              });
        }),
      ),
    );
  }
}
