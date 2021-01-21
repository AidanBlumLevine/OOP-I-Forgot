import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appinfo.dart';
import 'datetimepicker/customDateTimePicker.dart';
import 'appdata.dart';
import 'listcard.dart';

class AssignmentWidget extends StatefulWidget {
  AssignmentWidget({
    Key key,
    @required this.assignment,
    this.checkColor,
    @required this.setCourseState,
    @required this.alertsEnabled,
    @required this.info,
  }) : super(key: key);
  final AssignmentData assignment;
  final AppInfo info;
  final Color checkColor;
  final bool alertsEnabled;
  final setCourseState;
  AssignmentWidgetState createState() => AssignmentWidgetState();
}

class AssignmentWidgetState extends State<AssignmentWidget> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  bool opened = false;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListCard(
        key: Key(widget.assignment.uuid),
        dotIndicator: widget.assignment.newassignment,
        redIndicator: widget.assignment.due != null && !widget.assignment.completed && widget.assignment.due.isBefore(DateTime.now()),
        background: true,
        child: Column(
          children: [
            topHalf(),
            bottomHalf(),
          ],
        ),
        onDismissed: () {
          for (CourseData cd in widget.info.data.courses) {
            cd.assignments.remove(widget.assignment);
            widget.setCourseState();
          }
        },
        name: '"${widget.assignment.name}"');
  }

  Widget topHalf() => InkWell(
        onTap: () => setState(() {
          opened = !opened;
          opened ? controller.forward() : controller.reverse();
        }),
        child: Row(
          children: [
            Expanded(
              flex: 10000,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assignment.name,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  widget.assignment.due == null
                      ? Text("No due date")
                      : Text(
                          'Due ${DateFormat('MMM d, yyyy h:mm a').format(widget.assignment.due)}',
                        ),
                ],
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Spacer(),
            checkbox(),
          ],
        ),
      );

  Widget bottomHalf() => SizeTransition(
        axisAlignment: 1,
        sizeFactor: animation,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 3, 0, 1),
              height: 1,
              color: Color(0xffeeeeee),
            ),
            Row(
              children: [
                widget.alertsEnabled
                    ? (widget.assignment.completed ? greyedButton("alerts are disabled for complete tasks") : alertSection())
                    : greyedButton("alerts are disabled for this section"),
                Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                  child: InkWell(
                    onTap: () => setState(() {
                      changeDueDate();
                    }),
                    child: Icon(
                      Icons.settings_rounded,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget alertSection() {
    return widget.assignment.alert == null || widget.assignment.alert.time == null
        ? Container(
            height: 26,
            padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
            child: RawMaterialButton(
              onPressed: () => setState(() {
                addAlert();
              }),
              fillColor: Colors.black,
              splashColor: Colors.grey,
              constraints: BoxConstraints(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                child: Center(
                  child: Text(
                    "add alert",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          )
        : alert();
  }

  Widget greyedButton(String text) {
    return Container(
      height: 26,
      padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
      child: RawMaterialButton(
        onPressed: null,
        fillColor: Colors.black54,
        constraints: BoxConstraints(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }

  Widget checkbox() => Padding(
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: InkWell(
          onTap: () => setState(() {
            widget.assignment.completed = !widget.assignment.completed;
            if (widget.assignment.completed) {
              widget.assignment.completedAt = DateTime.now();
              widget.assignment.clearNotification();
            }
            widget.setCourseState();
          }),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                color: widget.checkColor,
              ),
              child: Container(
                margin: EdgeInsets.all(3),
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  color: Colors.white,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    color: widget.assignment.completed ? widget.checkColor : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget alert() => Row(
        children: [
          Container(
            height: 26,
            padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
            child: RawMaterialButton(
              onPressed: () => setState(() {
                editAlert();
              }),
              fillColor: Colors.black,
              splashColor: Colors.grey,
              constraints: BoxConstraints(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                child: Center(
                  child: Text(
                    'alert: ' + DateFormat('MMM d, yyyy h:mm a').format(widget.assignment.alert.time),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 26,
            width: 26,
            padding: EdgeInsets.fromLTRB(2, 3, 0, 0),
            child: RawMaterialButton(
              onPressed: () => setState(() {
                clearAlert();
              }),
              fillColor: Colors.red,
              splashColor: Colors.redAccent,
              constraints: BoxConstraints(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );

  Future<void> addAlert() async {
    CustomDatePicker.showCustomDateTimePicker(
      context,
      currentTime: DateTime.now(),
      theme: DatePickerTheme(
        containerHeight: 210.0,
        center: Text('Add alert', style: TextStyle(color: Colors.black87, fontSize: 16)),
      ),
      onConfirm: (date) {
        setState(() {
          widget.assignment.alert = AlertData(date);
          widget.assignment.addAlertNotification();
        });
      },
    );
  }

  Future<void> editAlert() async {
    CustomDatePicker.showCustomDateTimePicker(
      context,
      currentTime: widget.assignment.alert.time,
      theme: DatePickerTheme(
        containerHeight: 210.0,
        center: Text('Edit alert', style: TextStyle(color: Colors.black87, fontSize: 16)),
      ),
      onConfirm: (date) {
        setState(() {
          setState(() {
            widget.assignment.alert.time = date;
          });
          widget.assignment.clearAlertNotification();
          widget.assignment.addAlertNotification();
        });
      },
    );
  }

  clearAlert() {
    widget.assignment.clearAlertNotification();
    setState(() {
      widget.assignment.alert = null;
    });
  }

  Future<void> changeDueDate() async {
    CustomDatePicker.showCustomDateTimePicker(
      context,
      currentTime: widget.assignment.due ?? DateTime.now(),
      theme: DatePickerTheme(
        containerHeight: 210.0,
        center: Row(
          children: [
            Text('Edit due date', style: TextStyle(color: Colors.black87, fontSize: 16)),
            CupertinoButton(
              pressedOpacity: 0.3,
              padding: EdgeInsets.only(left: 16, top: 0),
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  widget.assignment.due = null;
                  widget.assignment.clearNotification();
                });
              },
            ),
          ],
        ),
      ),
      onConfirm: (date) {
        widget.assignment.due = date;
        widget.setCourseState();
        widget.assignment.clearNotification();
        widget.assignment.addNotification();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
