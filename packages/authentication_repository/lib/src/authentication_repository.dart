import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:dbcrypt/dbcrypt.dart';
import 'apiKeys.dart';

class SendPhoneNumberFailure implements Exception {
  @override
  String toString() {
    return "Sending phone number failed.";
  }
}

class RetrievingInformationFailure implements Exception {
  @override
  String toString() {
    return "Failed to retrieve information.";
  }
}

class LoginFailure implements Exception {
  @override
  String toString() {
    return "Login failed.";
  }
}

class LogOutFailure implements Exception {
  @override
  String toString() {
    return "Logout failed.";
  }
}

class ChangePhoneNumberFailure implements Exception {
  @override
  String toString() {
    return "Failed to change phone number.";
  }
}

class ChangePasswordFailure implements Exception {
  @override
  String toString() {
    return "Failed to change password.";
  }
}

class CheckPasswordFailure implements Exception {
  @override
  String toString() {
    return "Unable to verify password.";
  }
}

class NationalIdExists implements Exception {
  @override
  String toString() {
    return "National id exists.";
  }
}

class PhoneExists implements Exception {
  @override
  String toString() {
    return "Phone number exists.";
  }
}

class PhoneDoesNotExist implements Exception {
  @override
  String toString() {
    return "Phone number does not exist.";
  }
}

class WrongSmsCode implements Exception {
  @override
  String toString() {
    return "Wrong sms code.";
  }
}

class WrongCredentials implements Exception {
  @override
  String toString() {
    return "Wrong phone number or password.";
  }
}

class AccountSuspended implements Exception {
  @override
  String toString() {
    return "Account temporarily suspended for too many attempts.";
  }
}

class AddEmergencyContactFailure implements Exception {
  @override
  String toString() {
    return "Failed to add contact.";
  }
}

class EmergencyContactExists implements Exception {
  @override
  String toString() {
    return "Contact with same number already exists.";
  }
}

class EmergencyContactNameExists implements Exception {
  @override
  String toString() {
    return "Contact with same name already exists.";
  }
}

class AuthenticationRepository {
  AuthenticationRepository({
    this.verificationId = '',
    this.authKey = 'is_authenticated',
    this.userIdKey = 'userIdKey',
    this.civilianIdKey = 'civilianIdKey',
  });

  String verificationId;
  String authKey;
  String userIdKey;
  String civilianIdKey;

  final _authenticationUserController =
      StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get authenticationUser =>
      _authenticationUserController.stream;

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(authKey) ?? false;
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey) ?? "";
  }

  Future<String?> getCivilianId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(civilianIdKey) ?? "";
  }

  Future<void> authenticateUser(String userId, String civilianId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(authKey, true);
    await prefs.setString(userIdKey, userId);
    await prefs.setString(civilianIdKey, civilianId);
    final userAndCivilianId = {"userId": userId, "civilianId": civilianId};
    _authenticationUserController.add(userAndCivilianId);
  }

  Stream<List<Map<String, dynamic>>> streamEspLocations(
      List<String> espIds, String caseId) {
    if (espIds.isEmpty) {
      return Stream.value([]);
    }

    try {
      final espStream = FirebaseFirestore.instance
          .collection('esps')
          .where(FieldPath.documentId, whereIn: espIds)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'location': data['Location'],
            'type': data['ESPType'],
          };
        }).toList();
      });

      final caseStream = FirebaseFirestore.instance
          .collection('cases')
          .doc(caseId)
          .snapshots()
          .map((doc) {
        final arrivalTimeList = List<Map<String, dynamic>>.from(
            doc.data()?['ESPsArrivalTime'] ?? []);
        final arrivedEspIds =
            arrivalTimeList.map((map) => map['ESPID'] as String).toList();
        return arrivedEspIds;
      });

      return CombineLatestStream.combine2(
        espStream,
        caseStream,
        (List<Map<String, dynamic>> esps, List<String> arrivedEspIds) {
          final result = esps.map((esp) {
            final arrived = arrivedEspIds.contains(esp['id']);

            return {
              ...esp,
              'arrived': arrived,
            };
          }).toList();

          return result;
        },
      ).handleError((error) {
        print('Error in ESP location stream: $error');
        return [];
      });
    } catch (e, stackTrace) {
      print('Error setting up ESP location stream: $e');
      print('Stack trace: $stackTrace');
      return Stream.value([]);
    }
  }

  Future<Map<String, dynamic>?> getEspDetails(String espId) async {
    try {
      final espDoc =
          await FirebaseFirestore.instance.collection('esps').doc(espId).get();

      if (!espDoc.exists) return null;

      return {
        'id': espDoc.id,
        'location': espDoc.data()?['Location'],
        'type': espDoc.data()?['ESPType'],
        'status': espDoc.data()?['Status'],
      };
    } catch (e) {
      print('Error getting ESP details: $e');
      return null;
    }
  }

  Future<bool> checkEspArrived(String espId, String caseId) async {
    try {
      final caseDoc = await FirebaseFirestore.instance
          .collection('cases')
          .doc(caseId)
          .get();

      final arrivedEsps =
          List<String>.from(caseDoc.data()?['ESPsArrivalTime'] ?? []);
      return arrivedEsps.contains(espId);
    } catch (e) {
      print('Error checking ESP arrival: $e');
      return false;
    }
  }

  Future<List<String>> requestAdditionalEmergency(
      {required questions,
      required answers,
      required latitude,
      required longitude}) async {
    CollectionReference requests =
        FirebaseFirestore.instance.collection('requests');
    CollectionReference cases = FirebaseFirestore.instance.collection('cases');
    CollectionReference esps = FirebaseFirestore.instance.collection('esps');
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');
    final civilianId = await getCivilianId();

    Map<String, int> dispatch = {};

    // Process dispatch logic
    questions!.asMap().forEach((index, question) {
      if (!answers.containsKey(index)) return;

      if (question.containsKey('boolAdd')) {
        bool answer = answers[index];
        if (answer) {
          question['boolAdd']['dispatch'].forEach((unit, count) {
            dispatch[unit] = (dispatch[unit] ?? 0) + (count as int);
          });
        }
      } else if (question.containsKey('boolOr')) {
        Map<int, bool> answersMap = answers[index];
        bool hasPositiveAnswer =
            answersMap.values.any((value) => value == true);
        if (hasPositiveAnswer && question['boolOr'].containsKey('dispatch')) {
          question['boolOr']['dispatch'].forEach((unit, count) {
            dispatch[unit] = (dispatch[unit] ?? 0) + (count as int);
          });
        }
      } else if (question.containsKey('numAdd')) {
        int numberOfPeople = answers[index];
        int perPerson = question['numAdd']['perPerson'];
        int minimumPeople = question['numAdd']['minimumPeople'];

        int additionalPeople = numberOfPeople - minimumPeople;
        if (additionalPeople > 0) {
          int requiredUnits = (additionalPeople / perPerson).ceil();
          question['numAdd']['dispatch'].forEach((unit, count) {
            dispatch[unit] =
                (dispatch[unit] ?? 0) + (requiredUnits * (count as int));
          });
        }
      }
    });

    // Process questions and answers for submission
    final questionsAndAnswers = (questions as List<dynamic>)
        .asMap()
        .entries
        .expand<Map<String, String>>((entry) {
          final index = entry.key;
          final question = entry.value;
          final answerValue = answers[index];

          if (answerValue == null) return const <Map<String, String>>[];

          if (question.containsKey('boolMore')) {
            final mainQuestion = question['boolMore']['question'] as String;
            final mainAnswer =
                (answerValue as Map<String, dynamic>)['mainAnswer'] as bool;
            final subAnswers =
                (answerValue['subAnswers'] as Map<String, dynamic>?) ?? {};

            final result = <Map<String, String>>[
              {
                'Question': mainQuestion,
                'Answer': mainAnswer ? 'Yes' : 'No',
              }
            ];

            if (mainAnswer && question['boolMore']['subQuestions'] != null) {
              for (var subQ in question['boolMore']['subQuestions']) {
                if (subQ.containsKey('string')) {
                  final subQuestions =
                      subQ['string']['questions'] as List<String>;
                  for (var i = 0; i < subQuestions.length; i++) {
                    result.add({
                      'Question': subQuestions[i],
                      'Answer': subAnswers[i.toString()] ?? '',
                    });
                  }
                }
              }
            }

            return result;
          } else if (question.containsKey('string')) {
            final questions = question['string']['questions'] as List<String>;
            if (answerValue is Map) {
              return questions.asMap().entries.map((qEntry) {
                return {
                  'Question': qEntry.value,
                  'Answer': (answerValue[qEntry.key] ?? '').toString(),
                };
              });
            }
          } else if (question.containsKey('boolOr')) {
            final questions = question['boolOr']['questions'] as List<String>;
            if (answerValue is Map<int, bool>) {
              return questions.asMap().entries.map((qEntry) {
                final answer = answerValue[qEntry.key];
                return {
                  'Question': qEntry.value,
                  'Answer': answer != null ? (answer ? 'Yes' : 'No') : '',
                };
              });
            }
          } else if (question.containsKey('bool') ||
              question.containsKey('boolAdd')) {
            final questionText = question.containsKey('bool')
                ? question['bool']['question']
                : question['boolAdd']['question'];
            if (answerValue is bool) {
              return [
                {
                  'Question': questionText,
                  'Answer': answerValue ? 'Yes' : 'No',
                }
              ];
            }
          } else if (question.containsKey('num') ||
              question.containsKey('numAdd')) {
            final questionText = question.containsKey('num')
                ? question['num']['question']
                : question['numAdd']['question'];
            return [
              {
                'Question': questionText,
                'Answer': answerValue.toString(),
              }
            ];
          }

          return const <Map<String, String>>[];
        })
        .where((qa) => qa['Answer']!.isNotEmpty)
        .toList();

    // Continue with the rest of the submission process
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('CivilianID', isEqualTo: civilianId)
        .get();

    final requestId = querySnapshot.docs[0].id;
    final caseId = querySnapshot.docs[0]["CaseID"];
    List<String> espIds = List<String>.from(querySnapshot.docs[0]["ESPIDs"]);
    List<String> additionalESPs = await getNearestESPIds(
        dispatch: dispatch, latitude: latitude, longitude: longitude);

    espIds.addAll(additionalESPs);

    await cases.doc(caseId).update({
      'ESPIDs': espIds,
      'EmergencyDetails': questionsAndAnswers,
    });

    await requests.doc(requestId).update({
      'ESPIDs': espIds,
    });

    for (String espId in additionalESPs) {
      await esps.doc(espId).update({'Availability': 'occupied'});
    }

    await civilians.doc(civilianId).update({'InEmergency': 'waiting'});

    return espIds;
  }

  Future<void> requestEmergency(
      {required String emergencyType,
      required double latitude,
      required double longitude,
      required Map<String, int> initialDispatch}) async {
    CollectionReference requests =
        FirebaseFirestore.instance.collection('requests');
    CollectionReference cases = FirebaseFirestore.instance.collection('cases');
    CollectionReference esps = FirebaseFirestore.instance.collection('esps');
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');
    String requestId = requests.doc().id;
    String caseId = cases.doc().id;
    final civilianId = await getCivilianId();

    List<String> espIds = await getNearestESPIds(
      dispatch: initialDispatch,
      latitude: latitude,
      longitude: longitude,
    );

    await cases.doc(caseId).set({
      'CivilianID': civilianId,
      'CivilianLocation': GeoPoint(latitude, longitude),
      'ESPIDs': espIds,
      'EmergencyType': emergencyType,
      'EmergencyDetails': [],
      'RequestTime': Timestamp.now(),
      'Status': 'ongoing',
      'ESPsArrivalTime': [],
      'ESPsFinishTime': [],
    });

    await requests.doc(requestId).set({
      'CaseID': caseId,
      'CivilianID': civilianId,
      'ESPIDs': espIds,
    });

    for (String espId in espIds) {
      await esps.doc(espId).update({'Availability': 'occupied'});
    }

    await civilians.doc(civilianId).update({'InEmergency': 'survey'});

    final civilianDoc = await civilians.doc(civilianId).get();
    final emergencyContacts = civilianDoc.get("EmergencyContacts");

    for (final contact in emergencyContacts) {
      String phone = "962${contact["Phone"]}";
      String name = civilianDoc.get("Name");
      String link =
          "https://www.google.com/maps/search/?api=1&query=${latitude}%2C${longitude}";
      String type = formatEmergencyType(emergencyType);
      sendNotification(phone: phone, type: type, link: link, name: name);
    }
  }

  String formatEmergencyType(String type) {
    switch (type) {
      case "medical":
        return "Medical";
      case "carCrash":
        return "Car Crash";
      case "fire":
        return "Fire";
      case "pedestrianCollision":
        return "Pedestrian Collision";
      case "armedThreat":
        return "Armed Threat";
      case "naturalDisaster":
        return "Natural Disaster";
      case "suicideAttempt":
        return "Suicide Attempt";
      case "abduction":
        return "Abduction";
      case "burglary":
        return "Burglary";
      case "assault":
        return "Assault";
      case "domesticViolence":
        return "Domestic Violence";
      case "trapped":
        return "Trapped";
      default:
        return type;
    }
  }

  Future<List<String>> getNearestESPIds({
    required Map<String, int> dispatch,
    required double latitude,
    required double longitude,
  }) async {
    List<String> espIds = [];

    await Future.wait(
      dispatch.entries.map((entry) async {
        String type = entry.key;
        int num = entry.value;

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('esps')
            .where('ESPType', isEqualTo: type)
            .where('Availability', isEqualTo: 'available')
            .get();

        final sortedESPs = sortESPsByDistance(
            querySnapshot.docs.toList(), latitude, longitude);

        for (int i = 0; i < num && i < sortedESPs.length; i++) {
          espIds.add(sortedESPs[i].id);
        }
      }),
    );

    return espIds;
  }

  List<dynamic> sortESPsByDistance(
      List<dynamic> esps, double targetLat, double targetLng) {
    esps.sort((a, b) {
      double distanceA = calculateDistance(targetLat, targetLng,
          a["Location"].latitude, a["Location"].longitude);
      double distanceB = calculateDistance(targetLat, targetLng,
          b["Location"].latitude, b["Location"].longitude);
      return distanceA.compareTo(distanceB);
    });

    return esps;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLng = (lng2 - lng1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<String> getEmergencyWaitingStatus() async {
    try {
      String civilianId = await getCivilianId() ?? "";
      CollectionReference civilians =
          FirebaseFirestore.instance.collection('civilians');

      final civilianDoc = await civilians.doc(civilianId).get();
      String emergencyWaitingStatus = civilianDoc["InEmergency"];

      return emergencyWaitingStatus;
    } catch (e) {
      print(e);
    }
    return "";
  }

  Future<Map<String, dynamic>> getInitialEmergencyWaitingDetails() async {
    String id = await getCivilianId() ?? "";

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('CivilianID', isEqualTo: id)
        .get();

    final espIds = querySnapshot.docs.first["ESPIDs"];
    final caseId = querySnapshot.docs.first["CaseID"];

    CollectionReference cases = FirebaseFirestore.instance.collection('cases');

    final caseDoc = await cases.doc(caseId).get();
    final emergencyType = caseDoc["EmergencyType"];
    final longitude = caseDoc["CivilianLocation"].longitude;
    final latitude = caseDoc["CivilianLocation"].latitude;

    return {
      "emergencyType": emergencyType,
      "espIds": espIds,
      "longitude": longitude,
      "latitude": latitude,
      "caseId": caseId
    };
  }

  Future<Map<String, dynamic>> getCivilianData() async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    final civilianDoc = await civilians.doc(id).get();
    final civilianData = civilianDoc.data();

    return civilianData as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPastActivities() async {
    String id = await getCivilianId() ?? "";

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('cases')
        .where('CivilianID', isEqualTo: id)
        .get();

    return querySnapshot.docs as List<dynamic>;
  }

  Future<List<dynamic>> getSavedLocations() async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
    FirebaseFirestore.instance.collection('civilians');

    final civilianDoc = await civilians.doc(id).get();
    final savedLocations = civilianDoc.get("SavedLocations");

    return savedLocations;
  }

  Future<void> updateGender(String gender) async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    await civilians.doc(id).update({"Gender": gender});
  }

  Future<void> updateBloodType(String bloodType) async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    await civilians.doc(id).update({"BloodType": bloodType});
  }

  Future<void> updateDOB(String dob) async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    await civilians.doc(id).update({"DOB": dob});
  }

  Future<void> updateConditions(List<dynamic> conditions) async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    await civilians.doc(id).update({"Conditions": conditions});
  }

  Future<void> updateAllergies(List<dynamic> allergies) async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    await civilians.doc(id).update({"Allergies": allergies});
  }

  Future<void> updateMedications(List<dynamic> medications) async {
    String id = await getCivilianId() ?? "";
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    await civilians.doc(id).update({"Medications": medications});
  }

  Future<List<dynamic>> getEmergencyContacts() async {
    String id = await getUserId() ?? "";

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('civilians')
        .where('UserID', isEqualTo: id)
        .get();

    return querySnapshot.docs[0].get('EmergencyContacts');
  }

  Future<void> addEmergencyContact(
      {required String name, required String phone}) async {
    try {
      String id = await getUserId() ?? "";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: id)
          .get();

      await checkEmergencyContactDoesNotExist(
          querySnapshot: querySnapshot, name: name, phone: phone, index: -1);

      DocumentReference docRef = querySnapshot.docs[0].reference;

      await docRef.update({
        'EmergencyContacts': FieldValue.arrayUnion([
          {'Name': name, 'Phone': phone}
        ]),
      });
    } on EmergencyContactExists catch (e) {
      print(e.toString());
      throw EmergencyContactExists();
    } on EmergencyContactNameExists catch (e) {
      print(e.toString());
      throw EmergencyContactNameExists();
    } catch (e) {
      print(e.toString());
      throw AddEmergencyContactFailure();
    }
  }

  Future<void> editEmergencyContact(
      {required String name, required String phone, required int index}) async {
    try {
      String id = await getUserId() ?? "";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: id)
          .get();

      await checkEmergencyContactDoesNotExist(
          querySnapshot: querySnapshot, name: name, phone: phone, index: index);

      DocumentReference docRef = querySnapshot.docs[0].reference;
      List<dynamic> contacts = querySnapshot.docs[0].get('EmergencyContacts');

      contacts[index] = {'Name': name, 'Phone': phone};
      await docRef.update({'EmergencyContacts': contacts});
    } on EmergencyContactExists catch (e) {
      print(e.toString());
      throw EmergencyContactExists();
    } on EmergencyContactNameExists catch (e) {
      print(e.toString());
      throw EmergencyContactNameExists();
    } catch (e) {
      print(e.toString());
      throw AddEmergencyContactFailure();
    }
  }

  Future<void> removeEmergencyContact(
      {required String name, required String phone}) async {
    try {
      String id = await getUserId() ?? "";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: id)
          .get();

      DocumentReference docRef = querySnapshot.docs[0].reference;

      await docRef.update({
        'EmergencyContacts': FieldValue.arrayRemove([
          {'Name': name, 'Phone': phone}
        ]),
      });
    } on EmergencyContactExists catch (e) {
      print(e.toString());
      throw EmergencyContactExists();
    } on EmergencyContactNameExists catch (e) {
      print(e.toString());
      throw EmergencyContactNameExists();
    } catch (e) {
      print(e.toString());
      throw AddEmergencyContactFailure();
    }
  }

  Future<void> checkEmergencyContactDoesNotExist(
      {required QuerySnapshot querySnapshot,
      required String name,
      required String phone,
      required int index}) async {
    List<dynamic> contacts = querySnapshot.docs[0].get('EmergencyContacts');

    for (int i = 0; i < contacts.length; i++) {
      if (i != index) {
        final contact = contacts[i];
        if (contact["Name"] == name) {
          throw EmergencyContactExists();
        }

        if (contact["Phone"] == phone) {
          throw EmergencyContactNameExists();
        }
      }
    }
  }

  Future<void> sendPhoneNumber({required String phone}) async {
    verificationId = (Random().nextInt(9000) + 1000).toString();
    final url =
        Uri.parse('https://graph.facebook.com/v20.0/341497479053548/messages');

    final headers = {
      'Authorization': 'Bearer $whatsappAPIKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "messaging_product": "whatsapp",
      "to": "962$phone",
      "type": "template",
      "template": {
        "name": "verification",
        "language": {"code": "en"},
        "components": [
          {
            "type": "body",
            "parameters": [
              {"type": "text", "text": verificationId}
            ]
          },
          {
            "type": "button",
            "sub_type": "url",
            "index": "0",
            "parameters": [
              {"type": "text", "text": verificationId}
            ]
          }
        ]
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Message sent successfully');
        print('Response: ${response.body}');
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (_) {
      throw SendPhoneNumberFailure();
    }
  }

  Future<void> sendNotification(
      {required String phone,
      required String name,
      required String type,
      required String link}) async {
    final url =
        Uri.parse('https://graph.facebook.com/v20.0/341497479053548/messages');

    final headers = {
      'Authorization': 'Bearer $whatsappAPIKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "messaging_product": "whatsapp",
      "to": phone,
      "type": "template",
      "template": {
        "name": "emergency_alert",
        "language": {"code": "en"},
        "components": [
          {
            "type": "body",
            "parameters": [
              {"type": "text", "text": name, "parameter_name": "user_name"},
              {
                "type": "text",
                "text": type,
                "parameter_name": "emergency_type"
              },
              {"type": "text", "text": link, "parameter_name": "location_link"},
            ]
          },
        ]
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Message sent successfully');
        print('Response: ${response.body}');
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (_) {
      throw SendPhoneNumberFailure();
    }
  }

  Future<void> changePasswordVerification({
    required String phone,
  }) async {
    try {
      await checkPhoneExists(phone: phone);
      await sendPhoneNumber(phone: phone);
    } on PhoneExists catch (e) {
      print(e.toString());
      throw PhoneDoesNotExist();
    } on SendPhoneNumberFailure catch (e) {
      print(e.toString());
      throw SendPhoneNumberFailure();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> getPhoneNumber() async {
    try {
      String id = await getUserId() ?? "";
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      final userDoc = await users.doc(id).get();
      final username = userDoc.get("Username") as String;
      return username;
    } catch (e) {
      print(e.toString());
      throw RetrievingInformationFailure();
    }
  }

  Future<void> changePhoneNumber({required String phone}) async {
    try {
      String id = await getUserId() ?? "";
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      await users.doc(id).update({"Username": phone});
    } catch (e) {
      print(e.toString());
      throw ChangePhoneNumberFailure();
    }
  }

  Future<void> changePhoneVerification(
      {required String phone}) async {
    try {
      checkPhoneDoesNotExist(phone: phone);
      await sendPhoneNumber(phone: phone);
    } on PhoneExists catch (e) {
      print(e.toString());
      throw PhoneExists();
    } on SendPhoneNumberFailure catch (e) {
      print(e.toString());
      throw SendPhoneNumberFailure();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> changePassword(
      {required String phone, required String password}) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Username', isEqualTo: phone)
          .get();

      var id = querySnapshot.docs[0].id;
      String hashedPassword = DBCrypt().hashpw(password, DBCrypt().gensalt());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'Password': hashedPassword});
    } catch (e) {
      print(e.toString());
      throw ChangePasswordFailure();
    }
  }

  Future<void> checkPassword(
      {required String password}) async {
    try {
      String id = await getUserId() ?? "";
      CollectionReference users =
      FirebaseFirestore.instance.collection('users');

      final userDoc = await users.doc(id).get();
      final hashedPassword = userDoc.get("Password");

      if(!DBCrypt().checkpw(password, hashedPassword)){
        throw WrongCredentials();
      }
    } on WrongCredentials catch (e) {
      print(e.toString());
      throw WrongCredentials();
    } catch (e) {
      print(e.toString());
      throw CheckPasswordFailure();
    }
  }

  Future<void> signUpVerification({
    required String phone,
    required nationalId,
  }) async {
    try {
      await checkPhoneDoesNotExist(phone: phone);
      await checkNationalIdDoesNotExist(nationalId: nationalId);
      await sendPhoneNumber(phone: phone);
    } on NationalIdExists catch (e) {
      print(e.toString());
      throw NationalIdExists();
    } on PhoneExists catch (e) {
      print(e.toString());
      throw PhoneExists();
    } on SendPhoneNumberFailure catch (e) {
      print(e.toString());
      throw SendPhoneNumberFailure();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signUp(
      {required String name,
      required String phone,
      required nationalId,
      required String password,
      required String smsCode}) async {
    try {
      checkSmsCode(smsCode: smsCode);
      await addUserToCollection(
          name: name, phone: phone, nationalId: nationalId, password: password);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Username', isEqualTo: phone)
          .get();

      final userId = querySnapshot.docs[0].id;

      querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: userId)
          .get();

      authenticateUser(userId, querySnapshot.docs[0].id);
    } on WrongSmsCode catch (e) {
      print(e.toString());
      throw WrongSmsCode();
    } catch (e) {
      print(e.toString());
    }
  }

  void checkSmsCode({required String smsCode}) {
    if (smsCode != verificationId) {
      throw WrongSmsCode();
    }
  }

  Future<void> checkPhoneExists({required String phone}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('Username', isEqualTo: phone)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw PhoneDoesNotExist();
    }
  }

  Future<void> checkPhoneDoesNotExist({required String phone}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('Username', isEqualTo: phone)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw PhoneExists();
    }
  }

  Future<void> checkNationalIdDoesNotExist({required String nationalId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('civilians')
        .where('NationalID', isEqualTo: nationalId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw NationalIdExists();
    }
  }

  Future<void> addUserToCollection(
      {required String name,
      required String phone,
      required nationalId,
      required password}) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    CollectionReference civilians =
        FirebaseFirestore.instance.collection('civilians');

    String userId = users.doc().id;
    String civilianId = civilians.doc().id;

    String hashedPassword = DBCrypt().hashpw(password, DBCrypt().gensalt());

    await users.doc(userId).set({
      'Username': phone,
      'UserType': 'c',
      'Password': hashedPassword,
      'LoginAttempts': 0,
      'SuspensionDate': Timestamp.now(),
    });

    await civilians.doc(civilianId).set({
      'UserID': userId,
      'Name': name,
      'NationalID': nationalId,
      'Gender': '',
      'DOB': '',
      'BloodType': '',
      'Allergies': [],
      'Conditions': [],
      'Medications': [],
      'EmergencyContacts': [],
      'SavedLocations': [],
      'InEmergency': "no",
    });
  }

  Future<void> loginVerification({
    required String phone,
    required String password,
  }) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Username', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isEmpty ||
          querySnapshot.docs[0]["UserType"] != "c") {
        throw WrongCredentials();
      }

      DateTime suspensionDate =
          querySnapshot.docs[0]["SuspensionDate"].toDate();

      if (suspensionDate.isAfter(DateTime.now())) {
        throw AccountSuspended();
      }

      if (!DBCrypt().checkpw(password, querySnapshot.docs[0]["Password"])) {
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');

        if (querySnapshot.docs[0]["LoginAttempts"] < 5) {
          final newLoginAttempts = querySnapshot.docs[0]["LoginAttempts"] + 1;
          await users.doc(querySnapshot.docs[0].id).update({
            'LoginAttempts': newLoginAttempts,
          });

          throw WrongCredentials();
        }

        DateTime dateNow = DateTime.now();
        DateTime newDate = dateNow.add(const Duration(hours: 1));

        await users.doc(querySnapshot.docs[0].id).update({
          'LoginAttempts': 0,
          'SuspensionDate': Timestamp.fromDate(newDate),
        });

        throw AccountSuspended();
      }
      await sendPhoneNumber(phone: phone);
    } on WrongCredentials catch (e) {
      print(e.toString());
      throw WrongCredentials();
    } on AccountSuspended catch (e) {
      print(e.toString());
      throw AccountSuspended();
    } on SendPhoneNumberFailure catch (e) {
      print(e.toString());
      throw SendPhoneNumberFailure();
    } catch (e) {
      print(e.toString());
      throw LoginFailure();
    }
  }

  Future<void> login({required String smsCode, required String phone}) async {
    try {
      checkSmsCode(smsCode: smsCode);

      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Username', isEqualTo: phone)
          .get();

      final userId = querySnapshot.docs[0].id;

      await users.doc(userId).update({
        'LoginAttempts': 0,
      });

      querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: userId)
          .get();

      authenticateUser(userId, querySnapshot.docs[0].id);
    } on WrongSmsCode catch (e) {
      print(e.toString());
      throw WrongSmsCode();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> logOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(authKey, false);
      await prefs.remove(userIdKey);
      await prefs.remove(civilianIdKey);
      _authenticationUserController.add({"userId": "", "civilianId": ""});
    } catch (_) {
      throw LogOutFailure();
    }
  }
}
