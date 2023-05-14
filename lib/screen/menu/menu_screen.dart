import 'package:flutter/material.dart';

import '../../item/menu_item.dart';

class MenuItems {
  static const home = MenuItem('Home', Icons.home);
  static const tournaments = MenuItem('Tournaments', Icons.gamepad);
  static const myTickets = MenuItem('Inventory', Icons.inventory);
  static const settings = MenuItem('Settings', Icons.settings);

  static const all = <MenuItem>[home, tournaments, myTickets, settings];
}

class MenuScreen extends StatelessWidget {
  final MenuItem currentItem;
  final ValueChanged<MenuItem> onSelectedItem;

  const MenuScreen(
      {Key? key, required this.currentItem, required this.onSelectedItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          ...MenuItems.all.map(buildMenuItem).toList(),
          Spacer(flex: 2),
        ],
      )),
    );
  }

  Widget buildMenuItem(MenuItem item) {
    return ListTileTheme(
      selectedColor: Colors.black,
      child: ListTile(
        selectedTileColor: Color.fromARGB(255, 255, 255, 255),
        selected: currentItem == item,
        minLeadingWidth: 20,
        leading: Icon(item.icon),
        title: Text(item.title),
        textColor: Colors.white,
        iconColor: Colors.white,
        onTap: () => onSelectedItem(item),
      ),
    );
  }
}
