import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/auth.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements AuthStateListener{
  BuildContext _ctx;

  File _image = null;

  // final picker = ImagePicker();

  NetworkUtil _netUtil = new NetworkUtil();

  bool _isLoading = false;
  bool _isdataLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  int num = 0;
  double u_balance,m_balance;
  String all_order="0",all_user="0",user_id,time_slot,cutoff_time,user_type,user_status,user_balance,min_balance,accept_nagative_balance;
  String deliveryboy_name,deliveryboy_mobile,user_language,user_first_name,user_last_name,user_mobile_number;


  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 = new GlobalKey<RefreshIndicatorState>();

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    user_language= prefs.getString("user_language") ?? '';
    print("user_language : "+ user_language);
    _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
      'user_id': user_id,
    }).then((dynamic res) async {
      print(res);
      setState(() {
        // print(res);
        user_status = res["user_status"].toString();
        if(user_status == "1")
        {
          time_slot = res["time_slot"].toString();
          cutoff_time = res["cutoff_time"].toString();
          user_type = res["user_type"].toString();
          user_balance = res["user_balance"].toString();
          min_balance = res["min_balance"].toString();
          user_first_name = res["user_first_name"].toString();
          user_last_name = res["user_last_name"].toString();
          user_mobile_number = res["user_mobile_number"].toString();
          accept_nagative_balance = res["accept_nagative_balance"].toString();
          u_balance = double.parse(user_balance);
          m_balance = double.parse(min_balance);

          // u_balance = res["u_balance"];
          // min_balance = res["min_balance"];
          print("user_balance : "+user_balance);
          print("min_balance : "+min_balance);
          print("user_id : "+user_id);
          print("user_type : "+user_type);
          print("user_type : "+time_slot);
        }
        else{}

        _isdataLoading = false;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        key: scaffoldKey,
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (BuildContext context,
                  bool innerBoxIsScrolled) {
                return <Widget>[
                  // SliverAppBar(
                  //   centerTitle: true,
                  //   backgroundColor: maincolor,
                  //   title: Text("Profile",
                  //     style: TextStyle(color: Colors.white),),
                  //   iconTheme: IconThemeData(color: Colors.white),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.vertical(
                  //       bottom: Radius.circular(20),
                  //     ),
                  //   ),
                  //   pinned: true,
                  //   floating: true,
                  //   forceElevated: innerBoxIsScrolled,
                  // ),
                ];
              },
              body: (_isdataLoading)
                  ? new Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              )
                  : ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Image.asset('images/man.png',width: MediaQuery.of(context).size.width*0.20,),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.all(10),
                        ),

                        Text(user_first_name==null?"":user_first_name, style: TextStyle(color: blackcolor,fontSize: textSizeMMedium, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        SizedBox(
                          height: spacing_standard,
                        ),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                              ),
                              color: maincolor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(9, 7, 9, 7),
                              child: Text(user_mobile_number==null?"":"+44"+user_mobile_number, style: TextStyle(color: whitecolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            )
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                      color: whitecolor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: spacing_standard_new,
                          ),
                          InkWell(
                            onTap: ()
                            {
                              Navigator.of(context).pushNamed("/paymentlist");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            topRight: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                            bottomRight: Radius.circular(8.0),
                                          ),
                                          color: maincolor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(7, 6, 7, 6),
                                          child: Icon(Icons.add,size:textSizeNormal,color: whitecolor,),
                                        )
                                    ),
                                    SizedBox(
                                      width: spacing_middle,
                                    ),
                                    Text("Balance", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  ],
                                ),
                                Icon(Icons.chevron_right,size:textSizeNormal,color: titletext,),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spacing_xlarge,
                          ),
                          InkWell(
                            onTap: ()
                            {
                              Navigator.of(context).pushNamed("/order");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            topRight: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                            bottomRight: Radius.circular(8.0),
                                          ),
                                          color: maincolor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(7, 6, 7, 6),
                                          child: Icon(Icons.lock,size:textSizeNormal,color: whitecolor,),
                                        )
                                    ),
                                    SizedBox(
                                      width: spacing_middle,
                                    ),
                                    Text("My Order", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  ],
                                ),
                                Icon(Icons.chevron_right,size:textSizeNormal,color: titletext,),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spacing_xlarge,
                          ),
                          InkWell(
                            onTap: ()
                            {
                              Navigator.of(context).pushNamed("/changepassword");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            topRight: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                            bottomRight: Radius.circular(8.0),
                                          ),
                                          color: maincolor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(7, 6, 7, 6),
                                          child: Icon(Icons.lock,size:textSizeNormal,color: whitecolor,),
                                        )
                                    ),
                                    SizedBox(
                                      width: spacing_middle,
                                    ),
                                    Text("Change Password", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  ],
                                ),
                                Icon(Icons.chevron_right,size:textSizeNormal,color: titletext,),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spacing_xlarge,
                          ),

                          // InkWell(
                          //   onTap: ()
                          //   {
                          //     Navigator.of(context).pushNamed("/language");
                          //   },
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Row(
                          //         children: [
                          //           Container(
                          //               decoration: BoxDecoration(
                          //                 borderRadius: BorderRadius.only(
                          //                   topLeft: Radius.circular(8.0),
                          //                   topRight: Radius.circular(8.0),
                          //                   bottomLeft: Radius.circular(8.0),
                          //                   bottomRight: Radius.circular(8.0),
                          //                 ),
                          //                 color: maincolor,
                          //               ),
                          //               child: Padding(
                          //                 padding: EdgeInsets.fromLTRB(7, 6, 7, 6),
                          //                 child: Icon(Icons.language,size:textSizeNormal,color: whitecolor,),
                          //               )
                          //           ),
                          //           SizedBox(
                          //             width: spacing_middle,
                          //           ),
                          //           Text("Language", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                          //         ],
                          //       ),
                          //       Icon(Icons.chevron_right,size:textSizeNormal,color: titletext,),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: spacing_xlarge,
                          // ),
                          InkWell(
                            onTap: ()
                            {
                              logout();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            topRight: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                            bottomRight: Radius.circular(8.0),
                                          ),
                                          color: maincolor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(7, 6, 7, 6),
                                          child: Icon(Icons.logout,size:textSizeNormal,color: whitecolor,),
                                        )
                                    ),
                                    SizedBox(
                                      width: spacing_middle,
                                    ),
                                    Text("Logout", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  ],
                                ),
                                Icon(Icons.chevron_right,size:textSizeNormal,color: titletext,),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spacing_middle,
                          ),
                        ],
                      ),
                    )
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
  
  void logout() async
  {
    var authStateProvider = new AuthStateProvider();
    authStateProvider.dispose(this);
    var db = new DatabaseHelper();
    await db.deleteUsers();
    authStateProvider.notify(AuthState.LOGGED_OUT);
    Navigator.of(context).pushReplacementNamed("/login");
  }

  @override
  void onAuthStateChanged(AuthState state) {
    // TODO: implement onAuthStateChanged
  }
  
}
