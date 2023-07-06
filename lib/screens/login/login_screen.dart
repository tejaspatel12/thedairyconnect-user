import 'dart:async';
import 'dart:ui';
// import 'package:firebase_messaging/firebase_messaging.dart';
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

import '../../auth.dart';
import 'login_screen_presenter.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> implements LoginScreenContract, AuthStateListener {
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _mobile_numbers,_pass;
  bool passwordVisible = true;
  LoginScreenPresenter _presenter;
  String user_token="";
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  NetworkUtil _netUtil = new NetworkUtil();

  bool isOffline = false;
  bool done = false,pass= false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    // _firebaseMessaging.getToken().then((String t) {
    //   assert(t != null);
    //   setState(() {
    //     user_token=t;
    //     print("token  "+token);
    //   });
    // });
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  LoginScreenState() {
    _presenter = new LoginScreenPresenter(this);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
  }

  @override
  onAuthStateChanged(AuthState state) {
    if (state == AuthState.LOGGED_IN)
      Navigator.of(_ctx).pushReplacementNamed("/bottomhome");
  }

  @override
  Widget build(BuildContext context) {

   // _firebaseMessaging.getToken().then((String t)
   //  user_token==null? FirebaseMessaging.instance.getToken().then((String t) {
   //    print("Token :"+t);
   //    setState(() {
   //        user_token=t;
   //        print("token :: "+user_token);
   //    });
   //  }):Null;

    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        // backgroundColor: maincolor,
        // backgroundColor: Colors.transparent,
        // backgroundColor: Colors.grey.shade50,
        body:SafeArea(
          child: Stack(
            children: [

              SingleChildScrollView(
                reverse: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),

                      // _isLoading==true?
                      Image.asset(
                        'images/logo.png',
                        width: MediaQuery.of(context).size.width * 0.30,
                      ),
                      //     :
                      // Image.network(RestDatasource.MORE_IMAGE + app_login,
                      //   width: MediaQuery.of(context).size.width * 0.30,
                      // ),

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.09,
                      ),
                      Center(child: Text("Add Your Phone Number and Password",style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700,color: blackcolor, letterSpacing: 0.5),)),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.07,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Center(child: Text("Enter your phone number in order to\nsend you your OTP security code",style: TextStyle(fontSize: textSizeSMedium,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center)),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.08,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)),
                            color: whitecolor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
                            child: Form(
                              key: formKey,
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                      initialValue: null,
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      onSaved: (val) => _mobile_numbers = val,
                                      onChanged: (val)
                                      {
                                        setState(() {
                                          val.length == 10?done=true:done=false;
                                          _mobile_numbers = val;
                                        });
                                      },
                                      validator: validateMobile,
                                      decoration: const InputDecoration(

                                        // labelText: 'Enter Your Mobile Number',
                                          hintText: 'Enter Your Mobile Number',
                                          labelStyle: TextStyle(color: maincolor),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 2, color: maincolor
                                              )
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide()
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          isDense: true,
                                          contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),)),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width * 0.05,
                                  ),
                                  TextFormField(
                                      initialValue: null,
                                      obscureText: false,
                                      keyboardType: TextInputType.visiblePassword,
                                      onSaved: (val) => _pass = val,
                                      onChanged: (val)
                                      {
                                        setState(() {
                                          val.length == null?pass=false:pass=true;
                                          _pass = val;
                                        });
                                      },
                                      validator: validatePass,
                                      decoration: const InputDecoration(

                                        // labelText: 'Enter Your Mobile Number',
                                        hintText: 'Enter Your Password',
                                        labelStyle: TextStyle(color: maincolor),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2, color: maincolor
                                            )
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide()
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),)),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.40,
                      ),

                    ],
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Trouble logging in ? ",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: titletext, letterSpacing: 0.5),),
                      InkWell(
                          onTap: ()
                          {
                            Navigator.of(context).pushNamed("/forgotpassword");
                          },
                          child: Text("Forgot Password",style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600,color: maincolor, letterSpacing: 0.1),)),
                    ],
                  ),
                  done==false?
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                            child: InkWell(
                              onTap: () {
                                //FlashHelper.successBar(context, message: "Please Wait");
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0),
                                    bottomLeft: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0),
                                  ),
                                  color: maincolor,
                                ),
                                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                alignment: Alignment.center,
                                child: Text("Please Enter 10 Digit".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ):
                  pass==false?
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                            child: InkWell(
                              onTap: () {
                                //FlashHelper.successBar(context, message: "Please Wait");
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0),
                                    bottomLeft: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0),
                                  ),
                                  color: maincolor,
                                ),
                                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                alignment: Alignment.center,
                                child: Text("Please Enter Password".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ):
                  _isLoading==true?
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                            child: InkWell(
                              onTap: () {
                                //FlashHelper.successBar(context, message: "Please Wait");
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0),
                                    bottomLeft: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0),
                                  ),
                                  color: maincolor,
                                ),
                                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                alignment: Alignment.center,
                                child: Text("Please Wait".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ):
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                            child: InkWell(
                              onTap: () {
                                // FlashHelper.successBar(context, message: user_token);

                                // if (_isLoading == false) {
                                //   final form = formKey.currentState;
                                //   if (form.validate()) {
                                //     setState(() => _isLoading = true);
                                //     form.save();
                                //     NetworkUtil _netUtil = new NetworkUtil();
                                //     _netUtil.post(RestDatasource.LOGIN, body: {
                                //       "action": "userlogin",
                                //       "user_mobile_number": _mobile_numbers,
                                //     }).then((dynamic res) async {
                                //       if(res["status"] == "yes")
                                //       {
                                //         setState(() => _isLoading = false);
                                //         // FlashHelper.successBar(context, message: res['message']);
                                //         //FlashHelper.successBar(context, message: res['message'].toString());
                                //         Navigator.of(context).pushReplacementNamed("/otp",
                                //             arguments: {
                                //               // "last_id" : res["last_id"].toString(),
                                //               "user_id" : res["user_id"].toString(),
                                //               "user_mobile_number" : _mobile_numbers,
                                //               "user_token" : user_token,
                                //             });
                                //       }
                                //       else
                                //       {
                                //         setState(() => _isLoading = false);
                                //         //FlashHelper.errorBar(context, message: res['message']);
                                //       }
                                //     });
                                //   }
                                // }

                                if (_isLoading == false) {
                                  final form = formKey.currentState;
                                  if (form.validate()) {
                                    setState(() => _isLoading = true);
                                    form.save();

                                    setState(() => _isLoading = false);
                                    _presenter.doLogin(_mobile_numbers,_pass,user_token);

                                  }
                                }
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
                                ),
                                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                alignment: Alignment.center,
                                child: Text("Next".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.03,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("I accept the ",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: titletext, letterSpacing: 0.5),),
                      InkWell(
                          onTap: ()
                          {
                            Navigator.of(context).pushNamed("/termscondition");
                          },
                          child: Text("Terms and Conditions",style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600,color: maincolor, letterSpacing: 0.5),)),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.06,
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
    //FlashHelper.errorBar(context, message: errorTxt);
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

  String validatePass(String value) {
    if (value.length == null)
      return 'Please Enter Password';
    else if(value.length < 5)
      return 'Password Must be 5 digits';
    else
      return null;
  }
}
