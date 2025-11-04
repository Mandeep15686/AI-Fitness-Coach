import 'package:flutter/material.dart';
import '../services/privacy_service.dart';

class PrivacyProvider with ChangeNotifier {
  final PrivacyService _privacyService = PrivacyService();
  bool _consentGiven = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get consentGiven => _consentGiven;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PrivacyProvider() {
    loadConsentStatus();
  }

  Future<void> loadConsentStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _consentGiven = await _privacyService.getConsentStatus();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateConsentStatus(bool consent) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _privacyService.updateConsentStatus(consent);
      _consentGiven = consent;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _privacyService.deleteUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> exportUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _privacyService.exportUserData();
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
