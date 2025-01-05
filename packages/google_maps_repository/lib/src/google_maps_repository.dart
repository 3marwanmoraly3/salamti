import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_repository/src/apiKeys.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationAutoCompleteRequestFailure implements Exception {
  @override
  String toString() {
    return "Location autocomplete request failure.";
  }
}

class PlaceIdRequestFailure implements Exception {
  @override
  String toString() {
    return "Place ID request failure.";
  }
}

class RouteRequestFailure implements Exception {
  @override
  String toString() => 'Failed to fetch route information.';
}


class GoogleMapsRepository {
  Future<List<dynamic>> getLocationAutoComplete(
      String query, String? longitude, String? latitude) async {
    try {
      if (query == "") {
        return [];
      }
      http.Response? response =
          await locationAutoCompleteRequest(query, longitude, latitude);
      if (response != null) {
        if (response.statusCode == 200) {
          final decodedResult = jsonDecode(response.body)["suggestions"];
          List<dynamic> suggestions = [];
          for (int i = 0; i < decodedResult.length; i++) {
            final placeId = decodedResult[i]["placePrediction"]["placeId"];
            final placeName = decodedResult[i]["placePrediction"]
                ["structuredFormat"]["mainText"]["text"];
            suggestions.add({"id": placeId, "name": placeName});
          }
          return suggestions;
        } else {
          print(response);
          throw LocationAutoCompleteRequestFailure();
        }
      }
    } on LocationAutoCompleteRequestFailure catch (e) {
      print(e.toString());
      throw LocationAutoCompleteRequestFailure();
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  Future<http.Response?> locationAutoCompleteRequest(
      String query, String? longitude, String? latitude) async {
    try {
      final url =
          Uri.parse('https://places.googleapis.com/v1/places:autocomplete');

      final body = jsonEncode({
        "input": "$query",
        "locationBias": {
          "circle": {
            "center": {
              "latitude": latitude ?? "32.023150",
              "longitude": longitude ?? "35.876200",
            },
            "radius": 500.0
          }
        }
      });

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $googleMapsSessionToken',
        'X-Goog-User-Project': googleMapsProjectId,
      };

      final response = await http.post(url, headers: headers, body: body);
      return response;
    } catch (_) {
      throw LocationAutoCompleteRequestFailure();
    }
  }

  Future<Map<String, double>> getLocationFromPlaceId(String placeId) async {
    try {
      http.Response? response = await placeIdRequest(placeId);
      if (response != null) {
        if (response.statusCode == 200) {
          final decodedResult = jsonDecode(response.body)["location"];
          final double latitude = decodedResult["latitude"];
          final double longitude = decodedResult["longitude"];
          final result = {"latitude": latitude, "longitude": longitude};
          return result;
        } else {
          print(response);
          throw PlaceIdRequestFailure();
        }
      }
    } on PlaceIdRequestFailure catch (e) {
      throw PlaceIdRequestFailure();
    } catch (e) {
      print(e.toString());
    }
    return {};
  }

  Future<http.Response?> placeIdRequest(String placeId) async {
    try {
      final url = Uri.parse(
          'https://places.googleapis.com/v1/places/$placeId?fields=*');

      final headers = {
        'Authorization': 'Bearer $googleMapsSessionToken',
        'X-Goog-User-Project': googleMapsProjectId,
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);
      print(response);
      return response;
    } catch (_) {
      throw PlaceIdRequestFailure();
    }
  }

  Future<List<LatLng>> getRouteToDestination({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      print('Getting route from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');

      final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

      final body = jsonEncode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': origin.latitude,
              'longitude': origin.longitude
            }
          }
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destination.latitude,
              'longitude': destination.longitude
            }
          }
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'computeAlternativeRoutes': false,
        'routeModifiers': {
          'avoidTolls': false,
          'avoidHighways': false,
          'avoidFerries': false,
        },
        'languageCode': 'en-US',
        'units': 'METRIC'
      });

      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': googleMapsAPIKey,
        'X-Goog-FieldMask': 'routes.polyline.encodedPolyline'
      };

      print('Sending route request...');
      final response = await http.post(url, headers: headers, body: body);
      print('Route response status: ${response.statusCode}');
      print('Route response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['routes'] != null &&
            decodedResponse['routes'].isNotEmpty &&
            decodedResponse['routes'][0]['polyline'] != null) {

          final encodedPolyline = decodedResponse['routes'][0]['polyline']['encodedPolyline'];
          print('Successfully decoded polyline');
          return decodePolyline(encodedPolyline);
        } else {
          print('No route found in response');
          throw RouteRequestFailure();
        }
      } else {
        print('Route request failed with status: ${response.statusCode}');
        throw RouteRequestFailure();
      }
    } catch (e) {
      print('Error getting route: $e');
      throw RouteRequestFailure();
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  static const double earthRadius = 6371000; // meters

  double calculateArrivalTime(List<LatLng> route, {double averageSpeed = 40}) {
    double totalDistance = 0;

    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(
        route[i].latitude,
        route[i].longitude,
        route[i + 1].latitude,
        route[i + 1].longitude,
      );
    }

    // Convert distance to kilometers and speed to km/h
    double distanceKm = totalDistance / 1000;
    // Return time in minutes
    return (distanceKm / averageSpeed) * 60;
  }

  double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    double lat1Rad = lat1 * pi / 180;
    double lat2Rad = lat2 * pi / 180;
    double deltaLat = (lat2 - lat1) * pi / 180;
    double deltaLon = (lon2 - lon1) * pi / 180;

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
