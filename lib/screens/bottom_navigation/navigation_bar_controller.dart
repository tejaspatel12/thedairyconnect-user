import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth.dart';

class DrawerNavigationBarController extends StatefulWidget {
  @override
  _DrawerNavigationBarControllerState createState() =>
      _DrawerNavigationBarControllerState();
}

class _DrawerNavigationBarControllerState
    extends State<DrawerNavigationBarController> implements AuthStateListener{


  String user_id,user_first_name="Patel",user_last_name="Tejas",user_mobile_number="1234567890";
  String login;
  SharedPreferences prefs;
  // _loadPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // prefs = await SharedPreferences.getInstance();
  //   user_id= prefs.getString("user_id") ?? '';
  //   user_first_name= prefs.getString("user_first_name") ?? '';
  //   user_last_name= prefs.getString("user_last_name") ?? '';
  //   user_mobile_number= prefs.getString("user_mobile_number") ?? '';
  // }
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id= prefs.getString("user_id") ?? '';
      user_first_name= prefs.getString("user_first_name") ?? '';
      user_last_name= prefs.getString("user_last_name") ?? '';
      user_mobile_number= prefs.getString("user_mobile_number") ?? '';
    });
    print("user_id " + user_id);
    print("user_first_name " + user_first_name);
    print("user_last_name " + user_last_name);
    print("user_mobile_number " + user_mobile_number);
    navigationPage();
  }

  void navigationPage() async {
    var db = new DatabaseHelper();
    var isLoggedIn = await db.isLoggedIn();
    if(isLoggedIn) {
      setState(() {
        login="yes";
        print("login :"+login);
      });
    } else {
      setState(() {
        login = "no";
        print("login :"+login);
      });
    }
  }

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
            DrawerHeader(
            padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),


            child: Column(
              children: <Widget>[
                login=="yes"?
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.white, // button color
                          child: Image.asset(
                            'images/man.png',
                            width: MediaQuery.of(context).size.width * 0.15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            // first_name+" "+ last_name,
                            "Welcome, "+user_first_name +" "+ user_last_name,maxLines: 1,overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "+44"+user_mobile_number,maxLines: 1,overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16,color: Colors.white,),
                          ),

                        ],
                      ),
                    ],
                  ),
                ):
                InkWell(
                  onTap: ()
                  {
                    Navigator.of(context).pushNamed("/check");
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Colors.white, // button color
                            child: Image.asset(
                              'images/logo.png',
                              width: MediaQuery.of(context).size.width * 0.15,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              // first_name+" "+ last_name,
                              "Login Require",
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Need Login to Access App Function",overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16,color: Colors.white,),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
                color: maincolor,
            ),
          ),

          login=="yes"?
          SizedBox():
          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.login, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Login',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              Navigator.of(context).pushNamed("/check");
            },
          ),

          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.home_outlined, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Home',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/bottomhome");
            },
          ),


          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.reorder, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'My Orders',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              Navigator.of(context).pushNamed("/order");
            },
          ),

          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.contact_page_rounded, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'My Invoice',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/invoice");
            },
          ),

          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.notifications_active_rounded, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'My Notifications',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/mynotifications");
            },
          ),

          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.call_outlined, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Contact Us',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              // Navigator.of(context).pushReplacementNamed("/contactus");
              Navigator.of(context).pushNamed("/contactus");
            },
          ),

          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.help_outline, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'FAQ',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              // Navigator.of(context).pushReplacementNamed("/faq");
              Navigator.of(context).pushNamed("/faq");
            },
          ),

          login=="yes"?
          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.logout, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Logout',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: Color(0xff9E9E9E), size: 13.0,
                ),
              ],
            ),
            onTap: (){
              logout();
            },
          ):
          SizedBox(),


          _divider(),
          SizedBox(
            height: 10,
          ),
          new Center(
            child: new Text(appver,style: TextStyle(color:maincolor)),
          ),
          SizedBox(
            height: 10,
          ),
          // new Center(
          //   child: new Text("Developed by " + titlecapital,style: TextStyle(fontSize: 12.0)),
          // ),
          // SizedBox(
          //   height: 10,
          // ),
        ],
      ),
    );
  }

  void logout() async
  {
    var authStateProvider = new AuthStateProvider();
    authStateProvider.dispose(this);
    var db = new DatabaseHelper();
    await db.deleteUsers();
    authStateProvider.notify(AuthState.LOGGED_OUT);
    // Navigator.of(context).pushReplacementNamed("/check");
    prefs.remove('user_id');
    prefs.remove('user_first_name');
    prefs.remove('user_last_name');
    prefs.remove('user_mobile_number');
    Navigator.of(context).pushReplacementNamed("/check");
  }

  @override
  void onAuthStateChanged(AuthState state) {
    // TODO: implement onAuthStateChanged
  }

}