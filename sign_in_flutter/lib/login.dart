import 'package:flutter/material.dart';
import 'about.dart';
import 'appinfo.dart';
import 'loading.dart';

class Login extends StatefulWidget {
  final AppInfo info;
  Login(this.info);
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: [
            Transform.rotate(
              angle: -.2,
              child: Transform.scale(
                scale: 2,
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: FractionallySizedBox(heightFactor: .4, widthFactor: 2),
                  color: Color(0xff1565c0),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: FractionallySizedBox(heightFactor: .8)),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Image.asset(
                              'assets/logos/simple.png',
                              height: 40,
                            ),
                          ),
                          Text(
                            "OPS!",
                            style: TextStyle(
                              color: Colors.white,
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
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(child: FractionallySizedBox(heightFactor: 1)),
                Flexible(child: FractionallySizedBox(heightFactor: 1)),
                Padding(
                  padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Color(0xff1565c0),
                    textColor: Colors.white,
                    onPressed: () {
                      widget.info.api.signIn().then((loggedIn) {
                        if (loggedIn) {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => Loading(widget.info.postLogin, "updating courses")));
                        }
                      });
                    },
                    child: Text('Login'),
                  ),
                ),
                Flexible(child: FractionallySizedBox(heightFactor: .025)),
                Padding(
                  padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Color(0xff1565c0),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => About(loggedIn: false, info: widget.info)));
                    },
                    child: Text('About'),
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
