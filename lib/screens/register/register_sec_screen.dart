import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/models/admin.dart';
import 'package:dairy_connect/models/area.dart';
import 'package:dairy_connect/models/city.dart';
import 'package:dairy_connect/models/country.dart';
import 'package:dairy_connect/models/state.dart';
import 'package:dairy_connect/models/user.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth.dart';

class RegisterSecScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterSecScreenState();
  }
}

class RegisterSecScreenState extends State<RegisterSecScreen>{
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String user_mobile_number,user_id,user_first_name,user_last_name,user_email,area,user_pass,user_address;
  bool passwordVisible = true;

  String selectedArea = null,_Areatype=null;

  Future<List<AreaList>> AreaListdata;
  Future<List<AreaList>> AreaListfilterData;

  TextEditingController user_first_name_namecontroller = new TextEditingController();
  TextEditingController user_last_name_namecontroller = new TextEditingController();
  TextEditingController user_email_namecontroller = new TextEditingController();
  TextEditingController area_namecontroller = new TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 = new GlobalKey<RefreshIndicatorState>();


  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();

  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {

      AreaListdata = _getAreaData();
      AreaListfilterData=AreaListdata;

    });
  }


  //Area
  Future<List<AreaList>> _getAreaData() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.LOCATION,
        body:{
          'action': "show_area",
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<AreaList> listofusers = items.map<AreaList>((json) {
        return AreaList.fromJson(json);
      }).toList();
      List<AreaList> revdata = listofusers.toList();

      return revdata;
    });
  }

  Future<List<AreaList>> _refresh1() async
  {
    setState(() {
      AreaListdata = _getAreaData();
      AreaListfilterData=AreaListdata;
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
    setState(() {
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      user_mobile_number = arguments['user_mobile_number'];
      user_id = arguments['user_id'];
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        // backgroundColor: Colors.transparent,
        // backgroundColor: Colors.grey.shade50,
        body:SafeArea(
          child: (_isLoading)?Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/proccessing.json',
                repeat: true,
                reverse: true,
                animate: true,
              ),
              SizedBox(
                height: 10,
              ),
              Text("Just Minute..."),
            ],
          ):Stack(
            children: [

              NestedScrollView(
                headerSliverBuilder: (BuildContext context,
                    bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      centerTitle: true,
                      backgroundColor: maincolor,
                      title: Text("Register",
                        style: TextStyle(color: Colors.white),),
                      iconTheme: IconThemeData(color: Colors.white),

                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                    ),
                  ];
                },
                body:ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            //FNAME
                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.text,
                                onSaved: (val) {
                                  setState(() {
                                    user_first_name = val;
                                  });
                                },
                                validator: validateMiddleName,
                                decoration: const InputDecoration(

                                  // labelText: 'Enter Your Mobile Number',
                                    hintText: 'Enter Your First Name',
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
                                    contentPadding: EdgeInsets.all(15))),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                            ),

                            //LNAME
                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.text,
                                onSaved: (val) {
                                  setState(() {
                                    user_last_name = val;
                                  });
                                },
                                validator: validateMiddleName,
                                decoration: const InputDecoration(

                                  // labelText: 'Enter Your Mobile Number',
                                    hintText: 'Enter Your Last Name',
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
                                    contentPadding: EdgeInsets.all(15))),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                            ),

                            //MAIL
                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (val) {
                                  setState(() {
                                    user_email = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Enter Your Email Address',
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
                                    contentPadding: EdgeInsets.all(15))),

                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                            ),

                            //PASS
                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.visiblePassword,
                                onSaved: (val) {
                                  setState(() {
                                    user_pass = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Create Your Password',
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
                                    contentPadding: EdgeInsets.all(15))),

                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.04,
                              ),

                            //AREA
                            FutureBuilder<List<AreaList>>(
                              future: _getAreaData(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return Center(
                                      child: CircularProgressIndicator(
                                          backgroundColor: maincolor));
                                return DropdownButtonFormField(
                                    isExpanded: true,
                                    // hint: Text("Select Main Category", maxLines: 1),
                                    value: selectedArea,
                                    // validator: validatebird,
                                    items: snapshot.data.map((
                                        data) {
                                      return DropdownMenuItem(
                                        child: Text(
                                            data.area_name),
                                        value: data.area_id.toString(),
                                      );
                                    }).toList(),
                                    onChanged: (newVal) {
                                      setState(() {
                                        _refresh1();
                                        _Areatype = newVal;
                                        selectedArea = newVal;
                                      });
                                    },
                                    decoration:const InputDecoration(
                                        hintText: 'Select Area',
                                        labelStyle: TextStyle(color: maincolor),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2, color: maincolor
                                            )
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide()
                                        ),
                                        fillColor: containerboxcolor,
                                        filled: true,
                                        contentPadding: EdgeInsets.all(13),));
                              },
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                            ),

                            //ADDRESS
                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                maxLines: 4,
                                keyboardType: TextInputType.multiline,
                                onSaved: (val) {
                                  setState(() {
                                    user_address = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Enter Your Address',
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
                                    contentPadding: EdgeInsets.all(15))),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[


                  Container(
                    color: whitecolor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25,0, 25, 15),
                            child: InkWell(
                              onTap: () {

                                if(_Areatype==null)
                                {
                                  Fluttertoast.showToast(msg: "Please Select Area", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                }
                                else
                                {
                                  if (_isLoading == false) {
                                        final form = formKey.currentState;
                                        if (form.validate()) {
                                          setState(() => _isLoading = true);
                                          form.save();
                                          NetworkUtil _netUtil = new NetworkUtil();
                                          _netUtil.post(RestDatasource.LOGIN, body: {
                                            "action": "userregistersec",
                                            "user_id": user_id,
                                            "user_first_name": user_first_name,
                                            "user_last_name": user_last_name,
                                            "user_email": user_email,
                                            "user_pass": user_pass,
                                            "user_address": user_address,
                                            "area_id": _Areatype.toString(),
                                          }).then((dynamic res) async {
                                            if(res["status"] == "yes")
                                            {
                                              setState(() => _isLoading = false);
                                              Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: MediaQuery.of(context).size.width * 0.04);

                                              // FlashHelper.successBar(context, message: res['message']);
                                              Navigator.of(context).pushNamed("/registerdone",
                                                  arguments: {
                                                    "user_mobile_number" : user_mobile_number,
                                                    "user_id" : user_id,
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
                                }
                                  // FlashHelper.successBar(context, message: user_id.toString());
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
                                child: Text("Next".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                              ),
                            ),
                          ),
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

  String validateMiddleName(String value) {
    if (value.length <= 3)
      return 'Name must be greater than 3';
    else
      return null;
  }
  String validateArea(String value) {
    if (value.length == null)
      return 'Please Enter Area';
    else
      return null;
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


}
