import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'main.dart';
import 'appinfo.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final bool loggedIn;
  final AppInfo info;
  About({Key key, this.loggedIn, this.info});
  @override
  Widget build(BuildContext context) {
    print(this.loggedIn);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.fromLTRB(0, 8, 0, 9),
              child: Text(
                "About",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 25, 0, 0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "OOPS! I Forgot!", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            " is an app targeted at middle school students to help keep track of classes, assignments and schedules during online and in-person learning. Just sign in with your google account and "),
                    TextSpan(text: "OOPS! I Forgot!", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " instantly "),
                    TextSpan(text: "imports all of your google classroom courses and assignments", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ". It even knows the due dates so it can remind you to turn your work in!"),
                  ],
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: GestureDetector(
                child: Text(
                  "LINK",
                  style: TextStyle(
                    color: Colors.blue[800],
                  ),
                ),
                onTap: () => launch("https://winditions.com/"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text("See youtube link for some brief instructions"),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 25, 0, 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Color(0xff1565c0),
                    textColor: Colors.white,
                    onPressed: () {
                      if (loggedIn) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main(info)));
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(info)));
                      }
                    },
                    child: Text('Back'),
                  ),
                ),
              ],
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
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Designed and created by Aidan Blum Levine",
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 13,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text(
                      "If your keyboard is not appearing when trying to type, please restart this app",
                      style: TextStyle(
                        color: Colors.black26,
                        fontSize: 10,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
