
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dairy_connect/screens/calendar/calendar_screen.dart';
import 'package:dairy_connect/screens/home/home_screen.dart';
import 'package:dairy_connect/screens/wallet/recharge_offer_screen.dart';
import 'package:dairy_connect/screens/wallet/wallet_screen.dart';
import 'package:dairy_connect/utils/color.dart';


class BottomNavigationBarController extends StatefulWidget {
  @override
  _BottomNavigationBarControllerState createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> {

  int _selectedIndex = 0;
  final List<Widget> pages = [
    HomeScreen(),
    CalendarScreen(),
    WalletScreen(),
    RechargeOfferScreen(),
  ];
  //Bottom Navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: maincolor,
          elevation: 10,
          currentIndex: _selectedIndex,
          onTap: (int index){
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home",),
            BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Manage",),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet",),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Offer",),
          ],
        )
    );
  }

}
