import 'package:flutter/material.dart';
import 'appinfo.dart';
import 'coursewidget.dart';

class Home extends StatefulWidget {
  final AppInfo info;
  Home(this.info);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.info.data.courses.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
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
              "Classes and tasks",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          );
        }
        if (index - 1 == widget.info.data.courses.length) {
          return Column(
            children: [
              Container(
                height: 8,
              ),
              Text(
                "When you join classes with your google",
                style: TextStyle(fontSize: 13, color: Color(0x99000000)),
              ),
              Text(
                "account, they will appear here.",
                style: TextStyle(fontSize: 13, color: Color(0x99000000)),
              ),
              Container(
                height: 8,
              ),
            ],
          );
        }
        return CourseWidget(
          course: widget.info.data.courses[index - 1],
          info: widget.info,
        );
      },
    );
  }
}
