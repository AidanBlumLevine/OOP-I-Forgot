import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'apiservice.dart';
import 'appdata.dart';
import 'main.dart';
import 'notifications.dart';

class AppInfo {
  AppData data;
  ApiService api;
  Notifications notifications;
  Future postLogin(BuildContext context) async {
    print("NOTIFICATIONS");
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    notifications = Notifications(flutterLocalNotificationsPlugin);
    notifications.initNotifications();
    //load saved data
    String email = api.account.email;
    Directory path = await getApplicationDocumentsDirectory();
    String filename = email.replaceAll(RegExp('([^a-z0-9]+)'), '-');
    File savedData = File(path.path + "/" + filename + '.json');
    if (await savedData.exists()) {
      String source = await savedData.readAsString();
      data = AppData.fromJson(jsonDecode(source));
    } else {
      data = AppData(email);
    }
    data.saveTo = savedData;

    //nothing loaded is new
    for (CourseData c in data.courses) {
      for (AssignmentData a in c.assignments) {
        a.newassignment = false;
      }
    }

    //get api values
    final courses = await api.courses();
    if (courses != null) {
      //Remove all courses which are no longer active
      for (int i = 0; i < data.courses.length; i++) {
        CourseData cd = data.courses[i];
        Course course = courses.firstWhere((c) => int.parse(c.id) == cd.id, orElse: () => null);
        if (cd.id != 333 && course == null) {
          data.courses.removeAt(i);
          i--;
        }
      }

      for (Course course in courses) {
        CourseData cd = data.courses.firstWhere((c) => c.id == int.parse(course.id), orElse: () => null);
        if (cd == null) {
          cd = CourseData(int.parse(course.id), course.name, data.pickNewColor());
          data.courses.add(cd);
        } else {
          //maybe verify that recorded course matches this one
        }

        //get submission info for all this course's assignments
        final submissions = await api.submission(course);

        final assignments = await api.assignments(course);

        //remove all assignments that are no longer published
        for (int i = 0; i < cd.assignments.length; i++) {
          AssignmentData ad = cd.assignments[i];
          CourseWork courseWork = (assignments ?? []).firstWhere((a) => int.parse(a.id) == ad.id, orElse: () => null);
          if (courseWork == null) {
            cd.assignments.removeAt(i);
            i--;
          }
        }

        for (CourseWork assignment in assignments ?? []) {
          AssignmentData ad = cd.assignments.firstWhere((a) => a.id == int.parse(assignment.id), orElse: () => null);
          if (ad == null) {
            if (data.lastCourseFetch == null || DateTime.parse(assignment.updateTime).isAfter(data.lastCourseFetch)) {
              ad = AssignmentData(int.parse(assignment.id), assignment.title, api.date(assignment));
              cd.assignments.add(ad);
            } else {
              //if this courses was just loaded for the first time but is also old? shouldnt ever really happen
              continue;
            }
          } else {
            //turned in state is seperate, see below
          }

          //is it turned in?
          if (submissions.length > 0) {
            var latest;
            for (var submission in submissions) {
              if (submission == null || submission.updateTime == null || int.parse(submission.courseWorkId) != ad.id) {
                continue;
              }
              if (latest == null || DateTime.parse(submission.updateTime).isAfter(DateTime.parse(latest.updateTime))) {
                latest = submission;
              }
            }

            if (!ad.completed && latest != null) {
              ad.completed = latest.state == "TURNED_IN" || latest.state == "RETURNED";
              ad.completedAt = DateTime.parse(latest.updateTime);
            }
          }
        }
      }
    }
    for (EventData ed in data.events) {
      if (ed.uuid == null) {
        ed.uuid = Uuid().v4();
      }
    }
    for (CourseData cd in data.courses) {
      //NOTIFICATIONS
      for (AssignmentData ad in cd.assignments) {
        ad.info = this;
        ad.addNotification();
      }

      //FIXES============================================
      for (AssignmentData ad in cd.assignments) {
        if (ad.uuid == null) {
          ad.uuid = Uuid().v4();
        }
      }
    }
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await notifications.flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (PendingNotificationRequest a in pendingNotificationRequests) {
      print(a.title);
    }
    //====================================================

    data.notifications = notifications;
    data.lastCourseFetch = DateTime.now().subtract(Duration(minutes: 1));
    data.currentDay = DateTime.now().weekday;
    //done loading
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main(this)));
  }
}
