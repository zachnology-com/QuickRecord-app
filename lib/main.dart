import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:get_version/get_version.dart';
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'animations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickRecord',
      theme: ThemeData(
        primaryColor: Color(0xffE6E6E6),
        accentColor: Color(0xff4BBFD4),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ChromeSafariBrowser browser =
      new MyChromeSafariBrowser(new MyInAppBrowser());
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String shortcut = "no action set";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xffE6E6E6),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
          backgroundColor: Color(0xffE6E6E6),
          appBar: AppBar(
            elevation: 0,
            title: Text(
              "QuickRecord",
              style: TextStyle(
                fontFamily: "ZachnologyEuclid",
                fontSize: 22,
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: InkWell(
                  onTap: () {
                    Vibration.vibrate(duration: 10);
                    final RenderBox box = context.findRenderObject();
                    Share.share(
                        "Hey, you should check out this awesome podcast called Zachnology Tech Reviews at https://tech-reviews.zachnology.com!",
                        subject: "Awesome podcast!",
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                  },
                  child: Container(
                    width: 50,
                    child: Icon(
                      Icons.share_outlined,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: InkWell(
                  autofocus: true,
                  onTap: () async {
                    Vibration.vibrate(duration: 10);
                    await widget.browser.open(
                        url:
                            "https://docs.google.com/forms/d/e/1FAIpQLSf8tDysOTOgDHWSqVlYwJv-1GnQebolUkyRtKnWfqpOXlT8wA/viewform?usp=sf_link",
                        options: ChromeSafariBrowserClassOptions(
                            android: AndroidChromeCustomTabsOptions(
                              addDefaultShareMenuItem: true,
                              showTitle: true,
                            ),
                            ios: IOSSafariOptions(barCollapsingEnabled: true)));
                  },
                  child: Container(
                    width: 50,
                    child: Icon(
                      Icons.feedback_outlined,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: InkWell(
                  autofocus: true,
                  onTap: () {
                    Vibration.vibrate(duration: 10);
                    Navigator.push(context, ScaleRoute(page: SettingsPage()));
                  },
                  child: Container(
                    width: 50,
                    child: Icon(
                      Icons.settings_outlined,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
              child: Column(children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                    initialUrl: "https://form.jotform.com/211414403575145",
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        mediaPlaybackRequiresUserGesture: false,
                        debuggingEnabled: true,
                      ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {},
                    androidOnPermissionRequest:
                        (InAppWebViewController controller, String origin,
                            List<String> resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    }),
              ),
            ),
          ]))),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final ChromeSafariBrowser browser =
      new MyChromeSafariBrowser(new MyInAppBrowser());
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String year = DateFormat("yyyy").format(DateTime.now());
  String _projectVersion = '';
  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  initPlatformState() async {
    String projectVersion;
    try {
      projectVersion = await GetVersion.projectVersion;
    } on PlatformException {
      projectVersion = 'Failed to get project version.';
    }
    if (!mounted) return;

    setState(() {
      _projectVersion = projectVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xffE6E6E6),
        systemNavigationBarDividerColor: Color(0xffE6E6E6),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xffE6E6E6),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(EvaIcons.arrowIosBackOutline,
                  color: Colors.black, size: 30),
              onPressed: () {
                Vibration.vibrate(duration: 10);
                Navigator.of(context).pop();
              }),
          title: Text(
            "Settings",
            style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 22,
            ),
          ),
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    SizedBox(width: 35),
                    Image(
                      image: AssetImage('assets/zachnology.png'),
                      width: 90,
                    ),
                    SizedBox(width: 20),
                    Image(
                      image: AssetImage('assets/173012.png'),
                      width: 90,
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    SizedBox(width: 35),
                    Text(
                      'QuickRecord',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "ZachnologyEuclid",
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    SizedBox(width: 35),
                    Text(
                      'By Zachnology Tech Reviews',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 42),
                Scrollbar(
                  child: Column(
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0)),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        child: InkWell(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0)),
                          onTap: () {
                            Vibration.vibrate(duration: 10);
                            AppSettings.openAppSettings();
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 30),
                            leading: Icon(
                              Icons.settings_outlined,
                              color: Color(0xff24527A),
                            ),
                            title: Text('Open Settings'),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0)),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        child: InkWell(
                          onTap: () {
                            Vibration.vibrate(duration: 10);
                            Share.share(
                              "Hey, you should check out this awesome podcast called Zachnology Tech Reviews at https://tech-reviews.zachnology.com!",
                              subject: "Awesome podcast!",
                            );
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 30),
                            leading: Icon(
                              Icons.share_outlined,
                              color: Color(0xff24527A),
                            ),
                            title: Text('Share Podcast'),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0)),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        child: InkWell(
                          onTap: () async {
                            Vibration.vibrate(duration: 10);
                            await widget.browser.open(
                                url:
                                    "https://zachnology-reviews.wixsite.com/site/privacy-policy",
                                options: ChromeSafariBrowserClassOptions(
                                    android: AndroidChromeCustomTabsOptions(
                                      addDefaultShareMenuItem: true,
                                      showTitle: true,
                                    ),
                                    ios: IOSSafariOptions(
                                        barCollapsingEnabled: true)));
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 30),
                            leading: Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xff24527A),
                            ),
                            title: Text('Privacy Policy'),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0)),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        child: InkWell(
                          onTap: () async {
                            Vibration.vibrate(duration: 10);
                            await widget.browser.open(
                                url:
                                    "https://zachnology-reviews.wixsite.com/site/terms-of-service",
                                options: ChromeSafariBrowserClassOptions(
                                    android: AndroidChromeCustomTabsOptions(
                                      addDefaultShareMenuItem: true,
                                      showTitle: true,
                                    ),
                                    ios: IOSSafariOptions(
                                        barCollapsingEnabled: true)));
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 30),
                            leading: Icon(
                              Icons.article_outlined,
                              color: Color(0xff24527A),
                            ),
                            title: Text('Terms of Service'),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0)),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        child: InkWell(
                          onTap: () async {
                            Vibration.vibrate(duration: 10);
                            await widget.browser.open(
                                url:
                                    "https://zachnology-reviews.wixsite.com/site/updating-our-app",
                                options: ChromeSafariBrowserClassOptions(
                                    android: AndroidChromeCustomTabsOptions(
                                      addDefaultShareMenuItem: true,
                                      showTitle: true,
                                    ),
                                    ios: IOSSafariOptions(
                                        barCollapsingEnabled: true)));
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 30),
                            leading: Icon(
                              Icons.file_download_outlined,
                              color: Color(0xff24527A),
                            ),
                            title: Text('Update App'),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0)),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        child: InkWell(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0)),
                          onTap: () {
                            Vibration.vibrate(duration: 10);
                          },
                          onLongPress: () async {
                            Vibration.vibrate(duration: 50);
                            await new Future.delayed(
                                const Duration(seconds: 1));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EasterEgg()));
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 30),
                            leading: Icon(
                              Icons.info_outlined,
                              color: Color(0xff24527A),
                            ),
                            title: Text('Version'),
                            subtitle: Text(_projectVersion),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "\u00a9 " + year + " Zachnology and 1730 12",
                        textAlign: TextAlign.center,
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EasterEgg extends StatefulWidget {
  const EasterEgg({Key key}) : super(key: key);

  @override
  _EasterEggState createState() => _EasterEggState();
}

class _EasterEggState extends State<EasterEgg> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      child: Scaffold(
        backgroundColor: Color(0xffFFBE40),
        body: Column(
          children: <Widget>[
            Image(
              image: AssetImage('assets/todaynow.jpg'),
            ),
            SizedBox(height: 100),
            Text(
              'You found the TodayNOW! Easter Egg!!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "ZachnologyEuclid",
                fontSize: 35,
              ),
            ),
            SizedBox(height: 50),
            Text(
              "TodayNOW! is America's number one favorite news show!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xffFEF546)),
                ),
                icon:
                    Icon(EvaIcons.arrowIosBack, size: 26, color: Colors.black),
                label: Text(
                  'RETURN',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  Vibration.vibrate(duration: 10);
                  Navigator.of(context).pop();
                }),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          foregroundColor: Colors.black,
          backgroundColor: Color(0xffFEF546),
          onPressed: () {
            Share.share(
                'I just found the TodayNOW! easter egg in the Zachnology QuickRecord app! Try to figure out where it is!');
          },
          icon: Icon(
            Icons.send_outlined,
          ),
          label: Text('SEND TO FRIENDS'),
        ),
      ),
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xffFFBE40),
        systemNavigationBarDividerColor: Color(0xffFFBE40),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser(browserFallback) : super(bFallback: browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    Vibration.vibrate(duration: 10);
    print("ChromeSafari browser closed");
  }
}

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }
}
