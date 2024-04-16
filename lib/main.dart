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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Text(
            'position:',
          ),
          // 位置情報を表示する部分
          if (_position != null)
            Text(
              'Latitude: ${_position!.latitude}, Longitude: ${_position!.longitude}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          // 位置情報が取得されるまでの表示
          if (_position == null)
            // CircularProgressIndicator(), // ローディングインジケーターを表示
            Text(''),
          ElevatedButton(
            onPressed: () {
              getGourmet();
            },
            child: Text('検索'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
        },
        tooltip: 'Get Position',
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> getGourmet() async {
  Map<String, String> queryParameters = {
    'key': '2fe55a3b11fdac08',
    'format': 'json',
    'lat': '35.697837275',
    'lng': '139.8117242108',
    'range': '5',
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
