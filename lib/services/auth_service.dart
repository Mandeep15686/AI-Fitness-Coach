import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'encryption_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryptionService;

  String? _verificationId;

  AuthService(this._encryptionService);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required int age,
    required double height,
    required double weight,
    required String fitnessGoal,
    required String fitnessLevel,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        age: age,
        height: height,
        weight: weight,
        fitnessGoal: fitnessGoal,
        fitnessLevel: fitnessLevel,
        createdAt: DateTime.now(),
      );

      // Encrypt data before saving
      final userMap = user.toMap();
      userMap['age'] = _encryptionService.encrypt(user.age.toString());
      userMap['height'] = _encryptionService.encrypt(user.height.toString());
      userMap['weight'] = _encryptionService.encrypt(user.weight.toString());

      // Save user data to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userMap);

      return user;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Decrypt data if it's a string, otherwise use the raw value
        if (data['age'] is String) {
          data['age'] = int.parse(_encryptionService.decrypt(data['age']));
        }
        if (data['height'] is String) {
          data['height'] = double.parse(_encryptionService.decrypt(data['height']));
        }
        if (data['weight'] is String) {
          data['weight'] = double.parse(_encryptionService.decrypt(data['weight']));
        }

        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Decrypt data if it's a string, otherwise use the raw value
        if (data['age'] is String) {
          data['age'] = int.parse(_encryptionService.decrypt(data['age']));
        }
        if (data['height'] is String) {
          data['height'] = double.parse(_encryptionService.decrypt(data['height']));
        }
        if (data['weight'] is String) {
          data['weight'] = double.parse(_encryptionService.decrypt(data['weight']));
        }

        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      final userMap = user.copyWith(updatedAt: DateTime.now()).toMap();

      // Encrypt data before updating
      userMap['age'] = _encryptionService.encrypt(user.age.toString());
      userMap['height'] = _encryptionService.encrypt(user.height.toString());
      userMap['weight'] = _encryptionService.encrypt(user.weight.toString());

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(userMap);
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Send OTP to phone
  Future<void> sendOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification
        await linkPhoneNumber(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Phone verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Verify OTP and link phone number
  Future<void> verifyOtpAndLink(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Verification ID not found.');
    }
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    await linkPhoneNumber(credential);
  }

  // Link phone number to user account
  Future<void> linkPhoneNumber(PhoneAuthCredential credential) async {
    try {
      await _auth.currentUser!.linkWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to link phone number: ${e.toString()}');
    }
  }
}
