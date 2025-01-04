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

class AuthenticationRepository {
  AuthenticationRepository({
    this.verificationId = '',
    this.authKey = 'is_authenticated',
    this.userIdKey = 'userIdKey',
  });

  String verificationId;
  String authKey;
  String userIdKey;

  final _authenticationUserController =
      StreamController<String>.broadcast();

  Stream<String> get authenticationUser =>
      _authenticationUserController.stream;

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(authKey) ?? false;
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey) ?? "";
  }

  Future<void> authenticateUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(authKey, true);
    await prefs.setString(userIdKey, userId);
    _authenticationUserController.add(userId);
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
  }) async {
    try {
      await checkPhoneDoesNotExist(phone: phone);
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

  Future<void> signUp(
      {required String name,
      required String phone,
      required String password,
      required String smsCode}) async {
    try {
      checkSmsCode(smsCode: smsCode);
      await addUserToCollection(
          name: name, phone: phone, password: password);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Username', isEqualTo: phone)
          .get();

      final userId = querySnapshot.docs[0].id;

      authenticateUser(userId);
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

  Future<void> addUserToCollection(
      {required String name,
      required String phone,
      required password}) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    String userId = users.doc().id;

    String hashedPassword = DBCrypt().hashpw(password, DBCrypt().gensalt());

    await users.doc(userId).set({
      'Username': phone,
      'Password': hashedPassword,
      'LoginAttempts': 0,
      'SuspensionDate': Timestamp.now(),
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

      if (querySnapshot.docs.isEmpty) {
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

      authenticateUser(userId);
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
      _authenticationUserController.add("");
    } catch (_) {
      throw LogOutFailure();
    }
  }
}
