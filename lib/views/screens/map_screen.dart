import 'package:dars75_yandexmap_restaurant/services/firestore_servise.dart';
import 'package:dars75_yandexmap_restaurant/services/yandex_map_service.dart';
import 'package:dars75_yandexmap_restaurant/views/screens/restaurants_screen.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  MapScreen({super.key, required this.point});
  Point point;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final nameController = TextEditingController();

  late YandexMapController mapController;
  final searchContoller = TextEditingController();
  final phoneController = TextEditingController();
  int rate = 0;
  Point currentPoint =
      const Point(latitude: 41.28577506325057, longitude: 69.20349804096463);
  List<MapObject>? routePoints;

  Point? selectedPoint;

  List<SuggestItem> suggestions = [];

  void onMapCreated(YandexMapController controller) {
    mapController = controller;
    if (currentPoint != 0) {
      goToLocation(currentPoint);
      YandexMapService.getDirection(currentPoint, widget.point).then((points) {
        routePoints = points;
        setState(() {});
      });
    }

    setState(() {});
  }

  void getSearchSuggestions(String address) async {
    mapController.toggleUserLayer(visible: true);
    suggestions = await YandexMapService.getSearchSuggestions(address);

    setState(() {});
  }

  void goToLocation(Point? location) {
    if (location != null) {
      mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 18,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            mapType: MapType.vector,
            onMapCreated: onMapCreated,
            onMapLongTap: (Point point) {
              selectedPoint = point;
              YandexMapService.getDirection(
                currentPoint,
                selectedPoint!,
              ).then((points) {
                routePoints = points;
                setState(() {});
              });
              setState(() {});
            },
            mapObjects: [
              PlacemarkMapObject(
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage(
                      'assets/place.png',
                    ),
                    scale: 0.2,
                    anchor: const Offset(0.5, 2),
                  ),
                ),
                mapId: const MapObjectId("currentLocation"),
                point: currentPoint,
              ),
              if (selectedPoint != null)
                PlacemarkMapObject(
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage("assets/pin.png"),
                      scale: 0.2
                    ),
                  ),
                  mapId: const MapObjectId("selectedLocation"),
                  point: selectedPoint!,
                ),
              ...?routePoints,
            ],
          ),
          Align(
            alignment: const Alignment(0, -0.8),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                      controller: searchContoller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: getSearchSuggestions),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight:
                          (70 * suggestions.length).clamp(0, 300).toDouble(),
                    ),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (ctx, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          onTap: () {
                            suggestions = [];
                            goToLocation(suggestion.center);
                            searchContoller.text = '';
                            setState(() {});
                          },
                          title: Text(suggestion.displayText),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: InkWell(
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.location_searching_outlined,
                    size: 35,
                  ),
                ),
              ),
              onTap: () {
                goToLocation(currentPoint);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Add"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Nmae",
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Phone",
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        for (int i = 0; i < 5; i++)
                          IconButton(
                            onPressed: () {
                              rate = i + 1;
                              setState(() {});
                            },
                            icon: i < rate
                                ? const Icon(
                                    Icons.star,
                                  )
                                : const Icon(Icons.star_border),
                                
                          ),
                          
                      ],
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FilledButton(
                    onPressed: () async {
                      final placeName = await YandexMapService.getLocationName(
                          selectedPoint!);

                      await FirestoreServise().addData(
                        nameController.text,
                        selectedPoint!,
                        placeName,
                        phoneController.text,
                        rate,
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const RestaurantsScreen(),
                        ),
                      );
                    },
                    child: const Text("add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
