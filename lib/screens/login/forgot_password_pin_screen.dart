import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/main.dart';
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

class ForgotPasswordPin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ForgotPasswordPinState();
  }
}

class ForgotPasswordPinState extends State<ForgotPasswordPin>{
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String rand_pincode,user_id,user_mobile_number,_pin,_newpassword,_confirmpassword;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  NetworkUtil _netUtil = new NetworkUtil();

  bool isOffline = false;
  bool done = false,pass= false , Right=false;
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


  @override
  Widget build(BuildContext context) {
    _ctx = context;
    setState(() {
      _ctx = context;
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      user_id = arguments['user_id'];
      user_mobile_number = arguments['user_mobile_number'];
      rand_pincode = arguments['rand_pincode'];
    });
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

              Right==false?
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
                      Center(child: Text("Forgot Your Password Pin",style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700,color: blackcolor, letterSpacing: 0.5),)),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.07,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Center(child: Text("Enter your pin code we send you\nvia push notification",style: TextStyle(fontSize: textSizeSMedium,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center)),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rand_pincode==""?"":rand_pincode),
                                Form(
                                  key: formKey,
                                  child: TextFormField(
                                      initialValue: null,
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      onSaved: (val) => _pin = val,
                                      onChanged: (val)
                                      {
                                        setState(() {
                                          val.length == 4?done=true:done=false;
                                          _pin = val;
                                        });
                                      },
                                      validator: (val) {
                                        return val.length <= 0
                                            ? "Please Enter New Password"
                                            : null;
                                      },
                                      decoration: const InputDecoration(

                                        // labelText: 'Enter Your Mobile Number',
                                        hintText: 'Enter Pin Code',
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
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                      Text("4 Digit otp code".toUpperCase(),style: TextStyle(fontSize: spacing_middle,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center),

                                      SizedBox(
                                        height: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          done==false?Icon(Icons.circle,size:textSizeMedium,color: titletext,):Icon(Icons.check_circle,size:textSizeMedium,color: maincolor,),
                                          SizedBox(
                                            width: spacing_control,
                                          ),
                                          Text("Exactly 4 numbers",style: TextStyle(fontSize: spacing_middle,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
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
              ):
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
                      Center(child: Text("Set Your New Password",style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700,color: blackcolor, letterSpacing: 0.5),)),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.07,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Center(child: Text("Enter your new password,\nnow this is your password",style: TextStyle(fontSize: textSizeSMedium,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center)),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Form(
                                  key: formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                          initialValue: null,
                                          obscureText: false,
                                          keyboardType: TextInputType.visiblePassword,
                                          onSaved: (val) => _newpassword = val,
                                          onChanged: (val) => _newpassword = val,
                                          validator: (val) {
                                            return val.length <= 0
                                                ? "Please Enter New Password"
                                                : val.length <= 5
                                                ? "Password length Must be 5 Letter":null;
                                          },
                                          decoration: const InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: maincolor,
                                            ),
                                            // labelText: 'Enter Your Mobile Number',
                                            hintText: 'Enter New Password',
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
                                        height: MediaQuery.of(context).size.width * 0.04,
                                      ),

                                      TextFormField(
                                          initialValue: null,
                                          obscureText: false,
                                          keyboardType: TextInputType.visiblePassword,
                                          onSaved: (val) => _confirmpassword = val,
                                          onChanged: (val) => _confirmpassword = val,
                                          validator: (val) {
                                            return val.length <= 0
                                                ? "Please Enter Confirm Password":
                                                val.length <= 5
                                                ? "Password length Must be 5 Letter":null;
                                          },
                                          decoration: const InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: maincolor,
                                            ),
                                            // labelText: 'Enter Your Mobile Number',
                                            hintText: 'Enter Confirm Password',
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

                              ],
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

              Right==false?
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

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
                                Fluttertoast.showToast(msg: "Please Wait", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 16.0);
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

                                if(rand_pincode==_pin)
                                {
                                  setState((){
                                    Right = true;
                                  });
                                  Fluttertoast.showToast(msg: "Yes, OTP Match", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: 15);
                                }
                                else
                                {
                                  Fluttertoast.showToast(msg: "Opps, OTP Not Match", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 15);
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
                    height: MediaQuery.of(context).size.width * 0.06,
                  ),

                ],
              ):
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

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
                                Fluttertoast.showToast(msg: "Please Wait", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 16.0);
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
                                        'action': "user_set_new_password",
                                        "token":token,
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
                                                                        Navigator.of(context).pushReplacementNamed("/login");
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
