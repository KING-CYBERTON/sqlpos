import 'package:flutter/material.dart';

import 'Productlist.dart';
import 'Users.dart';
import 'dashboard.dart';
import 'movement.dart';
import 'saleslist.dart';

class adminAppBar extends StatefulWidget {
  const adminAppBar({super.key});

  @override
  State<adminAppBar> createState() => _adminAppBarState();
}

class _adminAppBarState extends State<adminAppBar> {
  late int pageindex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.amber,
                    height: 150,
                    width: 150,
                    child: Text("Dashboard"),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.red,
                    height: 150,
                    width: 150,
                    child: Text("Products"),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.pink,
                    height: 150,
                    width: 150,
                    child: Text("Sales"),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.green,
                    height: 150,
                    width: 150,
                    child: Text("Users"),
                  ),
                ),
                GestureDetector(
                    onTap: () {},
                    child: Container(
                      color: Colors.red,
                      height: 150,
                      width: 150,
                      child: Text("Products"),
                    )),
              ],
            ),
           
          ),
          Expanded(
            child: IndexedStack(
              index: pageindex,
              children: [
                Dashboard(),
                InventoryLogPage(),
                ProductList(),
                SalesList(),
                UserList(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
