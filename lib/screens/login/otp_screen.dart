import 'dart:async';
import 'dart:ui';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/models/admin.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/utils/network_util.dart';

import '../../auth.dart';
import 'login_screen_presenter.dart';

class OTPScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new OTPScreenState();
  }
}

class OTPScreenState extends State<OTPScreen> implements LoginScreenContract, AuthStateListener {
  BuildContext _ctx;

  Timer _timer,_newtimer;
  int _start = 30;
  int _newstart = 60;

  bool _isLoading = true;
  bool _isLoad = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String last_id, user_id,_otpcode,user_mobile_number,new_last_id,user_token;
  bool passwordVisible = true;
  LoginScreenPresenter _presenter;
  bool first=false;
  bool sec=false;
  int last_int_id;

  NetworkUtil _netUtil = new NetworkUtil();

  String app_otp;
  int us=0;

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
    startTimer();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            // startNewTimer();
          });
        } else {
          setState(() {
            print("_start : "+ _start.toString());
            _start--;
          });
        }
      },
    );
  }

  void startNewTimer() {
    const oneSec = const Duration(seconds: 1);
    _newtimer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_newstart == 0) {
          setState(() {
            // _start = 10;
            timer.cancel();
          });
        } else {
          setState(() {
            print("_start : "+ _newstart.toString());
            _newstart--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    // timer?.cancel();
    _timer.cancel();
    _newtimer.cancel();
    // startTimer();
    // startNewTimer();
  }

  OTPScreenState() {
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
    _ctx = context;
    setState(() {
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      last_id = arguments['last_id'];
      user_id = arguments['user_id'];
      user_mobile_number = arguments['user_mobile_number'];
      user_token = arguments['user_token'];
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        // backgroundColor: whitecolor,
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

                      SvgPicture.asset("images/sms.svg",height: MediaQuery.of(context).size.width * 0.30,),
                        //   :
                        // Image.network(RestDatasource.MORE_IMAGE + app_otp,
                        //     width: MediaQuery.of(context).size.width * 0.30,
                        //   ),

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


                  _isLoad==true?
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

                                if(_otpcode ==null)
                                {
                                  // FlashHelper.errorBar(context, message: "Please Enter OTP Code");
                                }
                                else if(_otpcode.length != 6)
                                {
                                  // FlashHelper.errorBar(context, message: "Please Enter OTP Code");
                                }
                                else
                                {
                                  if (_isLoad == false) {
                                    final form = formKey.currentState;
                                    if (form.validate()) {
                                      setState(() => _isLoad = true);
                                      form.save();
                                      if(first==false)
                                      {
                                        setState(() => _isLoad = false);
                                        _presenter.doLogin(user_id,_otpcode,user_token);
                                      }else
                                      {
                                        setState(() => _isLoad = false);
                                        _presenter.doLogin(user_id,_otpcode,user_token);

                                      }

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
                    height: MediaQuery.of(context).size.width * 0.03,
                  ),
                  first==false?
                  Container(
                    child: _start != 0?Center(child: Text("Resend Otp code in "+" "+_start.toString()+" sec",style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w400,color: maincolor, letterSpacing: 0.5),)):
                    InkWell(
                      onTap: ()
                      {
                        first = true;
                        if (_isLoad == false) {
                          setState(() => _isLoad = true);
                          NetworkUtil _netUtil = new NetworkUtil();
                          _netUtil.post(RestDatasource.LOGIN, body: {
                            "action": "resendotp",
                            "user_mobile_number": user_mobile_number,
                            "user_id": user_id,
                          }).then((dynamic res) async {
                            if(res["status"] == "yes")
                            {
                              // FlashHelper.successBar(context, message: res['message']);
                              setState(() => _isLoad = false);
                            }
                            else {
                              setState(() => _isLoad = false);
                              //FlashHelper.errorBar(context, message: res['message']);
                            }
                          });
                        }
                      },
                        child: Center(child: Text("Resend Otp".toUpperCase(),style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w400,color: maincolor, letterSpacing: 0.5),))
                    ),
                  ):
                  Container(
                    child: _newstart != 0?Center(child: Text("Resend Otp code in "+" "+_newstart.toString()+" sec",style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w400,color: maincolor, letterSpacing: 0.5),)):
                    InkWell(
                        onTap: ()
                        {
                          setState(() {
                            startTimer();
                          });
                          if (_isLoad == false) {
                            setState(() => _isLoad = true);
                            NetworkUtil _netUtil = new NetworkUtil();
                            _netUtil.post(RestDatasource.LOGIN, body: {
                              "action": "resendotp",
                              "user_mobile_number": user_mobile_number,
                              "user_id": user_id,
                            }).then((dynamic res) async {
                              if(res["status"] == "yes")
                              {
                                // FlashHelper.successBar(context, message: res['message']);
                                setState(() => _isLoad = false);
                              }
                              else {
                                setState(() => _isLoad = false);
                                //FlashHelper.errorBar(context, message: res['message']);
                              }
                            });
                          }
                        },
                        child: Center(child: Text("Resend Otp".toUpperCase(),style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w400,color: maincolor, letterSpacing: 0.5),))
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
}
