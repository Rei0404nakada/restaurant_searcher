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
  String isSelectedValue = '1';
  late List<List<String>>? restaurantData;
  String range = '1';

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
            // // 位置情報を表示する部分
            // if (_position != null)
            //   Text(
            //     'Latitude: ${_position!.latitude}, Longitude: ${_position!.longitude}',
            //     style: Theme.of(context).textTheme.titleLarge,
            //   ),
            // // 位置情報が取得されるまでの表示
            // if (_position == null)
            //   // CircularProgressIndicator(), // ローディングインジケーターを表示
            //   const Text(''),
            ElevatedButton(
              onPressed: () {
                // ボタンが押されたときに位置情報を取得する
                determinePosition().then((position) {
                  setState(() {
                    _position = position; // 取得した位置情報を状態に設定
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
                if (_position != null) {
                  print(_position!.latitude.toString());
                  print(_position!.longitude.toString());
                }
              },
              child: const Text('位置情報取得'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  onPressed: () {
                    getGourmet(range);
                    print(isSelectedValue);
                  },
                  child: const Text('検索'),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: _deviceWidth,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
              ),
              child: FutureBuilder<List<List<String>>?>(
                  future: getGourmet(range),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<List<String>>?> snapshot) {
                    if (snapshot.hasData) {
                      List<List<String>>? data = snapshot.data;
                      int dataLength = data!.length;
                      return Column(
                        children: <Widget>[
                          for (int i = 0; i < dataLength; i++) ...{
                            Container(
                              width: _deviceWidth,
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
                                  Image.network(restaurantData![i][1]),
                                  Container(
                                    width: _deviceWidth * 0.66,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                            restaurantData![i][0]),
                                        Text(
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                            restaurantData![i][2]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          },
                        ],
                      );
                    } else {
                      return SizedBox(
                        height: 50,
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<List<String>>?> getGourmet(range) async {
    Map<String, String> queryParameters = {
      'key': '2fe55a3b11fdac08',
      'format': 'json',
      'lat': '35.697837275',
      'lng': '139.8117242108',
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

    print(results['results']['shop'][0]['name']);
    print(results['results']['shop'][0]['address']);
    print(results['results']['shop'][0]['station_name']);
    print(results['results']['shop'][0]['photo']['mobile']['s']);
    print(results['results']['shop'][0]['mobile_access']);
    if (response.statusCode == 200) {
      restaurantData = [
        [
          results['results']['shop'][0]['name'],
          results['results']['shop'][0]['photo']['mobile']['s'],
          results['results']['shop'][0]['mobile_access']
        ],
      ];
      for (int i = 1; i < results['results']['shop'].length; i++) {
        restaurantData!.add(
          [
            results['results']['shop'][i]['name'],
            results['results']['shop'][i]['photo']['mobile']['s'],
            results['results']['shop'][i]['mobile_access']
          ],
        );
      }
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
