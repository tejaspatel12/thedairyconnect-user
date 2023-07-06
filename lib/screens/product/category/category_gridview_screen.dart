import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/models/category.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:skeleton_text/skeleton_text.dart';

class CategoryGridScreen extends StatefulWidget {
  _CategoryGridScreenState createState() => _CategoryGridScreenState();
}

class _CategoryGridScreenState extends State<CategoryGridScreen> {
  BuildContext _ctx;
  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();

  Future<List<CategoryList>> CategoryListdata;
  Future<List<CategoryList>> CategoryListfilterData;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "Search query";

  String method_call;

  _loadPref() async {
    setState(() {

      CategoryListdata = getCategoryData();
      CategoryListfilterData=CategoryListdata;
    });
  }

  //Load Data
  Future<List<CategoryList>> getCategoryData() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.BASE_INDEX, body: {
      'action': "method_category",
      "token":token,
      'category_status': "1",
    }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<CategoryList> listofusers = items.map<CategoryList>((json) {
        return CategoryList.fromJson(json);
      }).toList();
      List<CategoryList> revdata = listofusers.reversed.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<CategoryList>> _refresh1() async
  {
    setState(() {
      CategoryListdata = getCategoryData();
      CategoryListfilterData=CategoryListdata;
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
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: maincolor,
        //   title: Text(speciality,style: TextStyle(color: Colors.white),),
        //   iconTheme: IconThemeData(color: Colors.white),
        //   centerTitle: true,
        // ),
        body: Stack(
          children: <Widget>[
            FutureBuilder<List<CategoryList>>(
              future: CategoryListdata,
              builder: (context,snapshot) {
                if ((snapshot).connectionState == ConnectionState.waiting)
                {
                  return Center(
                    child: Lottie.asset(
                      'assets/loading.json',
                      repeat: true,
                      reverse: true,
                      animate: true,
                    ),

                  );
                }
                else if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //SvgPicture.asset('images/empty.svg', width: MediaQuery.of(context).size.width * 0.50,),
                        Text("No Data Available!"),
                      ],
                    ),
                  );
                }
                return GridView.count(
                  crossAxisCount: 3,
                  // crossAxisSpacing: 1.0,
                  // mainAxisSpacing: 5.0,
                  shrinkWrap: true,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 1.6),
                  scrollDirection: Axis.vertical,
                  children: snapshot.data
                      .map((data) =>
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed("/allproduct",
                              arguments: {
                                "category_id" : data.category_id,
                              }
                          );
                        },
                        child: Card(
                          color: bordercolor,
                          elevation: 0.2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              (data.category_img != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.CATEGORY_IMAGE + data.category_img, width: 90, height: 90,)):ClipOval(child: new Image.asset('images/logo.png', width: 90, height: 90,)),
                              Container(height: spacing_control),
                              Flexible(child: Text(data.category_name,overflow: TextOverflow.fade,maxLines: 1, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: textSizeSmall,))),
                            ],
                          ),
                        ),
                      ),
                  ).toList(),
                );
              },
            ),
          ],
        ),
      );
    }
  }


}
