import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class InternetConnection {
  Widget nointernetconnection()
  {
    return Scaffold(
        appBar: null,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Lottie.asset('assets/noconnection.json'),
            ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No Internet",style: TextStyle(fontSize: 20.0),),
              )
            ],
          ),
        )
    );
  }
}