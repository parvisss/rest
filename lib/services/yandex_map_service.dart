import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapService {
  static Future<List<SuggestItem>> getSearchSuggestions(String address) async {
    final result = await YandexSuggest.getSuggestions(
      text: address,
      boundingBox: const BoundingBox(
        northEast: Point(
          latitude: 0,
          longitude: 0,
        ),
        southWest: Point(
          latitude: 0,
          longitude: 0,
        ),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
      ),
    );

    final suggestionResult = await result.$2;

    if (suggestionResult.error != null) {
      print("Manzil topilmadi");
      return [];
    }

    return suggestionResult.items ?? [];
  }

  static Future<List<MapObject>> getDirection(Point from, Point to) async {
    final result = await YandexDriving.requestRoutes(
      points: [
        RequestPoint(point: from, requestPointType: RequestPointType.wayPoint),
        RequestPoint(point: to, requestPointType: RequestPointType.wayPoint),
      ],
      drivingOptions: const DrivingOptions(
        initialAzimuth: 1,
        routesCount: 1,
        avoidTolls: true,
      ),
    );

    final drivingResult = await result.$2;

    if (drivingResult.error != null) {
      print(drivingResult.error);
      return [];
    }

    final points = drivingResult.routes!.map((route) {
      return PolylineMapObject(
        mapId: MapObjectId(UniqueKey().toString()),
        polyline: route.geometry,
      );
    }).toList();

    return points;
  }

  static Future<Point?> getCurrentLocation() async {
    final location = await Geolocator.getCurrentPosition();

    return Point(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  static Future<String> getLocationName(Point point) async {
    final placeName = await YandexSearch.searchByPoint(
      point: point,
      searchOptions: const SearchOptions(searchType: SearchType.geo),
    );
    final searchResult = await placeName.$2;
    if (searchResult.error != null) {
      print('Error searching by point: ${searchResult.error}');
      return 'Address not found';
    }

    final items = searchResult.items;
    if (items != null && items.isNotEmpty) {
      final firstItem = items.first;
      final toponymMetadata = firstItem.toponymMetadata;
      if (toponymMetadata != null) {
        print(toponymMetadata.address.formattedAddress);
        return toponymMetadata.address.formattedAddress;
      } else {
        return 'Address not found';
      }
    } else {
      return 'Address not found';
    }
  }
}
