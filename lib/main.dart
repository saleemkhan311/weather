import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<WeatherDetail> fetchPost() async {
  final response = await http.get(
      'http://api.openweathermap.org/data/2.5/weather?q=Karachi,pk&units=metric&APPID=0154ac07e7c0fc3b2556cc8e5da8ad48');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return WeatherDetail.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class WeatherDesc {
  final String desc;
  WeatherDesc({this.desc});
  factory WeatherDesc.fromJson(dynamic json) {
    return WeatherDesc(
      desc: json['description'] as String,
    );
  }
  @override
  String toString() {
    return '${desc[0].toUpperCase()}${desc.substring(1)}';
  }
}

class WeatherDetail {
  final Main main;
  List<WeatherDesc> weather = List();

  WeatherDetail({this.main, this.weather});

  factory WeatherDetail.fromJson(Map<String, dynamic> json) {
    return WeatherDetail(
        main: Main.fromJson(json['main']),
        weather: (json['weather'] as List)
            .map((weatherDesc) => WeatherDesc.fromJson(weatherDesc))
            .toList());
  }
}

class Main {
  final int temperature;
  final int maxTemp;
  final int minTemp;
  final double feelsLike;

  Main({this.temperature, this.maxTemp, this.minTemp, this.feelsLike});
  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
        temperature: json['temp'],
        maxTemp: json['temp_max'],
        minTemp: json['temp_min'],
        feelsLike: json['feels_like']);
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<WeatherDetail> post;

  @override
  void initState() {
    super.initState();
    post = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        
        body: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/abstract.jpg"),
          fit: BoxFit.cover
          )),
          child: SafeArea(
            child: Center(
              child: FutureBuilder<WeatherDetail>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildWeatherUI(snapshot.data);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner.
                  return CircularProgressIndicator();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherUI(WeatherDetail data) {
    String _degreeSymbol = '°';
    String _temperature = data.main.temperature.toString();
    String _lowest = (data.main.minTemp - 3).toString();
    String _highest = (data.main.maxTemp + 4).toString();
    String _feelsLike = data.main.feelsLike.toInt().toString();
    String _desc = data.weather.first.toString();

    return Column(
      children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 17.0),
              child: ActionChip(
                  elevation: 15,
                  backgroundColor: Colors.white,
                  label: Icon(
                    Icons.refresh,
                  ),
                  onPressed: () {
                    setState(() {
                      post = fetchPost();
                    });
                  }),
            )),
        Text(
          "Karachi",
          style: TextStyle(fontFamily: "big_noodle_titling", fontSize: 60.0,shadows: <Shadow>[
                      Shadow(
                        offset: Offset(5.0, 5.0),
                        blurRadius: 15.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      )
                    ]),
        ),
        RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              text: _temperature + "°c",
              style: TextStyle(
                color: Colors.grey[100],
                  fontFamily: 'Rounded_Elegance',
                  fontSize: 60,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(5.0, 5.0),
                      blurRadius: 15.0,
                      color: Color.fromARGB(110, 0, 0, 0),
                    )
                  ]
                  ),
            )),
        Align(alignment:Alignment.center ,
        child: Text(_desc, style: TextStyle(
                    color: Colors.red[600],
                    fontFamily: 'Roboto',
                    fontSize: 35,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(5.0, 5.0),
                        blurRadius: 15.0,
                        color: Color.fromARGB(150, 0, 0, 0),
                      )
                    ]
                    ),),
        ),
       Padding(
         padding: const EdgeInsets.only(top:110.0),
         child: Container(
              width: 340,
              height: 100,
              child: Card(
              elevation: 50,
              borderOnForeground: false,
              color: Colors.grey[900],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              
              children: <Widget>[
              RichText(text: TextSpan(
                text: 'Feels like',style: TextStyle(fontSize:15.0,fontFamily:'Roboto',color: Colors.grey),
              children: [
                 TextSpan(
                text: "  -   ",style: TextStyle(fontSize:15.0,fontFamily:'Roboto',color: Colors.grey)),

                TextSpan(
                text: _feelsLike+"°c",style: TextStyle(fontSize:15.0,fontFamily:'Roboto',color: Colors.grey),),
              ]
              ),
              
              ),
              Divider(color: Colors.black,endIndent: 10,),
              Text(_lowest+"   -   " + _highest + "°c",style: TextStyle(color:Colors.grey),)

            ],),
            ),

            ),
       ) 
        ],
    );
  }
}
