import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sign_in_flutter/columnbuilder.dart';
import 'appdata.dart';
import 'appinfo.dart';
import 'datetimepicker/customDateTimePicker.dart';
import 'listcard.dart';

class Schedule extends StatefulWidget {
  final AppInfo info;
  Schedule(this.info);
  @override
  ScheduleState createState() => ScheduleState();
}

class ScheduleState extends State<Schedule> {
  String newName = 'New event';
  List<String> days = ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  List<String> fulldays = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<EventData> events = widget.info.data.eventsFrom(widget.info.data.currentDay);
    return Stack(
      children: [
        ListView(
          // physics: BouncingScrollPhysics(),
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
                "Schedule",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                day(7),
                day(1),
                day(2),
                day(3),
                day(4),
                day(5),
                day(6),
              ]),
            ),
            events.length > 0
                ? ColumnBuilder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return event(events[index]);
                    })
                : Center(
                    child: Column(children: [
                      Container(
                        child: Text(
                          'Nothing scheduled on ${fulldays[widget.info.data.currentDay]}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: EdgeInsets.only(top: 50),
                      ),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/logos/pigSleeping.png',
                          )),
                    ]),
                  ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              child: Icon(
                Icons.add,
                size: 30,
              ),
              backgroundColor: Colors.blue[800],
              onPressed: () {
                addEvent();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget day(int i) {
    return Expanded(
        child: Container(
      height: 45,
      child: MaterialButton(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        shape: CircleBorder(side: BorderSide(width: 1, color: Colors.blue[800], style: BorderStyle.solid)),
        color: widget.info.data.currentDay == i ? Colors.blue[800] : Colors.white,
        child: Text(days[i]),
        textColor: widget.info.data.currentDay != i ? Colors.blue[800] : Colors.white,
        elevation: 3,
        onPressed: () {
          setState(() {
            widget.info.data.currentDay = i;
          });
        },
      ),
    ));
  }

  Widget event(EventData e) {
    return ListCard(
        key: Key(e.uuid),
        onDismissed: () {
          widget.info.notifications.flutterLocalNotificationsPlugin.cancel(e.notificationID);
          widget.info.data.events.remove(e);
          updateState();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat('h:mm a').format(e.time),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  e.name,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        name: '"${e.name}"');
  }

  Future<void> addEvent() async {
    CustomDatePicker.showCustomTimePicker(
      context,
      currentTime: DateTime.now(),
      theme: DatePickerTheme(
        containerHeight: 210.0,
        center: Row(
          children: [
            Text('Edit due date', style: TextStyle(color: Colors.black87, fontSize: 16)),
          ],
        ),
        belowCenter: Padding(
          padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Event Name', hintText: 'New event'),
            initialValue: "",
            onChanged: (value) {
              newName = value;
            },
          ),
        ),
        titleHeight: 103,
      ),
      onConfirm: (date) {
        EventData ed = EventData(newName, widget.info.data.currentDay, date);
        newName = '';
        if (ed.name == '') {
          ed.name = 'New event';
        }
        setState(() {
          widget.info.data.events.add(ed);
        });
      },
    );
  }
}
