import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RestaurantSearcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _position; // 位置情報を保持する状態変数
  String latPosition = '';
  String lngPosition = '';
  String isSelectedValue = '1';
  String range = '1';
  Future<List<List<String>>?>? restaurantData;
  bool searchError = false;

  @override
  Widget build(BuildContext context) {
    double _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: _deviceWidth * 0.9,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black)),
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // ボタンが押されたときに位置情報を取得する
                      determinePosition().then((position) {
                        setState(() {
                          _position = position; // 取得した位置情報を状態に設定
                          if (_position != null) {
                            print(_position!.latitude.toString());
                            print(_position!.longitude.toString());
                            latPosition = '35.691837275';
                            lngPosition = '139.8117242108';
                            print(latPosition);
                          }
                        });
                      }).catchError((error) {
                        setState(() {
                          _position = null; // エラーが発生した場合は状態をクリア
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $error'), // エラーメッセージを表示
                          ),
                        );
                      });
                    },
                    child: const Text('位置情報取得'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Text('検索範囲'),
                      DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('300m'),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('500m'),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text('1000m'),
                          ),
                          DropdownMenuItem(
                            value: '4',
                            child: Text('2000m'),
                          ),
                          DropdownMenuItem(
                            value: '5',
                            child: Text('3000m'),
                          ),
                        ],
                        value: isSelectedValue,
                        onChanged: (String? value) {
                          setState(() {
                            isSelectedValue = value!;
                            range = value;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: locationChecker() == false
                            ? null
                            : () {
                                setState(() {
                                  restaurantData = getGourmet(
                                      range, latPosition, lngPosition);
                                  print(isSelectedValue);
                                });
                              },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            disabledBackgroundColor:
                                Colors.blueAccent.withOpacity(0.6),
                            disabledForegroundColor:
                                Colors.white.withOpacity(0.6)),
                        child: const Text('検索'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: _deviceWidth,
              child: FutureBuilder<List<List<String>>?>(
                  future: restaurantData,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<List<String>>?> snapshot) {
                    if (snapshot.hasData &&
                        latPosition != '' &&
                        lngPosition != '') {
                      List<List<String>>? data = snapshot.data;
                      int dataLength = data!.length;
                      return Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('＜'),
                              ),
                              const Text(
                                '1',
                                style: TextStyle(fontSize: 18),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('＞'),
                              ),
                            ],
                          ),
                          for (int i = 0; i < dataLength; i++) ...{
                            Container(
                              width: _deviceWidth,
                              height: _deviceWidth * 0.33,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.black,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Image.network(data[i][1]),
                                  SizedBox(
                                    width: _deviceWidth * 0.66,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                            data[i][0]),
                                        Text(
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            data[i][2]),
                                        Text(
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            data[i][3]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          },
                        ],
                      );
                    } else if (searchError) {
                      return AlertDialog(
                        title: const Text('エラー'),
                        content: const Text('検索範囲に店が存在していないか、通信エラーが発生しています'),
                        actions: <Widget>[
                          GestureDetector(
                            child: const Text('OK'),
                            onTap: () {
                              setState(() {
                                searchError = false;
                                latPosition = '';
                                lngPosition = '';
                              });
                            },
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                            locationChecker() == false
                                ? '位置情報を取得してください'
                                : '検索ボタンを押してください',
                          ),
                        ],
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  bool locationChecker() {
    if (latPosition != '' && lngPosition != '') {
      return true;
    } else {
      return false;
    }
  }

  Future<List<List<String>>?> getGourmet(
      String range, String lat, String lng) async {
    late List<List<String>>? restaurantData;
    int test = 404;
    Map<String, String> queryParameters = {
      'key': '2fe55a3b11fdac08',
      'format': 'json',
      'lat': lat,
      'lng': lng,
      'range': range,
      'count': '10',
    };
    Uri uri = Uri.https(
        'webservice.recruit.co.jp', '/hotpepper/gourmet/v1/', queryParameters);
    final response = await http.get(
      uri,
    );
    print('👑$response');
    print('👑${response.statusCode}');

    final results = jsonDecode(response.body);
    print(results);
    print(lat);
    print(range);
    print(results['results']['shop'][0]['budget']['name']);

    if (response.statusCode == 200 && results['results']['shop'].length > 0) {
      searchError = false;
      restaurantData = [
        [
          results['results']['shop'][0]['name'],
          results['results']['shop'][0]['photo']['mobile']['s'],
          results['results']['shop'][0]['mobile_access'],
          results['results']['shop'][0]['budget']['name']
        ],
      ];
      for (int i = 1; i < results['results']['shop'].length; i++) {
        restaurantData!.add(
          [
            results['results']['shop'][i]['name'],
            results['results']['shop'][i]['photo']['mobile']['s'],
            results['results']['shop'][i]['mobile_access'],
            results['results']['shop'][i]['budget']['name']
          ],
        );
      }
    } else {
      searchError = true;
    }
    return restaurantData;
  }
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled.';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permissions are denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied, we cannot request permissions.';
  }

  return Geolocator.getCurrentPosition();
}
