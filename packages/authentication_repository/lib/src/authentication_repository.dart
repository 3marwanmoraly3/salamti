import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:dbcrypt/dbcrypt.dart';
import 'apiKeys.dart';

class SendPhoneNumberFailure implements Exception {
  @override
  String toString() {
    return "Sending phone number failed.";
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

class ChangePasswordFailure implements Exception {
  @override
  String toString() {
    return "Failed to change password.";
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

  Future<void> requestAdditionalEmergency(
      {required questions, required answers, required latitude, required longitude}) async {
    CollectionReference requests =
        FirebaseFirestore.instance.collection('requests');
    CollectionReference cases = FirebaseFirestore.instance.collection('cases');
    CollectionReference esps = FirebaseFirestore.instance.collection('esps');
    final civilianId = await getCivilianId();

    Map<String, int> dispatch = {};

    // Process each question to determine dispatch
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
        bool answer = answers[index];
        if (answer) {
          question['boolOr']['dispatch'].forEach((unit, count) {
            dispatch[unit] = (dispatch[unit] ?? 0) + (count as int);
          });
        }
      } else if (question.containsKey('numAdd')) {
        int numberOfPeople = answers[index];
        int perPerson = question['numAdd']['perPerson'];
        int minimumPeople = question['numAdd']['minimumPeople'];

        // Subtract minimum people to account for initial dispatch
        int additionalPeople = numberOfPeople - minimumPeople;
        if (additionalPeople > 0) {
          int requiredUnits = (additionalPeople / perPerson).ceil();
          question['numAdd']['dispatch'].forEach((unit, count) {
            dispatch[unit] = (dispatch[unit] ?? 0) + (requiredUnits * (count as int));
          });
        }
      }
    });

    final questionsAndAnswers = questions!.asMap().entries.map((entry) {
      String questionText = '';
      if (entry.value.containsKey('string')) {
        questionText = entry.value['string'] is List
            ? entry.value['string'][0]
            : entry.value['string']['questions'][0];
      } else if (entry.value.containsKey('bool')) {
        questionText = entry.value['bool']['question'];
      } else if (entry.value.containsKey('boolMore')) {
        questionText = entry.value['boolMore']['question'];
      } else if (entry.value.containsKey('boolAdd')) {
        questionText = entry.value['boolAdd']['question'];
      } else if (entry.value.containsKey('boolOr')) {
        questionText = entry.value['boolOr']['questions'][0];
      } else if (entry.value.containsKey('num')) {
        questionText = entry.value['num']['question'];
      } else if (entry.value.containsKey('numAdd')) {
        questionText = entry.value['numAdd']['question'];
      }

      dynamic answer = answers[entry.key];
      if (answer is bool) {
        answer = answer ? 'Yes' : 'No';
      }

      return {
        'Question': questionText,
        'Answer': answers.containsKey(entry.key) ? answer : null,
      };
    }).where((qa) => qa['Answer'] != null).toList();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('CivilianID', isEqualTo: civilianId)
        .get();

    final requestId = querySnapshot.docs[0].id;
    final caseId = querySnapshot.docs[0]["CaseID"];
    List<String> espIds = List<String>.from(querySnapshot.docs[0]["ESPIDs"]);
    List<String> additionalESPs = await getNearestESPIds(dispatch: dispatch, latitude: latitude, longitude: longitude);

    espIds.addAll(additionalESPs);

    await cases.doc(caseId).update({
      'ESPIDs': espIds,
      'EmergencyDetails': questionsAndAnswers,
    });

    await requests.doc(requestId).update({
      'ESPIDs': espIds,
    });

    for (String espId in additionalESPs) {
      await esps.doc(espId).update({
        'Availability': 'occupied'
      });
    }
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
      await esps.doc(espId).update({
        'Availability': 'occupied'
      });
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
      String newPhone = '0$phone';
      String id = await getUserId() ?? "";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: id)
          .get();

      await checkEmergencyContactDoesNotExist(
          querySnapshot: querySnapshot, name: name, phone: newPhone, index: -1);

      DocumentReference docRef = querySnapshot.docs[0].reference;

      await docRef.update({
        'EmergencyContacts': FieldValue.arrayUnion([
          {'name': name, 'phone': newPhone}
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
      String newPhone = '0$phone';
      String id = await getUserId() ?? "";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: id)
          .get();

      await checkEmergencyContactDoesNotExist(
          querySnapshot: querySnapshot,
          name: name,
          phone: newPhone,
          index: index);

      DocumentReference docRef = querySnapshot.docs[0].reference;
      List<dynamic> contacts = querySnapshot.docs[0].get('EmergencyContacts');

      contacts[index] = {'name': name, 'phone': newPhone};
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
      String newPhone = '0$phone';
      String id = await getUserId() ?? "";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('civilians')
          .where('UserID', isEqualTo: id)
          .get();

      DocumentReference docRef = querySnapshot.docs[0].reference;

      await docRef.update({
        'EmergencyContacts': FieldValue.arrayRemove([
          {'name': name, 'phone': newPhone}
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
        if (contact["name"] == name) {
          throw EmergencyContactExists();
        }

        if (contact["phone"] == phone) {
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
      'Allergies': [],
      'Conditions': [],
      'EmergencyContacts': [],
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
