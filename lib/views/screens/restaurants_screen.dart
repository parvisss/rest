import 'package:dars75_yandexmap_restaurant/services/firestore_servise.dart';
import 'package:dars75_yandexmap_restaurant/views/screens/map_screen.dart';
import 'package:dars75_yandexmap_restaurant/views/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirestoreServise().getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }
          final restaurants = snapshot.data!.docs;
          return restaurants.isNotEmpty
              ? ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://panoramicrestaurant.com/wp-content/uploads/2023/07/2TH08812-1-scaled.jpg",
                        ),
                        radius: 50,
                      ),
                      title: Text(
                        restaurants[index]["givedName"],
                      ),
                      subtitle: Text(
                        restaurants[index]["name"].toString(),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => RestaurantScreen(
                              restaurant: restaurants[index]["name"],
                              location: restaurants[index]["location"],
                              rate: restaurants[index]["rate"],
                              phone: restaurants[index]["phone"],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : const Center(
                  child: Text("Empty Data"),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) {
                return MapScreen(
                  point: const Point(latitude: 0, longitude: 0),
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
