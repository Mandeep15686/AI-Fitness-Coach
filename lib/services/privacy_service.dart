import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';

class PrivacyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's consent status
  Future<bool> getConsentStatus() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection(AppConstants.usersCollection).doc(user.uid).get();
    return doc.data()?['consentGiven'] ?? false;
  }

  // Update user's consent status
  Future<void> updateConsentStatus(bool consent) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).update({
      'consentGiven': consent,
    });
  }

  // Request data deletion
  Future<void> deleteUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Delete user data from Firestore
    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).delete();

    // 2. Delete user account from Firebase Auth
    await user.delete();
  }

  // Export user data
  Future<Map<String, dynamic>> exportUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc = await _firestore.collection(AppConstants.usersCollection).doc(user.uid).get();
    return doc.data() ?? {};
  }
}
