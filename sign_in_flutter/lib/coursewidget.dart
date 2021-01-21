import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'appdata.dart';
import 'appinfo.dart';
import 'assignmentwidget.dart';
import 'customswitch.dart';
import 'columnbuilder.dart';

class CourseWidget extends StatefulWidget {
  CourseWidget({
    Key key,
    @required this.course,
    @required this.info,
  })  : accentColor = course.darken(course.color),
        super(key: key);
  final AppInfo info;
  final CourseData course;
  final Color accentColor;
  final Color deadColorAccent = Color(0xff212529);
  final Color deadColor = Color(0xff293241);

  CourseWidgetState createState() => CourseWidgetState();
}

class CourseWidgetState extends State<CourseWidget> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  String newName;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    controller.value = widget.course.opened ? 1 : 0;
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    int _overdue = widget.course.overdueCount();
    int _new = widget.course.newCount();

    DateTime fourDaysAgo = DateTime.now().subtract(Duration(days: 4));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.course.opened ? 12 : 20)),
        color: widget.course.enabled ? widget.course.color : widget.deadColor,
      ),
      margin: EdgeInsets.fromLTRB(6, 7, 6, 0),
      child: Column(children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 100000,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Text(
                  widget.course.name,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _overdue > 0 ? notificationDot('$_overdue', color: Colors.red) : Container(),
            _new > 0 ? notificationDot('$_new', color: Colors.blue) : Container(),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: InkWell(
                onTap: () => setState(() {
                  widget.course.opened = !widget.course.opened;
                  widget.course.opened ? controller.forward() : controller.reverse();
                }),
                child: RotationTransition(
                  turns: Tween<double>(begin: .25, end: 0).animate(controller),
                  child: Icon(
                    Icons.navigate_next_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizeTransition(
          axisAlignment: 1,
          sizeFactor: animation,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: CustomSwitch(
                  value: widget.course.enabled,
                  onChanged: (value) {
                    setState(() {
                      widget.course.enabled = value;
                    });
                  },
                  activeColor: widget.accentColor,
                  unactiveColor: widget.deadColorAccent,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 6, 0),
                child: InkWell(
                  onTap: () => setState(() {
                    addTask();
                  }),
                  child: Icon(
                    Icons.add_circle,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          axisAlignment: 1,
          sizeFactor: animation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: widget.course.enabled ? widget.accentColor : widget.deadColorAccent,
            ),
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
            child: (() {
              return Column(children: widget.course.assignmentList(updateState, widget.info));
              //ColumnBuilder(
              //   itemCount: widget.course.assignments.length,
              //   itemBuilder: (context, index) {
              //     if (widget.course.assignments[index].completed && widget.course.assignments[index].completedAt.isBefore(fourDaysAgo)) {
              //       return Container();
              //     } else {
              //       return AssignmentWidget(
              //         assignment: widget.course.assignments[index],
              //         checkColor: widget.course.enabled ? widget.course.color : widget.deadColor,
              //         setCourseState: updateState,
              //         alertsEnabled: widget.course.enabled,
              //         info: widget.info,
              //       );
              //     }
              //   },
              // );
            }()),
          ),
        ),
      ]),
    );
  }

  updateState() {
    setState(() {});
  }

  Widget notificationDot(String n, {Color color}) {
    return Container(
      margin: EdgeInsets.fromLTRB(4, 0, 0, 0),
      padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
      height: 22,
      constraints: BoxConstraints(minWidth: 22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(11)),
      ),
      child: Center(
        child: Text(
          n,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Future<void> addTask() async {
    newName = "";
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: RichText(
            text: TextSpan(
              text: 'Add a new task to ',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: widget.course.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ),
          ),
          content: TextFormField(
            initialValue: "",
            decoration: InputDecoration(hintText: 'New task'),
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if (newName == "") {
                    newName = "New task";
                  }
                  widget.course.assignments.add(new AssignmentData(333, newName, null));
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
