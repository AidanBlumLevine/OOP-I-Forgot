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

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<dynamic> comingUp = widget.info.data.comingUp();
    return Stack(
      children: [
        ListView.builder(
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
                              updateState();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Text(
                                      DateFormat('h:mm a').format(comingUp[index - 1].time),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    comingUp[index - 1].name,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                  ),
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
                                        setCourseState: updateState,
                                        updateOnComplete: false,
                                        alertsEnabled: true,
                                        info: widget.info,
                                        course: widget.info.data.courses.firstWhere((element) => element.assignments.contains(comingUp[index - 1])),
                                      )));
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.info.streak() >= 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logos/lion.png',
                          height: 30,
                          width: 50,
                        ),
                        Image.asset(
                          'assets/logos/lion.png',
                          height: 30,
                          width: 50,
                        ),
                        Image.asset(
                          'assets/logos/lion.png',
                          height: 30,
                          width: 50,
                        ),
                        Image.asset(
                          'assets/logos/lion.png',
                          height: 30,
                          width: 50,
                        ),
                        Image.asset(
                          'assets/logos/lion.png',
                          height: 30,
                          width: 50,
                        ),
                        Image.asset(
                          'assets/logos/lion.png',
                          height: 30,
                          width: 50,
                        ),
                      ],
                    )
                  : Container(),
              Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Work-O-Meter",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 2, 2, 1),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.black87),
                              ),
                              FractionallySizedBox(
                                alignment: Alignment.topCenter,
                                widthFactor: widget.info.streak(),
                                child: Container(
                                  width: 10,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.yellow),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
