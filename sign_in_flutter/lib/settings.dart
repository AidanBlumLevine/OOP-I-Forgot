import 'package:flutter/material.dart';
import 'about.dart';
import 'appinfo.dart';
import 'login.dart';

class Settings extends StatefulWidget {
  final AppInfo info;
  Settings(this.info);
  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[800],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          margin: EdgeInsets.fromLTRB(6, 0, 6, 0),
          padding: EdgeInsets.fromLTRB(0, 8, 0, 9),
          child: Text(
            "Settings",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 25, 0, 0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.blue[800],
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => About(loggedIn: true, info: widget.info)));
                  },
                  child: Text('About'),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
              //   child: RaisedButton(
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              //     color: Colors.blue[800],
              //     textColor: Colors.white,
              //     onPressed: () {},
              //     child: Text('Add parent'),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
              //   child: CheckboxListTile(
              //     title: Text("Enable schedule notifications"),
              //     value: false,
              //     onChanged: (newValue) {},
              //     activeColor: Colors.blue[800],
              //   ),
              // ),
              // true
              //     ? Padding(
              //         //aandroid version !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              //         padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
              //         child: CheckboxListTile(
              //           title: Text("Enable pop-up notifications"),
              //           value: false,
              //           onChanged: (newValue) {},
              //           activeColor: Colors.blue[800],
              //         ),
              //       )
              //     : Container(
              //         child: Text('Your phone does not support pop-up notifications'),
              //       ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
              //   child: CheckboxListTile(
              //     title: Text("Notifications one hour before due date"),
              //     value: false,
              //     onChanged: (newValue) {},
              //     activeColor: Colors.blue[800],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.blue[800],
                  textColor: Colors.white,
                  onPressed: () {
                    widget.info.data.save();
                    widget.info.api.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(widget.info)));
                  },
                  child: Text('Logout'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ColorFiltered(
                        child: Image.asset(
                          'assets/logos/simple.png',
                          height: 40,
                        ),
                        colorFilter: ColorFilter.mode(Colors.blue[900], BlendMode.srcIn)),
                  ),
                  Text(
                    "OPS!",
                    style: TextStyle(
                      color: Colors.blue[900],
                      letterSpacing: 1,
                      fontSize: 33,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                "I Forgot!",
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 20,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
