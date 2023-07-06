import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> implements AuthStateListener{
  BuildContext _ctx;

  File _image = null;

  // final picker = ImagePicker();

  NetworkUtil _netUtil = new NetworkUtil();

  bool _isLoading = false;
  bool _isdataLoading = true;
  bool _isOfferLoading = true;
  // bool _isdataLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  int num = 0,securecode;
  String user_id,user_first_name,user_last_name,user_balance,user_subscription_status,user_mobile_number,user_email;
  String amt,all_recharge_offer;
  String login,order_id,keyId,keySecret;
  int _amt=500;
  int _charges = 0,_totalcharges;
  double _tax=2,_taxamt,_taxcharges;
  Razorpay _razorpay;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 = new GlobalKey<RefreshIndicatorState>();

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    _netUtil.post(RestDatasource.USER, body: {
      'action': "get_user",
      'user_id': user_id,
    }).then((dynamic res) async {
      print(res);
      setState(() {
        num = 1;
        // product_name = res[0]["product_name"];
        user_first_name = res[0]["user_first_name"];
        user_last_name = res[0]["user_last_name"];
        user_balance = res[0]["user_balance"];
        user_mobile_number = res[0]["user_mobile_number"];
        user_email = res[0]["user_email"];
        user_subscription_status = res[0]["user_subscription_status"];
        _isdataLoading = false;

      });
    });
  }

  _loadOffer() async {
    _netUtil.post(RestDatasource.RECHARGE_OFFER, body: {
      'action': "dashboard_recharge_offer",
    }).then((dynamic res) async {
      print(res);
      setState(() {
        all_recharge_offer = res["all_recharge_offer"].toString();
        print("all_recharge_offer "+all_recharge_offer);
        _isOfferLoading = false;

      });
    });
  }

  // void startTimer() {
  //   const oneSec = const Duration(seconds: 1);
  //   _timer = new Timer.periodic(
  //     oneSec,
  //         (Timer timer) {
  //       if (_start == 0) {
  //         setState(() {
  //           // _start = 10;
  //           timer.cancel();
  //         });
  //       } else {
  //         setState(() {
  //           print("_start : "+ _start.toString());
  //           _start--;
  //           _color = Color.fromARGB(
  //             //or with fromRGBO with fourth arg as _random.nextDouble(),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //           );
  //         });
  //       }
  //     },
  //   );
  // }



  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
    _loadOffer();
    navigationPage();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': keyId,
      // 'key': "rzp_test_Ii046dnmnhtIOg",
      'amount': _totalcharges.toString() + "00",
      'name': 'Dairy Connect',
      'order_id': order_id,
      'description': 'Payment',
      // 'prefill': {'contact': "7227068777", 'email': "admin@gmail.com"},
      'prefill': {'contact': user_mobile_number, 'email': user_email},
      'external': {
        'wallets': ['paytm']
      }
    };


    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Fluttertoast.showToast(
    //   msg: "SUCCESS: " + response.paymentId,);
    _netUtil.post(
        RestDatasource.PAYMENT, body: {
      "action": "paymentdone",
      "user_id": user_id,
      "razorpay_payment_id": response.paymentId,
      "payment_amt": _amt.toString(),
      "payment_type": "Online",
      "payment_status": "1",
    }).then((dynamic res) async {
      print(res["message"]);
      if (res["status"] == "yes") {
        // FlashHelper.successBar(context, message: res["message"]);
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
                                  // SvgPicture.asset('images/confirmed.svg',width: MediaQuery.of(context).size.width * 0.65,),
                                  Lottie.asset(
                                    'assets/payment_successful.json',
                                    repeat: true,
                                    reverse: false,
                                    animate: true,
                                    height: MediaQuery.of(context).size.height * 0.40,
                                  ),
                                  SizedBox(
                                    height: spacing_standard,
                                  ),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Flexible(child: Text("Payment Successful!", style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold),))
                                  ),
                                  SizedBox(
                                    height: spacing_standard,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Flexible(
                                      child: Text(
                                        "Thank you for purchasing, Your payment was successfull.",
                                        style: TextStyle(
                                          fontSize: textSizeMMedium,
                                        ),
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
                                    },
                                    child: Container(
                                      padding: EdgeInsets
                                          .fromLTRB(
                                          10, 10, 10, 15),
                                      alignment: Alignment
                                          .center,
                                      child: Text("Ohk",
                                        style: TextStyle(
                                            color: Colors.green
                                                .shade600,
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

        // Navigator.of(context).pushReplacementNamed("/member");
      }
      else {
        // FlashHelper.errorBar(context, message: res["message"]);
        setState(() => _isLoading = false);
      }
    });

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //   msg: "ERROR: " + response.code.toString() + " - " + response.message,);

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //   msg: "EXTERNAL_WALLET: " + response.walletName,);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
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

  @override
  Widget build(BuildContext context) {
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return
        login=="yes"?
        Scaffold(
        drawer: DrawerNavigationBarController(),
        backgroundColor: shadecolor,
        key: scaffoldKey,
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (BuildContext context,
                  bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    centerTitle: true,
                    backgroundColor: maincolor,
                    title: Text("Wallet",
                      style: TextStyle(color: Colors.white),),
                    iconTheme: IconThemeData(color: Colors.white),
                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                  ),
                ];
              },
              body:
              (_isdataLoading)
                  ? new Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              ):(_isOfferLoading)
                  ? new Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              )
                  :
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0),
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                    child: InkWell(
                      onTap: ()
                      {
                        // rechargeoffer
                        Navigator.of(context).pushNamed("/rechargeoffer");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                          // color: _color,
                          // color: whitecolor,
                          color: maincolor,
                        ),

                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Recharge Offer", style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  SizedBox(
                                    height: spacing_middle,
                                  ),
                                  // " Offer Available"
                                  Text(all_recharge_offer==""?"0":all_recharge_offer+" Offer Available", style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                ],
                              ),
                              Icon(Icons.card_giftcard,size:28,color: whitecolor,),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: whitecolor,
                      ),

                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Wallet Balance", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                SizedBox(
                                  height: spacing_middle,
                                ),
                                Row(
                                  children: [
                                    Text(rupeesimbol, style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                    SizedBox(
                                      width: spacing_control_half,
                                    ),
                                    Text(user_balance=="0.00"?"0.00":user_balance, style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.account_balance_wallet_outlined,size:28,color: maincolor,),

                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: whitecolor,
                      ),

                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: InkWell(
                          onTap: ()
                          {
                            Navigator.of(context).pushNamed("/paymentlist");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Balance Log", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  SizedBox(
                                    height: spacing_middle,
                                  ),
                                  Text("Credit Balance", style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                ],
                              ),
                              Icon(Icons.sync_alt,size:28,color: maincolor,),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: whitecolor,
                      ),

                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Select Amount", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            SizedBox(
                              height: spacing_middle,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: ()
                                  {
                                    setState(() {
                                      _amt = 500;
                                    });
                                  },
                                  child: _amt==500?
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0),
                                      ),
                                      color: maincolor
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                      child: Row(
                                        children: [

                                          Text(rupeesimbol, style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            width: spacing_control_half,
                                          ),
                                          Text("500", style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                        ],
                                      ),
                                    ),
                                  ):Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0),
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color: titletext,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                      child: Row(
                                        children: [

                                          Text(rupeesimbol, style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            width: spacing_control_half,
                                          ),
                                          Text("500", style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: ()
                                  {
                                    setState(() {
                                      _amt = 1000;
                                    });
                                  },
                                  child: _amt==1000?
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5.0),
                                          topRight: Radius.circular(5.0),
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular(5.0),
                                        ),
                                        color: maincolor
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                      child: Row(
                                        children: [

                                          Text(rupeesimbol, style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            width: spacing_control_half,
                                          ),
                                          Text("1000", style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                        ],
                                      ),
                                    ),
                                  ):Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0),
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color: titletext,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                      child: Row(
                                        children: [

                                          Text(rupeesimbol, style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            width: spacing_control_half,
                                          ),
                                          Text("1000", style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: ()
                                  {
                                    setState(() {
                                      _amt = 1500;
                                    });
                                  },
                                  child: _amt==1500?
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5.0),
                                          topRight: Radius.circular(5.0),
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular(5.0),
                                        ),
                                        color: maincolor
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                      child: Row(
                                        children: [

                                          Text(rupeesimbol, style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            width: spacing_control_half,
                                          ),
                                          Text("1500", style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                        ],
                                      ),
                                    ),
                                  ):Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0),
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color: titletext,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                      child: Row(
                                        children: [

                                          Text(rupeesimbol, style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            width: spacing_control_half,
                                          ),
                                          Text("1500", style: TextStyle(color: titletext,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: textSizeSMedium,
                            ),
                            Text("Enter Amount", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            SizedBox(
                              height: spacing_middle,
                            ),
                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.number,
                                onSaved: (val) {
                                  setState(() {
                                    amt = val;
                                    _amt = int.parse(amt);
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {
                                    amt = val;
                                    _amt = int.parse(amt);
                                  });
                                },
                                decoration: InputDecoration(
                                    // prefixIcon: Icon(
                                    //   Icons.currency_rupee,
                                    //   color: maincolor,
                                    // ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: SvgPicture.asset("images/pound.svg",height: 10,),
                                    ),
                                  // labelText: 'Enter Your Mobile Number',
                                    hintText: 'Amount',
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
                                    filled: true)),
                            SizedBox(
                              height: textSizeSMedium,
                            ),
                            Container(
                              // color: whitecolor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if(_amt<100)
                                        {
                                          // FlashHelper.errorBar(context, message: "Minimum deposit amount is 100 Rs");
                                        }
                                        else
                                        {
                                          setState(() {
                                            _charges = _amt*1;
                                            _taxcharges = _charges.toDouble();
                                            _taxcharges = _taxcharges/100;
                                            _charges = _taxcharges.toInt();

                                            _totalcharges = _amt + _charges;
                                          });

                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                    builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          Card(
                                                            semanticContainer: true,
                                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                                            elevation: 2.0,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(15.0),
                                                                topRight: Radius.circular(15.0),
                                                                bottomLeft: Radius.circular(0.0),
                                                                bottomRight: Radius.circular(0.0),
                                                              ),
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.all(15),
                                                              width : double.infinity, color: maincolor,
                                                              child: Column(
                                                                children: const <Widget>[
                                                                  Text("Make Payment", style: TextStyle(color: Colors.white,fontSize: 18)),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          // 24.height,
                                                          const SizedBox(
                                                            height: 10,
                                                          ),

                                                          Padding(
                                                            padding: EdgeInsets.only(left: 12, right: 12),
                                                            child: Form(
                                                              key: formKey,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [

                                                                  Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text("Amount",style: TextStyle(color: blackcolor,fontWeight: FontWeight.w500),),
                                                                      Text("£ "+_amt.toString(),style: TextStyle(color: maincolor,fontWeight: FontWeight.w600)),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 10,),
                                                                  Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text("Online Payment Charges (1%)",style: TextStyle(color: blackcolor,fontWeight: FontWeight.w500),),
                                                                      Text("£ "+_charges.toString(),style: TextStyle(color: maincolor,fontWeight: FontWeight.w600)),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 5,),
                                                                  Divider(),
                                                                  SizedBox(height: 5,),
                                                                  Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text("Total",style: TextStyle(color: blackcolor,fontWeight: FontWeight.w500),),
                                                                      Text("£ "+_totalcharges.toString(),style: TextStyle(color: redcolor,fontWeight: FontWeight.w600)),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 15,),
                                                                  Text("Note : Recharge amount is $_amt. Tax Amount not count in recharge. 1% is payment getway fees.",style: TextStyle(fontSize: 10,color: titletext),),
                                                                  SizedBox(height: 20,),

                                                                  Container(
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment
                                                                          .spaceEvenly,
                                                                      children: <Widget>[
                                                                        Expanded(
                                                                          child: InkWell(
                                                                            onTap: () {

                                                                              setState(() {
                                                                                securecode = Random().nextInt(100);
                                                                              });
                                                                              NetworkUtil _netUtil = new NetworkUtil();
                                                                              _netUtil.post(RestDatasource.ORDERID, body: {
                                                                                "securecode": securecode.toString(),
                                                                                "txnid": securecode.toString(),
                                                                                "amount": _totalcharges.toString(),
                                                                              }).then((dynamic res) async {
                                                                                if(res["status"] == "yes")
                                                                                {
                                                                                  // FlashHelper.successBar(context, message: res['message']);
                                                                                  setState(() {
                                                                                    order_id = res['order_id'];
                                                                                    keyId = res['keyId'];
                                                                                    keySecret = res['keySecret'];
                                                                                  });
                                                                                  openCheckout();

                                                                                }
                                                                                else {
                                                                                  // FlashHelper.errorBar(context, message: res['message']);
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              });
                                                                            },

                                                                            child: Container(
                                                                              decoration: const BoxDecoration(
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
                                                                              child: Text("process to pay".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                          ),

                                                          // 16.height,
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              });

                                          // openCheckout();

                                          // setState(() {
                                          //   securecode = Random().nextInt(100);
                                          // });
                                          // NetworkUtil _netUtil = new NetworkUtil();
                                          // _netUtil.post(RestDatasource.ORDERID, body: {
                                          //   "securecode": securecode.toString(),
                                          //   "txnid": securecode.toString(),
                                          //   "amount": _amt.toString(),
                                          // }).then((dynamic res) async {
                                          //   if(res["status"] == "yes")
                                          //   {
                                          //     // FlashHelper.successBar(context, message: res['message']);
                                          //     setState(() {
                                          //       order_id = res['order_id'];
                                          //       keyId = res['keyId'];
                                          //       keySecret = res['keySecret'];
                                          //     });
                                          //     openCheckout();
                                          //
                                          //   }
                                          //   else {
                                          //     // FlashHelper.errorBar(context, message: res['message']);
                                          //     Navigator.pop(context);
                                          //   }
                                          // });

                                        }

                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(5,0, 5, 0),
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
                                          child: Text("Payment Now".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //
            //     Container(
            //       // color: whitecolor,
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment
            //             .spaceEvenly,
            //         children: <Widget>[
            //           Expanded(
            //             child: InkWell(
            //               onTap: () {
            //
            //                 // FlashHelper.successBar(context, message: chackbox);
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.fromLTRB(25,15, 25, 20),
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.only(
            //                       topLeft: Radius.circular(15.0),
            //                       topRight: Radius.circular(15.0),
            //                       bottomLeft: Radius.circular(15.0),
            //                       bottomRight: Radius.circular(15.0),
            //                     ),
            //                     color: maincolor,
            //                   ),
            //                   padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            //                   alignment: Alignment.center,
            //                   child: Text("Payment Now".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ):
        SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            backgroundColor: shadecolor,
            body: ListView(
              padding: EdgeInsets.only(top: 0),
              children: [



                Padding(
                  padding: const EdgeInsets.fromLTRB(10,50, 10, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Html(
                      //   data: web_privacy_policy==null?"":web_privacy_policy,
                      // ),
                      //WEBSITE
                      Center(
                        child: Image.asset(
                          'images/logo.png',
                          // width: MediaQuery.of(context).size.width * 10,
                          width: 100,
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.03,
                      ),
                      Center(child: Text("Login Require", style: TextStyle(color: blackcolor,fontSize: textSizeLargeMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5))),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0)),
                            color: whitecolor,
                            boxShadow: [new BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3.0,
                            ),]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Text("Please login to add amount into your wallet"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //WEBSITE

                      SizedBox(
                        height: spacing_middle,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5,10, 5, 10),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed("/check");
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
                                    child: Text("Login Now".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: spacing_middle,
                      ),


                    ],
                  ),
                ),



              ],
            ),
          ),
        );
    }
  }

  // void sendPayment() async {
  //   // String upiurl = "upi://pay?pa=9998879296@okbizaxis&pn=SenderName&tn=TestingGpay&am="+finalprice.toString()+"&cu=INR";
  //   String upiurl = "upi://pay?pa=9998879296@okbizaxis&pn=SenderName&tn=TestingGpay&am=100&cu=INR";
  //   await launch(upiurl);
  // }

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