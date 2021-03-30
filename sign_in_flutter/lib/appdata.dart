import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import 'appinfo.dart';
import 'assignmentwidget.dart';
import 'notifications.dart';

class AppData {
  DateTime lastCourseFetch;
  double streak;
  List<CourseData> courses = [];
  List<EventData> events = [];
  String email;
  File saveTo;
  Notifications notifications;
  int currentPage = 1;
  int currentDay = 1;
  AppData(String email) {
    this.email = email;
    lastCourseFetch = null;
    courses.add(CourseData(333, "General Tasks", Colors.blue[800]));
  }

  AppData.fromJson(Map<String, dynamic> json) {
    lastCourseFetch = DateTime.parse(json['last_fetch']);
    courses = List<CourseData>.from(json['courses'].map((i) => CourseData.fromJson(i)));
    events = List<EventData>.from((json['events'] ?? []).map((i) => EventData.fromJson(i)));
    streak = json['streak'].toDouble() ?? 0;
    currentPage = json['currentPage'];
    if (currentPage == 3) {
      currentPage = 1;
    }
  }

  Map toJson() => {
        'last_fetch': lastCourseFetch.toIso8601String(),
        'email': email,
        'currentPage': currentPage,
        'courses': courses.map((e) => e.toJson()).toList(),
        'events': events.map((e) => e.toJson()).toList(),
        'streak': streak,
      };

  save() {
    print('save');
    for (EventData e in events) {
      if (e.notificationID == 0) {
        e.notificationID = Random().nextInt(2147483647);
        notifications.notifyScheduled(e.notificationID, "${e.name}", 'starting now', '${e.notificationID}', e.time, e.day);
      }
    }
    saveTo.writeAsString(jsonEncode(this));
  }

  sortEvents() {
    events.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
  }

  explodeList(List<CourseData> l) {
    return [
      for (CourseData o in l)
        {
          o.toJson(),
        }
    ];
  }

  List<Color> colors = [
    Color(0xFFef476f),
    Color(0xFF118ab2),
    Color(0xeeeec055),
    Color(0xFF06d6a0),
    Color(0xFF073b4c),
    Color(0xFF33691e),
    Color(0xFFbc5100),
    Color(0xFF54478c),
  ];
  List shuffle(List items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  Color pickNewColor() {
    return colors[courses.length % colors.length];
  }

  int overdueCount() {
    int overdue = 0;
    for (CourseData c in courses) {
      overdue += c.overdueCount();
    }
    return overdue;
  }

  List<dynamic> comingUp() {
    List<dynamic> today = [];
    List<dynamic> thisWeek = [];
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);

    for (CourseData c in courses) {
      for (AssignmentData a in c.assignments) {
        if (a.due != null && a.completed == false && a.due.isAfter(now) && a.due.isBefore(now.add(Duration(days: 1)))) {
          today.add(a);
        }
        if (a.due != null && a.completed == false && a.due.isAfter(now.add(Duration(days: 1))) && a.due.isBefore(now.add(Duration(days: 7)))) {
          thisWeek.add(a);
        }
      }
    }
    for (EventData e in events) {
      if (e is EventData) {
        e.time = DateTime(now.year, now.month, now.day, e.time.hour, e.time.minute);
      }
      if (e.day == DateTime.now().weekday) {
        today.add(e);
      }
    }
    today.sort((a, b) => (a is EventData ? a.time : a.due).isAfter(b is EventData ? b.time : b.due) ? 1 : -1);
    thisWeek.sort((a, b) => (a is EventData ? a.time : a.due).isAfter(b is EventData ? b.time : b.due) ? 1 : -1);
    today.insert(0, "Today");
    thisWeek.insert(0, "Due Later This Week");
    if (today.length == 1) {
      today.clear();
    }
    if (thisWeek.length == 1) {
      thisWeek.clear();
    }
    if (today.length == 0 && thisWeek.length == 0) {
      today.add(100.0);
      today.add("You're all set for");
      today.add("the next week");
      today.add(
        Padding(
          padding: EdgeInsets.all(20),
          child: Image.asset(
            'assets/logos/party.png',
          ),
        ),
      );
    }
    today.addAll(thisWeek);
    return today;
  }

  List<EventData> eventsFrom(int i) {
    List<EventData> list = [];
    for (EventData e in events) {
      if (e.day == i) {
        list.add(e);
      }
    }
    return list;
  }
}

class CourseData {
  int id;
  String name;
  Color color;
  bool enabled = true, opened = true;
  List<AssignmentData> assignments = [];
  CourseData(this.id, this.name, this.color);

  CourseData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        enabled = json['enabled'],
        opened = json['opened'],
        assignments = List<AssignmentData>.from(json['assignments'].map((i) => AssignmentData.fromJson(i))),
        color = Color((json['color'] as int) + 0x00000000);

  Map toJson() => {
        'id': id,
        'name': name,
        'enabled': enabled,
        'opened': opened,
        'assignments': assignments.map((e) => e.toJson()).toList(),
        'color': color.value,
      };

  int overdueCount() {
    DateTime now = DateTime.now();
    return assignments.fold(
        0, (prev, element) => prev + (element.due != null && !element.completed && element.due.isBefore(now) && !element.completed ? 1 : 0));
  }

  int newCount() {
    return assignments.fold(0, (prev, element) => prev + ((element.newassignment && !element.completed) ? 1 : 0));
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  int compareAssignments(AssignmentData a, AssignmentData b) {
    // if (a.completed) {
    //   if (b.completed) {
    //     return a.completedAt.isBefore(b.completedAt) ? -1 : 1;
    //   }
    // }
    if (a.due == null) {
      if (b.due == null) {
        return 0;
      }
      return 1;
    }
    if (b.due == null) {
      return -1;
    }
    return a.due.isBefore(b.due) ? -1 : 1;
  }

  List<Widget> assignmentList(var _setCourseState, var info) {
    List<Widget> top = [], bottom = [];
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    DateTime lastWeek = DateTime.now().subtract(Duration(days: 7));
    if (assignments == null || assignments.length == 0) {
      return [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logos/lion.png',
                  height: 30,
                ),
                Padding(padding: const EdgeInsets.only(left: 10)),
                Text(
                  "You're all set here",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
                Padding(padding: const EdgeInsets.only(left: 10)),
                Image.asset(
                  'assets/logos/lion.png',
                  height: 30,
                ),
              ],
            ),
          ),
        )
      ];
    }
    for (AssignmentData a in assignments) {
      if (!a.completed || a.completedAt.isAfter(yesterday)) {
        top.add(
          AssignmentWidget(
            assignment: a,
            checkColor: enabled ? color : Color(0xff293241),
            setCourseState: _setCourseState,
            alertsEnabled: enabled,
            info: info,
          ),
        );
      } else if (a.completedAt.isAfter(lastWeek)) {
        bottom.add(
          AssignmentWidget(
            assignment: a,
            checkColor: enabled ? color : Color(0xff293241),
            setCourseState: _setCourseState,
            alertsEnabled: enabled,
            info: info,
          ),
        );
      }
    }
    top.sort((a, b) => compareAssignments((a as AssignmentWidget).assignment, (b as AssignmentWidget).assignment));
    if (bottom.length > 0) {
      top.add(
        Padding(
          padding: EdgeInsets.only(top: 6, bottom: 2),
          child: Center(
            child: Column(
              children: [
                Text("Completed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                Text("completed tasks disappear after a week", style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ),
      );
      top.addAll(bottom);
    }
    return top;
  }
}

class EventData {
  int notificationID = 0;
  String name;
  int day;
  DateTime time;
  String uuid;

  EventData(this.name, this.day, this.time) : this.uuid = Uuid().v4();

  EventData.fromJson(Map<String, dynamic> json)
      : notificationID = json['notificationID'],
        name = json['name'],
        time = json['time'] == null ? null : DateTime.parse(json['time']),
        uuid = json['uuid'],
        day = json['day'];

  Map toJson() => {
        'notificationID': notificationID,
        'name': name,
        'day': day,
        'uuid': uuid,
        'time': time != null ? time.toIso8601String() : null,
      };
}

class AssignmentData {
  int id, notificationID = 0;
  String name;
  bool completed = false, newassignment = true;
  DateTime due, createdAt, completedAt;
  AlertData alert;
  String uuid;
  AppInfo info;

  AssignmentData(this.id, this.name, this.due) : this.uuid = Uuid().v4();

  AssignmentData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        notificationID = json['notificationID'] ?? 0,
        name = json['name'],
        newassignment = json['newassignment'],
        completed = json['completed'],
        due = json['due'] == null ? null : DateTime.parse(json['due']),
        createdAt = json['createdAt'] == null ? null : DateTime.parse(json['createdAt']),
        completedAt = json['completedAt'] == null ? null : DateTime.parse(json['completedAt']),
        alert = AlertData.fromJson(json['alert']);

  Map toJson() => {
        'id': id,
        'name': name,
        'completed': completed,
        'newassignment': newassignment,
        'due': due != null ? due.toIso8601String() : null,
        'createdAt': createdAt != null ? createdAt.toIso8601String() : null,
        'completedAt': completedAt != null ? completedAt.toIso8601String() : null,
        'alert': alert != null ? alert.toJson() : null,
        'notificationID': notificationID,
      };

  addNotification() {
    if (due != null && notificationID == 0 && due.isAfter(DateTime.now().add(Duration(hours: 1, seconds: 1)))) {
      notificationID = Random().nextInt(2147483647);
      tz.TZDateTime time = tz.TZDateTime.from(due.subtract(Duration(hours: 1)), tz.getLocation('US/Eastern'));
      info.notifications.notify(notificationID, '$name is due in one hour!', 'make sure it is ${id == 333 ? "complete" : "turned in"} by that time',
          '$notificationID', time);
    }
  }

  clearNotification() {
    if (notificationID != 0) {
      info.notifications.flutterLocalNotificationsPlugin.cancel(notificationID);
      notificationID = 0;
    }
  }

  addAlertNotification() {
    if (alert == null) {
      return;
    }
    if (alert.time != null && alert.notificationID == 0 && alert.time.isAfter(DateTime.now().add(Duration(seconds: 20)))) {
      alert.notificationID = Random().nextInt(2147483647);
      tz.TZDateTime time = tz.TZDateTime.from(alert.time, tz.getLocation('US/Eastern'));
      info.notifications.notify(alert.notificationID, 'Reminder: $name', 'make sure to complete this task soon', '${alert.notificationID}', time);
    }
  }

  clearAlertNotification() {
    if (alert == null) {
      return;
    }
    if (alert.notificationID != 0) {
      info.notifications.flutterLocalNotificationsPlugin.cancel(alert.notificationID);
      alert.notificationID = 0;
    }
  }
}

class AlertData {
  DateTime time;
  int notificationID = 0;

  AlertData(this.time);
  AlertData.fromJson(Map<String, dynamic> json)
      : time = json == null
            ? null
            : json['time'] == null
                ? null
                : DateTime.parse(
                    json['time'],
                  ),
        notificationID = json == null ? null : json['notificationID'] ?? 0;
  Map toJson() => {
        'time': time != null ? time.toIso8601String() : null,
        'notificationID': notificationID,
      };
}
