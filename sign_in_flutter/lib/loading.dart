import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  final method, text;
  Loading(this.method, this.text);
  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    widget.method(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
            Container(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                widget.text,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
