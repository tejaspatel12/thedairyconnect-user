// import 'dart:async';
// import 'dart:ui';
// import 'package:dairy_connect/data/database_helper.dart';
// import 'package:dairy_connect/data/rest_ds.dart';
// import 'package:dairy_connect/models/admin.dart';
// import 'package:dairy_connect/screens/register/register_screen_presenter.dart';
// import 'package:dairy_connect/utils/Constant.dart';
// import 'package:dairy_connect/utils/color.dart';
// import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
// import 'package:dairy_connect/utils/flash_helper.dart';
// import 'package:dairy_connect/utils/internetconnection.dart';
// import 'package:flutter/material.dart';
// import 'package:dairy_connect/utils/network_util.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../auth.dart';
//
// class RegisterThrScreen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return new RegisterThrScreenState();
//   }
// }
//
// // class RegisterThrScreenState extends State<RegisterThrScreen> implements RegisterScreenContract, AuthStateListener{
// class RegisterThrScreenState extends State<RegisterThrScreen>{
//   BuildContext _ctx;
//
//   bool _isLoading = false;
//   bool _isLoad = false;
//   final formKey = new GlobalKey<FormState>();
//   final scaffoldKey = new GlobalKey<ScaffoldState>();
//   String user_mobile_number,user_id;
//   String getlat,getlng,getlatlong,address;
//   // RegisterScreenPresenter _presenter;
//
//   TextEditingController _address_namecontroller=new TextEditingController();
//
//   static final kInitialPosition = LatLng(-33.8567844, 151.213108);
//   // PickResult selectedPlace;
//
//   SharedPreferences prefs;
//   NetworkUtil _netUtil = new NetworkUtil();
//
//   _loadPref() async {
//     prefs = await SharedPreferences.getInstance();
//     setState(() {
//
//
//     });
//   }
//
//   bool isOffline = false;
//   InternetConnection connection = new InternetConnection();
//   StreamSubscription _connectionChangeStream;
//
//   @override
//   initState() {
//     super.initState();
//     print("setstate called");
//     ConnectionStatusSingleton connectionStatus =
//     ConnectionStatusSingleton.getInstance();
//     connectionStatus.initialize();
//     _connectionChangeStream =
//         connectionStatus.connectionChange.listen(connectionChanged);
//     // startTime();
//   }
//
//   void connectionChanged(dynamic hasConnection) {
//     setState(() {
//       isOffline = !hasConnection;
//       //print(isOffline);
//     });
//   }
//
//   // OTPScreenState() {
//   //   _presenter = new RegisterScreenPresenter(this);
//   //   var authStateProvider = new AuthStateProvider();
//   //   authStateProvider.subscribe(this);
//   // }
//   //
//   // @override
//   // onAuthStateChanged(AuthState state) {
//   //   if (state == AuthState.LOGGED_IN)
//   //     Navigator.of(_ctx).pushReplacementNamed("/bottomhome");
//   // }
//
//   // LocationResult _pickedLocation;
//
//   @override
//   Widget build(BuildContext context) {
//     _ctx = context;
//     setState(() {
//       final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
//       user_mobile_number = arguments['user_mobile_number'];
//       user_id = arguments['user_id'];
//     });
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Location picker'),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Builder(builder: (context) {
//               return Container(
//                 color: shadecolor,
//                 alignment: Alignment.center,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     selectedPlace!=null?
//                     Column(
//                       children: [
//                         Lottie.asset(
//                           'assets/location.json',
//                           repeat: true,
//                           reverse: true,
//                           animate: true,
//                           height: MediaQuery.of(context).size.height * 0.20,
//                         ),
//                         Text("Get Location Successfully",style: TextStyle(fontSize: textSizeMedium,color: maincolor),),
//                       ],
//                     ):InkWell(
//                       onTap: () async {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return PlacePicker(
//                                 apiKey: "AIzaSyAQfo7QS7ZPiUdTiXTHgGmtmOA7k1FTUKE",
//                                 initialPosition: kInitialPosition,
//                                 useCurrentLocation: true,
//                                 selectInitialPosition: true,
//
//                                 //usePlaceDetailSearch: true,
//                                 onPlacePicked: (result) {
//                                   selectedPlace = result;
//                                   Navigator.of(context).pop();
//                                   setState(() {
//                                     selectedPlace = result;
//                                     _address_namecontroller.text=selectedPlace.formattedAddress;
//                                   });
//                                 },
//                               );
//                             },
//                           ),
//                         );
//
// //                         LocationResult result = await showLocationPicker(
// //                           context, 'AIzaSyAQfo7QS7ZPiUdTiXTHgGmtmOA7k1FTUKE',
// //                           initialCenter: LatLng(21.1702, 72.8311),
// //                           automaticallyAnimateToCurrentLocation: true,
// // //                      mapStylePath: 'assets/mapStyle.json',
// //                           myLocationButtonEnabled: true,
// //                           layersButtonEnabled: true,
// //                           // countries: ['AE', 'NG']
// //
// //                           //resultCardAlignment: Alignment.bottomCenter,
// //                         );
//                         // setState(() {
//                         //   result = _pickedLocation;
//                         // });
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(5.0),
//                             topRight: Radius.circular(5.0),
//                             bottomLeft: Radius.circular(5.0),
//                             bottomRight: Radius.circular(5.0),
//                           ),
//                           color: maincolor,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
//                           child: new Text(
//                             "Pick Location".toUpperCase(),
//                             style: new TextStyle(
//                               color: whitecolor,
//                               fontSize: 14.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // SizedBox(height: 15),
//                     //
//                     // _pickedLocation!=null?SizedBox():Card(
//                     //   margin: EdgeInsets.all(10),
//                     //   child: Container(
//                     //       padding: EdgeInsets.all(10),
//                     //       child: Text(_pickedLocation.toString(),
//                     //         style: GoogleFonts.roboto(color: Colors.black), textAlign: TextAlign.center,)),
//                     // ),
//                   ],
//                 ),
//               );
//             }),
//
//             selectedPlace==null?SizedBox():Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(20.0),
//                         bottomRight: Radius.circular(5.0),
//                         topLeft: Radius.circular(20.0),
//                         bottomLeft: Radius.circular(5.0)),
//                     color: whitecolor,
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: MediaQuery.of(context).size.width * 0.06,
//                       ),
//
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
//                         child: Form(
//                           key: formKey,
//                           child: Column(
//                             children: [
//                               TextFormField(
//                                   initialValue: null,
//                                   obscureText: false,
//                                   controller: _address_namecontroller,
//                                   keyboardType: TextInputType.multiline,
//                                   maxLines: 5,
//                                   validator: validateAddress,
//                                   onSaved: (val) {
//                                     setState(() {
//                                       address = val;
//                                     });
//                                   },
//                                   decoration: InputDecoration(
//                                       hintText: 'Enter Your Address',
//                                       labelStyle: TextStyle(color: maincolor),
//                                       focusedBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               width: 2, color: maincolor
//                                           )
//                                       ),
//                                       border: OutlineInputBorder(
//                                           borderSide: BorderSide()
//                                       ),
//                                       fillColor: Colors.white,
//                                       filled: true,
//                                       contentPadding: EdgeInsets.all(15))),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(
//                         height: MediaQuery.of(context).size.width * 0.01,
//                       ),
//
//                       Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment
//                               .spaceEvenly,
//                           children: <Widget>[
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.fromLTRB(25,15, 25, 15),
//                                 child: InkWell(
//                                   onTap: () {
//                                     // if (_isLoad == false) {
//                                     //   final form = formKey.currentState;
//                                     //   if (form.validate()) {
//                                     //     setState(() => _isLoad = true);
//                                     //     form.save();
//                                     //
//                                     //     _presenter.doLogin(user_id,address,_pickedLocation.latLng.toString());
//                                     //   }
//                                     // }
//
//                                     if (_isLoading == false) {
//                                       final form = formKey.currentState;
//                                       if (form.validate()) {
//                                         setState(() => _isLoading = true);
//                                         form.save();
//                                         NetworkUtil _netUtil = new NetworkUtil();
//                                         _netUtil.post(RestDatasource.LOGIN, body: {
//                                           "action": "userregisterthread",
//                                           "user_id": user_id,
//                                           // "user_id": user_id,
//                                           "user_address": address,
//                                           "user_placeid":  selectedPlace.placeId.toString(),
//                                           // "user_latlng":  selectedPlace.latLng.toString(),
//                                         }).then((dynamic res) async {
//                                           if(res["status"] == "yes")
//                                           {
//                                             setState(() => _isLoading = false);
//                                             // FlashHelper.successBar(context, message: res['message']);
//                                             Navigator.of(context).pushNamed("/registerdone");
//                                           }
//                                           else {
//                                             setState(() => _isLoading = false);
//                                             // FlashHelper.errorBar(context, message: res['message']);
//                                           }
//                                         });
//                                       }
//                                     }
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(5.0),
//                                         topRight: Radius.circular(5.0),
//                                         bottomLeft: Radius.circular(5.0),
//                                         bottomRight: Radius.circular(5.0),
//                                       ),
//                                       color: maincolor,
//                                     ),
//                                     padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
//                                     alignment: Alignment.center,
//                                     child: Text("Next".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//
//                     ],
//                   ),
//                 ),
//
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // @override
//   // void onLoginError(String errorTxt) {
//   //   FlashHelper.errorBar(context, message: errorTxt);
//   //   setState(() => _isLoading = false);
//   // }
//   //
//   // @override
//   // void onLoginSuccess(Admin user) async {
//   //   //_showSnackBar(user.toString());
//   //   setState(() => _isLoading = false);
//   //   var db = new DatabaseHelper();
//   //   await db.saveUser(user);
//   //   var authStateProvider = new AuthStateProvider();
//   //   authStateProvider.notify(AuthState.LOGGED_IN);
//   // }
//
//   String validateAddress(String value) {
//     if (value.length <= 3)
//       return 'Name must be greater than 3';
//     else
//       return null;
//   }
//
// }
