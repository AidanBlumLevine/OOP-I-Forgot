import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appinfo.dart';
import 'assignmentwidget.dart';
import 'listcard.dart';
import 'appdata.dart';

class UpNext extends StatefulWidget {
  final AppInfo info;
  UpNext(this.info);
  @override
  UpNextState createState() => UpNextState();
}

class UpNextState extends State<UpNext> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<dynamic> comingUp = widget.info.data.comingUp();
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: comingUp.length + 2,
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
              "Coming Up",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          );
        }
        if (index - 1 == comingUp.length) {
          return Container(
            height: 8,
          );
        }
        return Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Opacity(
                opacity: (comingUp[index - 1] is EventData && comingUp[index - 1].time.isBefore(now) ||
                        comingUp[index - 1] is AssignmentData && comingUp[index - 1].due.isBefore(now))
                    ? .5
                    : 1,
                child: comingUp[index - 1] is EventData
                    ? ListCard(
                        key: Key(comingUp[index - 1].uuid),
                        onDismissed: () {
                          widget.info.data.events.remove(comingUp[index - 1]);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(comingUp[index - 1].time),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              comingUp[index - 1].name,
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),
                        name: '"${comingUp[index - 1].name}"')
                    : comingUp[index - 1] is String
                        ? Center(
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  comingUp[index - 1],
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )))
                        : comingUp[index - 1] is double
                            ? Padding(padding: EdgeInsets.only(top: comingUp[index - 1]))
                            : comingUp[index - 1] is Widget
                                ? comingUp[index - 1]
                                : AssignmentWidget(
                                    assignment: comingUp[index - 1],
                                    checkColor: Color(0xff293241),
                                    setCourseState: (() {}),
                                    alertsEnabled: true,
                                    info: widget.info,
                                  )));
      },
    );
  }
}
