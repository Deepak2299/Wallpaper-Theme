import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shake/shake.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaperplugin/wallpaperplugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

void main() => runApp(MyApp());

String ACCESS_KEY = "1rHlcywTTNw6h5BHsR1Apa1it3YvNF0dvMrJeMDIPnI";

String SECRET_KEY = "Ks0INvpv8yduR-iOA-25cgJaqYypKNQbV6VCNeIZFag";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
//  ScrollController controller = new ScrollController();
//  List textshow = new List(10);
  var _pg = 1;
  bool isShaking = true;
  ShakeDetector detector;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    detector = ShakeDetector.waitForStart(onPhoneShake: () {
      print("shaking");

      setState(() {
        isShaking = false;
        _pg++;
        data.clear();
      });
//      controller = new ScrollController();
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isShaking = true;
          fetchData(page: _pg);
        });
      });
    });
    fetchData(page: _pg);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    detector.stopListening();
    super.dispose();
  }

  List data;
  Future<String> fetchData({int page = 1}) async {
    var res = await http.get(
        "https://api.unsplash.com/search/photos?page=${page}&per_page=10&client_id=${ACCESS_KEY}&query=nature");
    var jsonData = json.decode(res.body);
//    print(jsonData['results']);
    setState(() {
      data = jsonData['results'];
    });
//    print(data);
//    print(data.length);
    return "Success";
  }

  static Future<bool> _checkAndGetPermission() async {
    final PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permissionStatus != PermissionStatus.granted) {
      final Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions(<PermissionGroup>[PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        return null;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    detector.startListening();

    var size = MediaQuery.of(context).size;

    var center = Alignment.center.alongSize(size).dx;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: isShaking
            ? new Swiper(
                key: UniqueKey(),
                pagination: new SwiperPagination(
                    margin: new EdgeInsets.all(5.0),
                    builder: new DotSwiperPaginationBuilder(
                        color: Colors.grey,
                        activeColor: Colors.white,
                        activeSize: 18.0,
                        size: 8.0)),
                itemBuilder: (BuildContext context, int index) {
                  String name = data[index]["user"]["name"];
                  return GestureDetector(
                    onDoubleTap: () {
                      print("double tab");

                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return AlertDialog(
                              title: Container(
                                child: Column(
//                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Saved",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Wallpaper successfully saved to \nCamara Roll",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    FlatButton(
                                      padding: EdgeInsets.only(bottom: 0),
                                      onPressed: () {
                                        downloadImg(context,
                                            data[index]["urls"]["small"]);
                                      },
                                      child: Text(
                                        "High 5!",
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    onLongPressStart: (d) {
                      if (d.globalPosition.dx < center) {
                        print("Left Side");
                      }
                      if (d.globalPosition.dx > center) {
                        print("Right Side");
                      }
                    },
//                    onLongPressEnd: (d) {
//                      if (d.globalPosition.dx < center) {
//                        print("Left Side");
//                      }
//                      if (d.globalPosition.dx < center) {
//                        print("Right Side");
//                      }
//                    },
                    child: Image.network(
                      data[index]["urls"]["small"],
                      fit: BoxFit.fill,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded)
                          return Stack(
                            children: <Widget>[
                              Container(
                                  width: size.width,
                                  height: size.height,
                                  child: child),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(3.0),
                                      child: Text(
                                        "Photo by",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      color: Colors.black,
                                      width: center,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: center,
                                      padding: EdgeInsets.all(3.0),
                                      color: Colors.black,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ],
//                            mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              )
                            ],
                          );
                        else {
                          return frame != null
                              ? Stack(
                                  children: <Widget>[
                                    Container(
                                        width: size.width,
                                        height: size.height,
                                        child: child),
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(3.0),
                                            child: Text(
                                              "Photo by",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            color: Colors.black,
                                            width: center,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            width: center,
                                            padding: EdgeInsets.all(3.0),
                                            color: Colors.black,
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
//                            mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ),
                                    )
                                  ],
                                )
                              : null;
                        }
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
//                      print(child.hashCode);
                        if (loadingProgress == null) {
                          return Stack(
                            children: <Widget>[
                              Container(
                                  width: size.width,
                                  height: size.height,
                                  child: child),
                            ],
                          );
                        }

                        return Container(
                          color: Colors.black,
                          child: Stack(
                            children: <Widget>[
                              Center(
                                  child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      new AlwaysStoppedAnimation(Colors.white),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              )),
                              Center(
                                child: Text(
                                  "${(loadingProgress.cumulativeBytesLoaded * 100 / loadingProgress.expectedTotalBytes).floor()}%",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 9),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                itemCount: data == null ? 0 : data.length,
//        pagination: new SwiperPagination(),
//              control: new SwiperControl(),
                loop: false,
//        autoplayDisableOnInteraction: false,
//        index: 7,
              )
            : Container(
                width: size.width,
                height: size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation(Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Fetching data..",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  downloadImg(BuildContext context, String url) async {
    if (_checkAndGetPermission() != null) {
      Dio dio = new Dio();
      final Directory appDirectory = await getExternalStorageDirectory();
      final Directory directory =
          await Directory(appDirectory.path + "/wallpapers")
              .create(recursive: true);
//      final String dir = directory.path;
      final String dir = "/storage/emulated/0/DCIM/wallpapers";
      String num = new DateTime.now().toIso8601String();
      String localpath = "$dir/IMG_$num.jpeg";

      try {
        dio.download(url, localpath);
        print(localpath);
      } on PlatformException catch (e) {
        print(e);
      }
    } else {}
    Navigator.pop(context);
  }
}
