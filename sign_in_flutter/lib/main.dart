import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sign_in_flutter/upnext.dart';
import 'apiservice.dart';
import 'appinfo.dart';
import 'loading.dart';
import 'login.dart';
import 'home.dart';
import 'schedule.dart';
import 'settings.dart';
import 'notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Route(),
    );
  }
}

class Route extends StatefulWidget {
  @override
  RouteState createState() => RouteState();
}

class RouteState extends State<Route> {
  AppInfo info;
  @override
  void initState() {
    super.initState();
    info = AppInfo();
    info.api = ApiService();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('US/Eastern'));
  }

  init(ctx) {
    info.api.autoSignIn().then((loggedIn) {
      setState(() {
        if (loggedIn) {
          info.postLogin(ctx);
        } else {
          Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (ctx) => Login(info)));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Loading(init, "loading data");
  }
}

class Main extends StatefulWidget {
  final AppInfo info;
  Main(this.info);

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> with WidgetsBindingObserver {
  int page = 0;

  PageController pc;

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    page = widget.info.data.currentPage ?? 0;
    pc = PageController(initialPage: page);
    pc.addListener(() {
      setState(() {
        page = (pc.page).round();
        widget.info.data.currentPage = page;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.info.data != null) {
      widget.info.data.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Container(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 130),
                  width: 18,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page == 0 ? Colors.black87 : Colors.black38,
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 130),
                  width: 18,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page == 1 ? Colors.black87 : Colors.black38,
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 130),
                  width: 18,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page == 2 ? Colors.black87 : Colors.black38,
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 130),
                  width: 18,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page == 3 ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            )),
      ),
      body: PageView(
        physics: BouncingScrollPhysics(),
        controller: pc,
        children: [
          UpNext(widget.info),
          Home(widget.info),
          Schedule(widget.info),
          Settings(widget.info),
        ],
      ),
    );
  }
}
