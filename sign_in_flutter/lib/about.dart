import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'main.dart';
import 'appinfo.dart';

class About extends StatelessWidget {
  final bool loggedIn;
  final AppInfo info;
  About({Key key, this.loggedIn, this.info});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Color(0xff1565c0),
        textColor: Colors.white,
        onPressed: () {
          print(loggedIn);
          if (loggedIn) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main(info)));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(info)));
          }
        },
        child: Text('Back'),
      ),
    );
  }
}
