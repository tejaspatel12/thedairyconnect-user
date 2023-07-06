import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ChangePasswordScreenState();
  }
}

class ChangePasswordScreenState extends State<ChangePasswordScreen>{
  BuildContext _ctx;
  // LocationResult _pickedLocation;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _oldpassword,_newpassword,_confirmpassword,user_id;
  bool passwordVisible = true;

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;
  NetworkUtil _netUtil = new NetworkUtil();

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id= prefs.getString("user_id") ?? '';
    });
  }

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
    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        // backgroundColor: Colors.transparent,
        // backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Change Password",style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: maincolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          // actions: <Widget>[
          //   new Stack(
          //     alignment: Alignment.center,
          //     children: <Widget>[
          //       Row(
          //         children: [
          //           new IconButton(icon: Icon(Icons.search_rounded),color: Colors.white, onPressed: () {
          //             Navigator.of(context).pushNamed("/search");
          //           }),
          //         ],
          //       )
          //     ],
          //   ),
          // ]
        ),
        body:Stack(
          children: [
            ListView(
              children: [
                Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.05,
                        ),
                        TextFormField(
                            initialValue: null,
                            obscureText: false,
                            keyboardType: TextInputType.text,
                            onSaved: (val) => _oldpassword = val,
                            onChanged: (val) => _oldpassword = val,
                            validator: (val) {
                              return val.length <= 0
                                  ? "Please Enter Current Password"
                                  : null;
                            },
                            autofocus: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: maincolor,
                                ),
                                hintText: 'Enter Current Password',
                                // isDense: true,
                                // contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                labelStyle: TextStyle(color: maincolor),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                      color: maincolor,width: 2,
                                    )
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                      color: maincolor,width: 2,
                                    )
                                ),
                                fillColor: Colors.white,
                                filled: true)),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.04,
                        ),
                        TextFormField(
                            initialValue: null,
                            obscureText: false,
                            keyboardType: TextInputType.text,
                            onSaved: (val) => _newpassword = val,
                            onChanged: (val) => _newpassword = val,
                            validator: (val) {
                              return val.length <= 0
                                  ? "Please Enter New Password"
                                  : null;
                            },
                            autofocus: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: maincolor,
                                ),
                                hintText: 'Enter New Password',
                                // isDense: true,
                                // contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                labelStyle: TextStyle(color: maincolor),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                      color: maincolor,width: 2,
                                    )
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                      color: maincolor,width: 2,
                                    )
                                ),
                                fillColor: Colors.white,
                                filled: true)),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.04,
                        ),
                        TextFormField(
                            initialValue: null,
                            obscureText: false,
                            keyboardType: TextInputType.text,
                            onSaved: (val) => _confirmpassword = val,
                            onChanged: (val) => _confirmpassword = val,
                            validator: (val) {
                              return val.length <= 0
                                  ? "Please Enter Confirm Password"
                                  : null;
                            },
                            autofocus: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: maincolor,
                                ),
                                hintText: 'Enter Confirm Password',
                                // isDense: true,
                                // contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                labelStyle: TextStyle(color: maincolor),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                      color: maincolor,width: 2,
                                    )
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                      color: maincolor,width: 2,
                                    )
                                ),
                                fillColor: Colors.white,
                                filled: true)),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.04,
                        ),


                      ],
                    ),
                  ),
                ),
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.01,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white10,Colors.white70],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                  ),
                ),
                Container(
                  color: whitecolor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () {

                            if(_newpassword!=_confirmpassword)
                            {
                              Fluttertoast.showToast(msg: "New Password and Confirm Password is not match.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 15);
                            }
                            else
                            {
                            if (_isLoading == false) {
                              final form = formKey.currentState;
                              if (form.validate()) {
                                setState(() => _isLoading = true);
                                form.save();
                                _netUtil.post(
                                    RestDatasource.PASSWORD, body: {
                                  'action': "user_change_password",
                                  "token":token,
                                  "oldcode": _oldpassword,
                                  "newcode": _newpassword,
                                  "confirm": _confirmpassword,
                                  "user_id": user_id,
                                  // "user_mobile": _mobilenum,
                                }).then((dynamic res) async {
                                  // print("Web Output"+res["status"]);
                                  if (res["status"] == "yes") {
                                    formKey.currentState.reset();
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            Dialog(
                                              backgroundColor: Colors.white,
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Container(
                                                          padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Lottie.asset(
                                                                'assets/done.json',
                                                                repeat: true,
                                                                reverse: true,
                                                                animate: true,
                                                              ),
                                                              // SvgPicture.asset('images/confirmed.svg',width: MediaQuery.of(context).size.width * 0.65,),
                                                              SizedBox(
                                                                height: spacing_standard,
                                                              ),
                                                              Align(
                                                                  alignment: Alignment.center,
                                                                  child: Text(res["message"], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold),)
                                                              ),
                                                              SizedBox(
                                                                height: spacing_standard,
                                                              ),
                                                              Align(
                                                                alignment: Alignment.center,
                                                                child: Text(res["password"],
                                                                  style: TextStyle(
                                                                    fontSize: textSizeMMedium,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: spacing_standard,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors.grey,
                                                        ),
                                                        Row(
                                                          children: <Widget>[

                                                            Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator.of(context).pushReplacementNamed("/bottomhome");
                                                                  // openCheckout();
                                                                },
                                                                child: Container(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      10, 10, 10, 15),
                                                                  alignment: Alignment
                                                                      .center,
                                                                  child: Text("Ohk",
                                                                    style: TextStyle(
                                                                        color: maincolor,
                                                                        fontSize: 15),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top:0.0,
                                                    right: 0.0,
                                                    child: new IconButton(
                                                        icon: Icon(Icons.cancel,color: maincolor,size: textSizeLarge,),
                                                        onPressed: () {
                                                          Navigator.pop(context,false);
                                                        }),
                                                  )
                                                ],
                                              ),
                                            )
                                    );
                                    // FlashHelper.successBar(context, message: res["message"]);
                                    setState(() => _isLoading = false);
                                    // Navigator.of(context).pushReplacementNamed("/done");
                                  }
                                  else if(res["status"] == "password_wrong")
                                  {
                                    formKey.currentState.reset();
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            Dialog(
                                              backgroundColor: Colors.white,
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Container(
                                                          padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Lottie.asset(
                                                                'assets/error.json',
                                                                repeat: true,
                                                                reverse: true,
                                                                animate: true,
                                                              ),
                                                              // SvgPicture.asset('images/confirmed.svg',width: MediaQuery.of(context).size.width * 0.65,),
                                                              SizedBox(
                                                                height: spacing_standard,
                                                              ),
                                                              Align(
                                                                  alignment: Alignment.center,
                                                                  child: Text(res["message"], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold),)
                                                              ),
                                                              SizedBox(
                                                                height: spacing_standard,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors.grey,
                                                        ),
                                                        Row(
                                                          children: <Widget>[

                                                            Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(context);
                                                                  // openCheckout();
                                                                },
                                                                child: Container(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      10, 10, 10, 15),
                                                                  alignment: Alignment
                                                                      .center,
                                                                  child: Text("Ohk",
                                                                    style: TextStyle(
                                                                        color: maincolor,
                                                                        fontSize: 15),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top:0.0,
                                                    right: 0.0,
                                                    child: new IconButton(
                                                        icon: Icon(Icons.cancel,color: maincolor,size: textSizeLarge,),
                                                        onPressed: () {
                                                          Navigator.pop(context,false);
                                                        }),
                                                  )
                                                ],
                                              ),
                                            )
                                    );
                                    // FlashHelper.successBar(context, message: res["message"]);
                                    setState(() => _isLoading = false);
                                    // Navigator.of(context).pushReplacementNamed("/done");
                                  }
                                  else {
                                    // FlashHelper.errorBar(context, message: res["message"]);
                                    setState(() => _isLoading = false);
                                  }
                                });
                              }
                            }
                            }
                            // FlashHelper.successBar(context, message: chackbox);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,15, 25, 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                  bottomLeft: Radius.circular(15.0),
                                  bottomRight: Radius.circular(15.0),
                                ),
                                color: maincolor,
                              ),
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              alignment: Alignment.center,
                              child: Text("Change Password",style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            )
          ],
        ),

      );
    }
  }
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }
  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }
  String validateMiddleName(String value) {
    if (value.length <= 3)
      return 'Name must be greater than 3';
    else
      return null;
  }
  String validateAddress(String value) {
    if (value.length <= 3)
      return 'Enter Valid Address';
    else
      return null;
  }
  String validatePassword(String value) {
    if (value.length <= 3)
      return 'Enter Valid Password';
    else
      return null;
  }
}
