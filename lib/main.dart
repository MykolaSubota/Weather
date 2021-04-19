import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature;
  String location ='Kyiv';
  int woeid = 703448;
  String iconcode = '10d';
  String weather = 'Clear';
  String abbrevation = '';
  String errorMessage = '';
  //String searchApiUrl =
 //     'https://www.metaweather.com/api/location/search/?query=';
  static const baseUrl = 'http://api.openweathermap.org';
  static const token = 'ecac0cff9381cfa0877aab7e79a86a43';
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async{
    try{
      var url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {'q': '$input', 'appid': '$token', 'units': 'metric', 'lang':'ua'});

      var response = await http.get(url);
      var locationJson = null;
      if (response.statusCode != 200) {
        print('error getting locationId for city');
        throw Exception('error getting locationId for city');
      }
      else{
         print('Greet get data');
         print(response.body.toString());
         locationJson = jsonDecode(response.body);
         print(locationJson.toString());
         print('City Name: $input\nCity ID: ' + (locationJson)['id'].toString());
      }

      setState(() {
        location = (locationJson)['name'];
        woeid = (locationJson)['id'];
        errorMessage = '';
      });
    }
    catch(error){
      setState(() {
        errorMessage = "Sorry, we don`t have data about this city."
             + " Try another one.";
      });
    }
  }

  void fetchLocation() async{
    print("fetchLocation start. City ID: $woeid");
    var url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {'id': woeid.toString(), 'appid': '$token', 'units': 'metric', 'lang':'ua'});

    var response = await http.get(url);

    if (response.statusCode != 200) {
      print('error getting weather for location');
    }

    final weatherJson = jsonDecode(response.body);

    try {
      print("Weather  ");
      print(weatherJson);
      print("Json  ");
      print("Temp " + (weatherJson)['main']['temp'].toString());
      print("Wearheee " + (weatherJson)['weather'][0]['description'].toString());
    }
    catch(e){
      print("Json Decode error:" + e);
    }


    setState(() {
      double multiplier = .5;
      temperature = (multiplier * (weatherJson)['main']['temp']).round();
      weather = (weatherJson)['weather'][0]['main'];
      abbrevation = (weatherJson)['weather'][0]['main'];
      iconcode = (weatherJson)['weather'][0]['icon'];
    });
  }

  void onTextFieldSubmitted(String input) async{
    await fetchSearch(input);
    await fetchLocation();
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude,
          _currentPosition.longitude
      );

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
      onTextFieldSubmitted(place.locality);
      print(place.locality);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/$weather.png'),
                fit: BoxFit.cover
            )
        ),
        child:
        Scaffold(
          appBar: AppBar(actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: (){
                  _getCurrentLocation();
                },
                child: Icon(Icons.location_city, size: 36,),
              ),
            )
          ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Center(
                    child: Image.network(
                      'https://openweathermap.org/img/wn/' +
                          iconcode + '.png',
                      width: 100,
                    ),
                  ),
                  Center(
                      child: Text(
                          temperature.toString() + '°С',
                        style: TextStyle(color: Colors.white, fontSize: 60),
                      )
                  ),
                  Center(
                    child: Text(
                        location,
                        style: TextStyle(color: Colors.white, fontSize: 40)
                    ),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input){
                        onTextFieldSubmitted(input);
                      },
                      style: TextStyle(color: Colors.white, fontSize: 25),
                      decoration: InputDecoration(
                        hintText: 'Search another location...',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 18),
                        prefixIcon: Icon(Icons.search, color: Colors.white,)
                      ),
                    ),
                  ),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


