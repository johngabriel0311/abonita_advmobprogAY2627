import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Map<String, dynamic> data = {};

  // ============================================================
  // FIREBASE AUTHENTICATION
  // ============================================================

  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  // Stores the currently authenticated Firebase user.
  final ValueNotifier<auth.User?> currentUser = ValueNotifier<auth.User?>(null);

  UserService() {
    currentUser.value = _firebaseAuth.currentUser;

    _firebaseAuth.authStateChanges().listen((auth.User? user) {
      currentUser.value = user;
    });
  }

  // Get the current Firebase user.
  auth.User? get firebaseUser => _firebaseAuth.currentUser;

  // ============================================================
  // FIREBASE PROFILE STORAGE
  // ============================================================

  // Each Firebase account gets its own profile key.
  String _firebaseProfileKey(String uid) {
    return 'firebase_profile_$uid';
  }

  // ============================================================
  // FIREBASE SIGN IN
  // ============================================================

  Future<auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ============================================================
  // FIREBASE CREATE ACCOUNT
  // ============================================================

  Future<auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ============================================================
  // SAVE FIREBASE PROFILE
  // ============================================================

  Future<void> saveFirebaseProfile({
    required auth.User firebaseUser,
    required String firstName,
    required String lastName,
    required String age,
    required String contactNo,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final profile = {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'contactNo': contactNo,
      'username': username,
      'email': email,
      'gender': '',
      'image': firebaseUser.photoURL ?? '',
    };

    // Save the profile specifically for this Firebase UID.
    await prefs.setString(
      _firebaseProfileKey(firebaseUser.uid),
      jsonEncode(profile),
    );

    // Also load it as the current session.
    await _setCurrentFirebaseSession(
      firebaseUser: firebaseUser,
      profile: profile,
    );
  }

  // ============================================================
  // SAVE FIREBASE USER DATA AFTER LOGIN
  // ============================================================

  Future<void> saveFirebaseUserData(auth.User firebaseUser) async {
    final prefs = await SharedPreferences.getInstance();

    final profileKey = _firebaseProfileKey(firebaseUser.uid);
    final savedProfile = prefs.getString(profileKey);

    Map<String, dynamic> profile = {};

    if (savedProfile != null && savedProfile.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedProfile);

        if (decoded is Map<String, dynamic>) {
          profile = decoded;
        }
      } catch (_) {
        profile = {};
      }
    }

    // For an older Firebase account that has no profile yet,
    // only use Firebase's own information.
    final username = (profile['username']?.toString().isNotEmpty ?? false)
        ? profile['username'].toString()
        : (firebaseUser.displayName ?? '');

    profile['username'] = username;
    profile['email'] = firebaseUser.email ?? profile['email'] ?? '';
    profile['firstName'] = profile['firstName']?.toString() ?? '';
    profile['lastName'] = profile['lastName']?.toString() ?? '';
    profile['age'] = profile['age']?.toString() ?? '';
    profile['contactNo'] = profile['contactNo']?.toString() ?? '';
    profile['gender'] = profile['gender']?.toString() ?? '';
    profile['image'] =
        profile['image']?.toString() ?? (firebaseUser.photoURL ?? '');

    // Save the profile again under this Firebase UID.
    await prefs.setString(profileKey, jsonEncode(profile));

    // Load this account's profile into the current session.
    await _setCurrentFirebaseSession(
      firebaseUser: firebaseUser,
      profile: profile,
    );
  }

  // ============================================================
  // SET CURRENT FIREBASE SESSION
  // ============================================================

  Future<void> _setCurrentFirebaseSession({
    required auth.User firebaseUser,
    required Map<String, dynamic> profile,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // ------------------------------------------------------------
    // Remove information belonging to a previous account.
    // ------------------------------------------------------------

    await prefs.remove('id');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    // ------------------------------------------------------------
    // Current Firebase account.
    // ------------------------------------------------------------

    await prefs.setString('firebaseUid', firebaseUser.uid);

    await prefs.setString('username', profile['username']?.toString() ?? '');

    await prefs.setString(
      'email',
      profile['email']?.toString() ?? firebaseUser.email ?? '',
    );

    await prefs.setString('firstName', profile['firstName']?.toString() ?? '');

    await prefs.setString('lastName', profile['lastName']?.toString() ?? '');

    await prefs.setString('age', profile['age']?.toString() ?? '');

    await prefs.setString('contactNo', profile['contactNo']?.toString() ?? '');

    await prefs.setString('gender', profile['gender']?.toString() ?? '');

    await prefs.setString('image', profile['image']?.toString() ?? '');

    // Firebase UID is used as the current session token.
    await prefs.setString('token', firebaseUser.uid);
  }

  // ============================================================
  // UPDATE USERNAME
  // ============================================================

  Future<void> updateUsername({required String username}) async {
    final currentFirebaseUser = _firebaseAuth.currentUser;

    if (currentFirebaseUser == null) {
      throw Exception('No Firebase user is currently signed in.');
    }

    // Update Firebase display name.
    await currentFirebaseUser.updateDisplayName(username);

    final prefs = await SharedPreferences.getInstance();

    // Update current session username.
    await prefs.setString('username', username);

    // Update this account's saved profile.
    final profileKey = _firebaseProfileKey(currentFirebaseUser.uid);
    final savedProfile = prefs.getString(profileKey);

    Map<String, dynamic> profile = {};

    if (savedProfile != null && savedProfile.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedProfile);

        if (decoded is Map<String, dynamic>) {
          profile = decoded;
        }
      } catch (_) {
        profile = {};
      }
    }

    profile['username'] = username;
    profile['email'] = profile['email'] ?? currentFirebaseUser.email ?? '';
    profile['firstName'] = profile['firstName'] ?? '';
    profile['lastName'] = profile['lastName'] ?? '';
    profile['age'] = profile['age'] ?? '';
    profile['contactNo'] = profile['contactNo'] ?? '';
    profile['gender'] = profile['gender'] ?? '';
    profile['image'] = profile['image'] ?? (currentFirebaseUser.photoURL ?? '');

    await prefs.setString(profileKey, jsonEncode(profile));
  }

  // ============================================================
  // FIREBASE SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    // Remove only the current session.
    // Per-account Firebase profiles remain saved.
    await logout();
  }

  // ============================================================
  // DELETE FIREBASE ACCOUNT
  // ============================================================

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final auth.User? currentFirebaseUser = _firebaseAuth.currentUser;

    if (currentFirebaseUser == null) {
      throw Exception('No Firebase user is currently signed in.');
    }

    final auth.AuthCredential credential = auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    // Re-authenticate before deleting.
    await currentFirebaseUser.reauthenticateWithCredential(credential);

    final prefs = await SharedPreferences.getInstance();

    // Delete this Firebase account's local profile.
    await prefs.remove(_firebaseProfileKey(currentFirebaseUser.uid));

    // Delete Firebase account.
    await currentFirebaseUser.delete();

    // Sign out from Firebase.
    await _firebaseAuth.signOut();

    // Clear current session.
    await clearUserData();
  }

  // ============================================================
  // CHANGE FIREBASE PASSWORD
  // ============================================================

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    final auth.User? currentFirebaseUser = _firebaseAuth.currentUser;

    if (currentFirebaseUser == null) {
      throw Exception('No Firebase user is currently signed in.');
    }

    final auth.AuthCredential credential = auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    // Re-authenticate before changing password.
    await currentFirebaseUser.reauthenticateWithCredential(credential);

    // Update password.
    await currentFirebaseUser.updatePassword(newPassword);
  }

  // ============================================================
  // DUMMYJSON LOGIN
  // ============================================================

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      await saveUserData(data);

      return data;
    } else {
      throw Exception(response.body);
    }
  }

  // ============================================================
  // SAVE DUMMYJSON USER DATA
  // ============================================================

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final user = User.fromJson(userData);

    // Remove any Firebase session information.
    await prefs.remove('firebaseUid');

    await prefs.setInt('id', user.id);

    await prefs.setString('username', user.username);

    await prefs.setString('email', user.email);

    await prefs.setString('firstName', user.firstName);

    await prefs.setString('lastName', user.lastName);

    await prefs.setString('gender', user.gender);

    await prefs.setString('image', user.image);

    await prefs.setString('accessToken', user.accessToken);

    await prefs.setString('refreshToken', user.refreshToken);

    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  // ============================================================
  // GET SAVED USER DATA
  // ============================================================

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      // DummyJSON information.
      'id': prefs.getInt('id') ?? 0,

      'username': prefs.getString('username') ?? '',

      'email': prefs.getString('email') ?? '',

      'firstName': prefs.getString('firstName') ?? '',

      'lastName': prefs.getString('lastName') ?? '',

      'gender': prefs.getString('gender') ?? '',

      'image': prefs.getString('image') ?? '',

      'accessToken': prefs.getString('accessToken') ?? '',

      'refreshToken': prefs.getString('refreshToken') ?? '',

      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',

      // Firebase information.
      'firebaseUid': prefs.getString('firebaseUid') ?? '',

      // Signup information.
      'age': prefs.getString('age') ?? '',

      'contactNo': prefs.getString('contactNo') ?? '',
    };
  }

  // ============================================================
  // GET USER MODEL
  // ============================================================

  Future<User> getUser() async {
    final userData = await getUserData();

    return User.fromJson(userData);
  }

  // ============================================================
  // CHECK LOGIN STATUS
  // ============================================================

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    // Check DummyJSON access token.
    final accessToken = prefs.getString('accessToken');

    if (accessToken != null && accessToken.isNotEmpty) {
      return true;
    }

    // Check current Firebase user first.
    if (_firebaseAuth.currentUser != null) {
      return true;
    }

    // Check local Firebase token.
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      return true;
    }

    return false;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ----------------------------------------------------------
      // Remove ONLY the current session/profile data.
      // ----------------------------------------------------------

      await prefs.remove('id');
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove('firstName');
      await prefs.remove('lastName');
      await prefs.remove('gender');
      await prefs.remove('image');
      await prefs.remove('age');
      await prefs.remove('contactNo');

      // Authentication/session information.
      await prefs.remove('token');
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('firebaseUid');

      // ----------------------------------------------------------
      // IMPORTANT:
      //
      // We DO NOT remove:
      //
      // firebase_profile_<UID>
      //
      // because those belong to individual Firebase accounts.
      // ----------------------------------------------------------
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }

  // ============================================================
  // CLEAR ALL CURRENT USER DATA
  // ============================================================

  // Used when the currently logged-in account is deleted.
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('id');
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove('firstName');
      await prefs.remove('lastName');
      await prefs.remove('gender');
      await prefs.remove('image');
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('token');
      await prefs.remove('firebaseUid');
      await prefs.remove('age');
      await prefs.remove('contactNo');
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }
}
