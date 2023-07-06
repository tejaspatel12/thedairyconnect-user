import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/models/admin.dart';
import 'package:dairy_connect/models/user.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:lottie/lottie.dart';

import '../../auth.dart';

class RegisterDoneScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterDoneScreenState();
  }
}

class RegisterDoneScreenState extends State<RegisterDoneScreen>{
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _mobile_numbers;
  bool passwordVisible = true;

  String deliveryboy_token="";

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
    // startTime();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }


  @override
  Widget build(BuildContext context) {
    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        // backgroundColor: Colors.transparent,
        // backgroundColor: Colors.grey.shade50,
        body:SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/done.json',
                      repeat: true,
                      reverse: false,
                      animate: true,
                      height: MediaQuery.of(context).size.height * 0.40,
                    ),
                  ),

                  Text("Account Create Successfully",style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.w700,color: maincolor, letterSpacing: 0.5),),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomRight: Radius.circular(5.0),
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(5.0)),
                      color: whitecolor,
                    ),
                    child: Column(
                      children: [

                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.06,
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(25,0, 25, 0),
                          child: InkWell(
                            onTap: ()
                            {
                              Navigator.of(_ctx).pushReplacementNamed("/login");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  topRight: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0),
                                  bottomRight: Radius.circular(5.0),
                                ),
                                color: maincolor,
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(-0, -2),
                                      color: Colors.white10// shadow direction: bottom right
                                  ),
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10),
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("LOGIN NOW",
                                    style: TextStyle(
                                        color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.04,
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(25,0, 25, 0),
                          child: InkWell(
                            onTap: ()
                            {
                              exit(0);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  topRight: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0),
                                  bottomRight: Radius.circular(5.0),
                                ),
                                color: redcolor,
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(-0, -2),
                                      color: Colors.white10// shadow direction: bottom right
                                  ),
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10),
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Not Now",
                                    style: TextStyle(
                                        color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.04,
                        ),



                      ],
                    ),
                  ),

                ],
              ),
            ],
          ),


        ),

      );
    }
  }

  @override
  void onLoginError(String errorTxt) {
    // FlashHelper.errorBar(context, message: errorTxt);
    setState(() => _isLoading = false);
  }

  @override
  void onLoginSuccess(Admin user) async {
    //_showSnackBar(user.toString());
    setState(() => _isLoading = false);
    var db = new DatabaseHelper();
    await db.saveUser(user);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.notify(AuthState.LOGGED_IN);
  }

  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }
}
