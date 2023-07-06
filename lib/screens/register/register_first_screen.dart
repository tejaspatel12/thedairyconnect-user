import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

class RegisterFirstScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterFirstScreenState();
  }
}

class RegisterFirstScreenState extends State<RegisterFirstScreen>{
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _mobile_numbers;
  bool passwordVisible = true;
  String app_login;
  String deliveryboy_token="";

  bool done = false;

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  NetworkUtil _netUtil = new NetworkUtil();


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


                      Image.asset(
                        'images/logo.png',
                        width: MediaQuery.of(context).size.width * 0.30,
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.09,
                      ),
                      Center(child: Text("Add Your Phone Number",style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700,color: blackcolor, letterSpacing: 0.5),)),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.07,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Form(
                                  key: formKey,
                                  child: TextFormField(
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
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                      Text("Your phone number must contain".toUpperCase(),style: TextStyle(fontSize: spacing_middle,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center),

                                      SizedBox(
                                        height: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          done==false?Icon(Icons.circle,size:textSizeMedium,color: titletext,):Icon(Icons.check_circle,size:textSizeMedium,color: maincolor,),
                                          const SizedBox(
                                            width: spacing_control,
                                          ),
                                          const Text("Exactly 10 numbers",style: TextStyle(fontSize: spacing_middle,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center),
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
              ),


              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  // Container(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment
                  //         .spaceEvenly,
                  //     children: <Widget>[
                  //       Expanded(
                  //         child: Padding(
                  //           padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                  //           child: InkWell(
                  //             onTap: () {
                  //               FlashHelper.errorBar(context, message: "Click");
                  //             },
                  //             child: Container(
                  //               decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.only(
                  //                   topLeft: Radius.circular(5.0),
                  //                   topRight: Radius.circular(5.0),
                  //                   bottomLeft: Radius.circular(5.0),
                  //                   bottomRight: Radius.circular(5.0),
                  //                 ),
                  //                 color: maincolor,
                  //               ),
                  //               padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                  //               alignment: Alignment.center,
                  //               child: Text("Next".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

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
                                if (_isLoading == false) {
                                  final form = formKey.currentState;
                                  if (form.validate()) {
                                    setState(() => _isLoading = true);
                                    form.save();
                                    NetworkUtil _netUtil = new NetworkUtil();
                                    _netUtil.post(RestDatasource.LOGIN, body: {
                                      "action": "userregister",
                                      "user_mobile_number": _mobile_numbers,
                                    }).then((dynamic res) async {
                                      if(res["status"] == "yes")
                                      {
                                        setState(() => _isLoading = false);
                                        // FlashHelper.successBar(context, message: res['message']);
                                        // FlashHelper.successBar(context, message: res['message'].toString());
                                        Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                        Navigator.of(context).pushReplacementNamed("/registersec",
                                            arguments: {
                                              // "last_id" : res["last_id"].toString(),
                                              "user_id" : res["user_id"].toString(),
                                              "user_mobile_number" : _mobile_numbers,
                                            });
                                      }
                                      else {
                                        setState(() => _isLoading = false);
                                        Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                        // FlashHelper.errorBar(context, message: res['message']);
                                      }
                                    });
                                  }
                                }
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
                      const Text("I accept the ",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: titletext, letterSpacing: 0.5),),
                      InkWell(
                        onTap: ()
                        {
                          Navigator.of(context).pushNamed("/termscondition");
                        },
                          child: const Text("Terms and Conditions",style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600,color: maincolor, letterSpacing: 0.5),)
                      ),
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
    if (value.length != 10) {
      return 'Mobile Number must be of 10 digit';
    } else {
      return null;
    }
  }
}
