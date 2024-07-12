import 'package:dars75_yandexmap_restaurant/views/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

// ignore: must_be_immutable
class RestaurantScreen extends StatelessWidget {
  RestaurantScreen(
      {super.key,
      required this.restaurant,
      required this.location,
      required this.phone,
      required this.rate});
  String restaurant;
  String location;
  String phone;
  int rate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: 380,
            child: Image.network(
                "https://panoramicrestaurant.com/wp-content/uploads/2023/07/2TH08812-1-scaled.jpg"),
          ),
          Text(
            phone,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < rate; i++)
                const Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List latLang = location.split(",");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => MapScreen(
                point: Point(
                  latitude: double.parse(latLang[0]),
                  longitude: double.parse(latLang[1]),
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.navigation_rounded,
        ),
      ),
    );
  }
}
