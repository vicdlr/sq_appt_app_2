import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/home_provider.dart';
import 'package:sq_notification/view/home/home_page.dart';
import 'package:sq_notification/view/home/my_booking.dart';
import 'package:sq_notification/view/home/request_new_booking.dart';

class BottomNavBar extends StatelessWidget {
   BottomNavBar({super.key});

  List pages = [
    HomePage(),
    MyBooking(),
    RequestNewBooking(),
  ];

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context,listen:  true);
    return Scaffold(
      body: pages[homeProvider.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: homeProvider.selectedIndex,
        onTap: (val){
          homeProvider.changeSelectedIndex(val);
          if(val == 2){
            homeProvider.setIndustriesEmpty();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label : ""
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.factory),
            label: ""
          ),
        ],
      ),
    );
  }
}
