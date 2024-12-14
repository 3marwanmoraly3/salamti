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

class GoogleMapsRepository {
  final String projectId = "organic-berm-430508-a2";

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
        'Authorization': 'Bearer $googleMapsAPIKey',
        'X-Goog-User-Project': projectId,
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
        'Authorization': 'Bearer $googleMapsAPIKey',
        'X-Goog-User-Project': projectId,
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);
      print(response);
      return response;
    } catch (_) {
      throw PlaceIdRequestFailure();
    }
  }
}
