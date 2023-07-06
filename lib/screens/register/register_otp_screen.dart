import 'dart:async';
import 'dart:ui';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
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

class RegisterOTPScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterOTPScreenState();
  }
}

class RegisterOTPScreenState extends State<RegisterOTPScreen>{
  BuildContext _ctx;


  bool _isLoading = false;
  bool _isLoad = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String user_id,_otpcode,user_mobile_number,new_last_id;
  bool passwordVisible = true;

  String deliveryboy_token="";
  NetworkUtil _netUtil = new NetworkUtil();
  String app_otp;
  bool first=false;

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
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    setState(() {
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      // last_id = arguments['last_id'];
      user_id = arguments['user_id'];
      user_mobile_number = arguments['user_mobile_number'];
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        // backgroundColor: whitecolor,
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
                      // Container(
                      //   // color: maincolor,
                      //   child: _isLoading==true?Image.asset(
                      //     'images/logo.png',
                      //     width: MediaQuery.of(context).size.width * 90,
                      //     height: MediaQuery.of(context).size.height * 0.50,
                      //   ):Image.network(RestDatasource.MORE_IMAGE + app_otp,
                      //     width: MediaQuery.of(context).size.width * 90,
                      //     height: MediaQuery.of(context).size.height * 0.50,
                      //   ),
                      // ),

                      SvgPicture.asset("images/sms.svg",height: MediaQuery.of(context).size.width * 0.30,),


                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.09,
                      ),
                      Center(child: Text("Enter the Verification Code",style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700,color: blackcolor, letterSpacing: 0.5),)),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.07,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Center(child: Text("Enter the 6 digit number that we send\nto +91 "+user_mobile_number,style: TextStyle(fontSize: textSizeSMedium,color: titletext, letterSpacing: 0.6,),textAlign: TextAlign.center)),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.08,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                                topLeft: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0)),
                            color: whitecolor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
                            child: Form(
                              key: formKey,
                              child: PinCodeFields(
                                length: 6,
                                // borderWidth: 2.0,
                                onChange: (val) {
                                  setState(() {
                                    _otpcode = val;
                                  });
                                },
                                keyboardType: TextInputType.number,
                                borderColor: maincolor,
                                onComplete: (result) {
                                  // Your logic with code
                                  print(result);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // SizedBox(
                      //   height: MediaQuery.of(context).size.width * 0.05,
                      // ),
                      // InkWell(
                      //   onTap: () {
                      //     FlashHelper.successBar(context, message: "last_id :"+last_id);
                      //   },
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.only(
                      //         topLeft: Radius.circular(5.0),
                      //         topRight: Radius.circular(5.0),
                      //         bottomLeft: Radius.circular(5.0),
                      //         bottomRight: Radius.circular(5.0),
                      //       ),
                      //       color: maincolor,
                      //     ),
                      //     padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                      //     alignment: Alignment.center,
                      //     child: Text("code".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                      //   ),
                      // ),

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
                                      "action": "userotpregister",
                                      // "last_id": first==false?last_id:new_last_id,
                                      "user_id": user_id,
                                      "otp": _otpcode,
                                    }).then((dynamic res) async {
                                      if(res["status"] == "yes")
                                      {
                                        setState(() => _isLoading = false);
                                        // FlashHelper.successBar(context, message: res['message']);
                                        Navigator.of(context).pushReplacementNamed("/registersec",
                                            arguments: {
                                              "user_mobile_number" : user_mobile_number,
                                              "user_id" : user_id,
                                            });
                                      }
                                      else {
                                        setState(() => _isLoading = false);
                                        // FlashHelper.errorBar(context, message: res['message']);
                                      }
                                    });
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
                    height: MediaQuery.of(context).size.width * 0.04,
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
