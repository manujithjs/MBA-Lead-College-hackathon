import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/utils/geo_utils.dart';
import '../core/utils/validation_utils.dart';
import '../data/academy_data.dart';
import '../firebase_options.dart';
import '../models/escrow_payment.dart';
import '../models/practical_certificate.dart';
import '../models/provider_profile.dart';
import '../models/request_contact_details.dart';
import '../models/service_request.dart';
import '../models/user_account.dart';

/// Saved address model for the "Select Address" sheet (Home / Work / Others).
class SavedAddress {
  final String id;
  final String label; // 'Home' | 'Work' | 'Others'
  final String fullAddress;
  final double lat;
  final double lng;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  factory SavedAddress.fromMap(Map<String, dynamic> map) {
    return SavedAddress(
      id: (map['id'] ?? '').toString(),
      label: (map['label'] ?? 'Others').toString(),
      fullAddress: (map['fullAddress'] ?? '').toString(),
      lat: ((map['lat'] ?? 0) as num).toDouble(),
      lng: ((map['lng'] ?? 0) as num).toDouble(),
      isDefault: map['isDefault'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'fullAddress': fullAddress,
        'lat': lat,
        'lng': lng,
        'isDefault': isDefault,
      };

  SavedAddress copyWith({
    String? id,
    String? label,
    String? fullAddress,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class FirebaseService extends ChangeNotifier {
  static const List<SavedAddress> defaultSeedAddresses = [
    SavedAddress(
      id: 'ADDR_OTHERS_DEF',
      label: 'Others',
      fullAddress: '3rd Floor, RAMP1/2, Malaparamba, Kozhikode, Kerala, 673009',
      lat: 11.2828,
      lng: 75.7958,
      isDefault: true,
    ),
    SavedAddress(
      id: 'ADDR_WORK_DEF',
      label: 'Work',
      fullAddress: 'One, HV8G+8CF, Kazhakkoottam, Kerala, 695582',
      lat: 8.5686,
      lng: 76.8731,
      isDefault: false,
    ),
    SavedAddress(
      id: 'ADDR_HOME_DEF',
      label: 'Home',
      fullAddress: 'Nil, Sasthamangalam, Thiruvananthapuram, Kerala, India',
      lat: 8.5117,
      lng: 76.9654,
      isDefault: false,
    ),
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: DefaultFirebaseOptions.firestoreDatabaseId,
  );

  User? _user;
  bool _authReady = false;
  UserAccount? _userAccount;
  String _activePortal = 'client'; // 'client' | 'provider'
  String _homeTab = 'Service'; // 'Product' | 'Service' (matches template toggle)
  String? _gender;
  List<SavedAddress> _savedAddresses = [];
  bool _authLoading = false;
  String? _authError;

  List<ProviderProfile> _providers = [];
  List<PracticalCertificate> _certificates = [];
  List<ServiceRequest> _openRequests = [];
  List<ServiceRequest> _clientRequests = [];
  List<ServiceRequest> _providerRequests = [];
  List<EscrowPayment> _payments = [];

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot>? _providersSub;
  StreamSubscription<QuerySnapshot>? _certsSub;
  StreamSubscription<DocumentSnapshot>? _userDocSub;
  StreamSubscription<QuerySnapshot>? _openReqSub;
  StreamSubscription<QuerySnapshot>? _clientReqSub;
  StreamSubscription<QuerySnapshot>? _provReqSub;
  StreamSubscription<QuerySnapshot>? _paymentsSub;

  FirebaseService() {
    _init();
  }

  FirebaseFirestore get db => _db;
  User? get user => _user;
  bool get authReady => _authReady;
  UserAccount? get userAccount => _userAccount;
  String get activePortal => _activePortal;
  String get homeTab => _homeTab;
  String? get gender => _gender;
  List<SavedAddress> get savedAddresses => _savedAddresses;
  bool get authLoading => _authLoading;
  String? get authError => _authError;

  SavedAddress get selectedAddress {
    if (_savedAddresses.isEmpty) return defaultSeedAddresses.first;
    return _savedAddresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _savedAddresses.first,
    );
  }

  bool get isAdmin =>
      _user != null &&
      _user!.email == 'manujith.js@lead.ac.in' &&
      _user!.emailVerified;

  List<ProviderProfile> get providers => _providers;
  List<PracticalCertificate> get certificates => _certificates;
  List<ServiceRequest> get openRequests => _openRequests;
  List<ServiceRequest> get clientRequests => _clientRequests;
  List<ServiceRequest> get providerRequests => _providerRequests;
  List<EscrowPayment> get payments => _payments;

  ProviderProfile? get myProviderProfile {
    if (_user == null) return null;
    for (final p in _providers) {
      if (p.uid == _user!.uid || p.id == _user!.uid) {
        return p;
      }
    }
    return null;
  }

  void _init() {
    _listenPublicCollections();
    _authSub = _auth.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;
      _authReady = true;
      notifyListeners();

      await _cancelPrivateListeners();

      if (firebaseUser == null) {
        _userAccount = null;
        _gender = null;
        _savedAddresses = [];
        _openRequests = [];
        _clientRequests = [];
        _providerRequests = [];
        _payments = [];
        notifyListeners();
        return;
      }

      if (firebaseUser.email == 'manujith.js@lead.ac.in' &&
          firebaseUser.emailVerified) {
        unawaited(
          AcademyDataSeeder.seedInitialAcademyRegistry(
              _db, firebaseUser.email!),
        );
      }

      _listenAuthenticatedCollections(firebaseUser.uid);
    });
  }

  void _listenPublicCollections() {
    _providersSub = _db
        .collection('providers')
        .where('verificationStatus',
            whereIn: ['verified', 'pending', 'revoked'])
        .snapshots()
        .listen((snap) {
          _providers =
              snap.docs.map((d) => ProviderProfile.fromFirestore(d)).toList();
          notifyListeners();
        });

    _certsSub = _db
        .collection('certificates')
        .where('status', whereIn: ['verified', 'pending', 'revoked'])
        .snapshots()
        .listen((snap) {
          _certificates = snap.docs
              .map((d) => PracticalCertificate.fromFirestore(d))
              .toList();
          notifyListeners();
        });
  }

  void _listenAuthenticatedCollections(String uid) {
    _userDocSub = _db.collection('users').doc(uid).snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data() ?? const <String, dynamic>{};
        _userAccount = UserAccount.fromFirestore(snap);
        _activePortal = _userAccount!.portalType;
        _gender = (data['gender'] as String?)?.trim();

        final rawAddresses = data['savedAddresses'];
        if (rawAddresses is List) {
          _savedAddresses = rawAddresses
              .whereType()
              .map((m) => SavedAddress.fromMap(Map<String, dynamic>.from(m)))
              .toList();
        } else {
          _savedAddresses = [];
        }
        notifyListeners();
      }
    });

    _openReqSub = _db
        .collection('serviceRequests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((snap) {
      _openRequests =
          snap.docs.map((d) => ServiceRequest.fromFirestore(d)).toList();
      notifyListeners();
    });

    _clientReqSub = _db
        .collection('serviceRequests')
        .where('clientId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      _clientRequests =
          snap.docs.map((d) => ServiceRequest.fromFirestore(d)).toList();
      notifyListeners();
    });

    _provReqSub = _db
        .collection('serviceRequests')
        .where('providerId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      _providerRequests =
          snap.docs.map((d) => ServiceRequest.fromFirestore(d)).toList();
      notifyListeners();
    });

    final paymentField =
        _activePortal == 'provider' ? 'providerId' : 'clientId';
    _paymentsSub = _db
        .collection('payments')
        .where(paymentField, isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      _payments = snap.docs.map((d) => EscrowPayment.fromFirestore(d)).toList();
      notifyListeners();
    });
  }

  Future<void> _cancelPrivateListeners() async {
    await _userDocSub?.cancel();
    await _openReqSub?.cancel();
    await _clientReqSub?.cancel();
    await _provReqSub?.cancel();
    await _paymentsSub?.cancel();
  }

  void setHomeTab(String tab) {
    if (tab != 'Product' && tab != 'Service') return;
    _homeTab = tab;
    notifyListeners();
  }

  void setActivePortal(String portal) {
    _activePortal = portal;
    notifyListeners();
    if (_user != null) {
      _db.collection('users').doc(_user!.uid).update({
        'portalType': portal,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((_) {});
    }
  }

  Future<void> updateProfileDetails({
    required String displayName,
    String? phone,
    String? gender,
  }) async {
    if (_user == null) return;
    final cleanName = ValidationUtils.sanitizeText(
      displayName,
      ValidationUtils.displayNameMax,
    );
    await _user!.updateDisplayName(cleanName);

    final updates = <String, dynamic>{
      'displayName': cleanName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (phone != null) {
      updates['phone'] =
          ValidationUtils.sanitizeText(phone, ValidationUtils.phoneMax);
    }
    if (gender != null && gender.trim().isNotEmpty) {
      updates['gender'] = ValidationUtils.sanitizeText(gender, 30);
    }

    await _db.collection('users').doc(_user!.uid).update(updates);
  }

  Future<void> addSavedAddress({
    required String label,
    required String fullAddress,
    required double lat,
    required double lng,
    bool makeDefault = true,
  }) async {
    if (_user == null) return;
    final id = 'ADDR_${DateTime.now().millisecondsSinceEpoch}';
    final updatedList = [
      for (final item in _savedAddresses)
        makeDefault ? item.copyWith(isDefault: false) : item,
      SavedAddress(
        id: id,
        label: ValidationUtils.sanitizeText(label, 30),
        fullAddress: ValidationUtils.sanitizeText(fullAddress, 240),
        lat: lat,
        lng: lng,
        isDefault: makeDefault || _savedAddresses.isEmpty,
      ),
    ];

    final chosen = updatedList.firstWhere(
      (a) => a.isDefault,
      orElse: () => updatedList.first,
    );

    await _db.collection('users').doc(_user!.uid).update({
      'savedAddresses': updatedList.map((e) => e.toMap()).toList(),
      'neighborhood': chosen.fullAddress,
      'lat': chosen.lat,
      'lng': chosen.lng,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> selectDefaultAddress(String addressId) async {
    if (_savedAddresses.isEmpty) {
      _savedAddresses = List.from(defaultSeedAddresses);
    }
    final updatedList = _savedAddresses
        .map((a) => a.copyWith(isDefault: a.id == addressId))
        .toList();
    _savedAddresses = updatedList;
    notifyListeners();
    if (_user == null) return;
    final chosen = updatedList.firstWhere(
      (a) => a.isDefault,
      orElse: () => updatedList.first,
    );

    await _db.collection('users').doc(_user!.uid).update({
      'savedAddresses': updatedList.map((e) => e.toMap()).toList(),
      'neighborhood': chosen.fullAddress,
      'lat': chosen.lat,
      'lng': chosen.lng,
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((_) {});
  }

  Future<void> deleteSavedAddress(String addressId) async {
    if (_savedAddresses.isEmpty) {
      _savedAddresses = List.from(defaultSeedAddresses);
    }
    var remaining =
        _savedAddresses.where((a) => a.id != addressId).toList();
    if (remaining.isNotEmpty && !remaining.any((a) => a.isDefault)) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    _savedAddresses = remaining;
    notifyListeners();
    if (_user == null) return;

    final updates = <String, dynamic>{
      'savedAddresses': remaining.map((e) => e.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (remaining.isNotEmpty) {
      final def = remaining.firstWhere((a) => a.isDefault);
      updates['neighborhood'] = def.fullAddress;
      updates['lat'] = def.lat;
      updates['lng'] = def.lng;
    }

    await _db.collection('users').doc(_user!.uid).update(updates).catchError((_) {});
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required String portalType,
  }) async {
    _authLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (cred.user != null) {
        await _ensureUserDocument(cred.user!, portalType: portalType);
      }
      _activePortal = portalType;
      return true;
    } on FirebaseAuthException catch (e) {
      _authError = e.message ?? 'Email sign-in failed.';
      return false;
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
    required String phone,
    required String portalType,
    required ServiceZone zone,
    String? gender,
  }) async {
    _authLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (cred.user != null) {
        await cred.user!.updateDisplayName(displayName.trim());
        await _ensureUserDocument(
          cred.user!,
          portalType: portalType,
          displayNameOverride: displayName,
          phoneOverride: phone,
          zoneOverride: zone,
          genderOverride: gender,
        );
      }
      _activePortal = portalType;
      return true;
    } on FirebaseAuthException catch (e) {
      _authError = e.message ?? 'Account registration failed.';
      return false;
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle({required String portalType}) async {
    _authLoading = true;
    _authError = null;
    notifyListeners();
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        final cred = await _auth.signInWithPopup(provider);
        if (cred.user != null) {
          await _ensureUserDocument(cred.user!, portalType: portalType);
        }
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          _authLoading = false;
          notifyListeners();
          return false;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final cred = await _auth.signInWithCredential(credential);
        if (cred.user != null) {
          await _ensureUserDocument(cred.user!, portalType: portalType);
        }
      }
      _activePortal = portalType;
      return true;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureUserDocument(
    User signedUser, {
    required String portalType,
    String? displayNameOverride,
    String? phoneOverride,
    ServiceZone? zoneOverride,
    String? genderOverride,
  }) async {
    final userRef = _db.collection('users').doc(signedUser.uid);
    final snap = await userRef.get();
    final defaultZone = zoneOverride ?? serviceZones.first;
    final safeName = ValidationUtils.sanitizeText(
      displayNameOverride ??
          signedUser.displayName ??
          signedUser.email?.split('@').first ??
          'CraftBridge Member',
      ValidationUtils.displayNameMax,
    );

    if (!snap.exists) {
      final initialAddress = SavedAddress(
        id: 'ADDR_DEFAULT',
        label: 'Others',
        fullAddress: defaultZone.name,
        lat: defaultZone.lat,
        lng: defaultZone.lng,
        isDefault: true,
      );
      final payload = <String, dynamic>{
        'uid': signedUser.uid,
        'displayName': safeName,
        'email': signedUser.email ?? '',
        'portalType': portalType,
        'neighborhood': defaultZone.name,
        'lat': defaultZone.lat,
        'lng': defaultZone.lng,
        'savedAddresses': [initialAddress.toMap()],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (phoneOverride != null && phoneOverride.trim().isNotEmpty) {
        payload['phone'] = ValidationUtils.sanitizeText(
          phoneOverride,
          ValidationUtils.phoneMax,
        );
      }
      if (genderOverride != null && genderOverride.trim().isNotEmpty) {
        payload['gender'] = ValidationUtils.sanitizeText(genderOverride, 30);
      }
      await userRef.set(payload);
    } else {
      await userRef.update({
        'portalType': portalType,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateUserZone(ServiceZone zone) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).update({
      'neighborhood': zone.name,
      'lat': zone.lat,
      'lng': zone.lng,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Creates `/serviceRequests/{requestId}` + PII-isolated `/contactDetails/private`
  /// with optional sub-service, scheduled date/time, and photo attachments.
  Future<String> createServiceRequest({
    required String title,
    required String description,
    required String trade,
    String? subService,
    required String urgency,
    required ServiceZone zone,
    String? customAddress,
    String? scheduledDate,
    String? scheduledTime,
    List<String>? photoUrls,
    required double maxRadiusKm,
    required double budgetMin,
    required double budgetMax,
    required String contactPhone,
    required String contactAddress,
    required String preferredWindow,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('You must be signed in to post a service request.');
    }

    final reqRef = _db.collection('serviceRequests').doc();
    final safeMin = ValidationUtils.clampDouble(
      budgetMin,
      ValidationUtils.budgetMin,
      ValidationUtils.budgetMax,
    );
    final safeMax = ValidationUtils.clampDouble(
      math.max(budgetMin, budgetMax),
      safeMin,
      ValidationUtils.budgetMax,
    );
    final estimated = ((safeMin + safeMax) / 2.0 * 100).round() / 100.0;
    final safeRadius = ValidationUtils.clampDouble(
      maxRadiusKm,
      ValidationUtils.radiusMinKm,
      ValidationUtils.radiusMaxKm,
    );
    final displayLocation = (customAddress != null && customAddress.trim().isNotEmpty)
        ? customAddress.trim()
        : zone.name;
    final maskedPreview =
        '${ValidationUtils.maskPhoneNumber(contactPhone)} · $displayLocation';

    final photos = (photoUrls != null && photoUrls.isNotEmpty)
        ? photoUrls.take(3).toList()
        : [AssetImages.forTrade(trade)];

    final batch = _db.batch();
    batch.set(reqRef, {
      'clientId': currentUser.uid,
      'clientName': ValidationUtils.sanitizeText(
        _userAccount?.displayName ?? currentUser.displayName ?? 'Homeowner',
        ValidationUtils.displayNameMax,
      ),
      'providerId': '',
      'providerName': '',
      'title': ValidationUtils.sanitizeText(title, ValidationUtils.titleMax),
      'description': ValidationUtils.sanitizeText(
        description,
        ValidationUtils.descriptionMax,
      ),
      'trade': trade,
      'subService': ValidationUtils.sanitizeText(subService ?? '', 80),
      'urgency': urgency,
      'scheduledDate': ValidationUtils.sanitizeText(scheduledDate ?? '', 40),
      'scheduledTime': ValidationUtils.sanitizeText(scheduledTime ?? '', 40),
      'zoneName': ValidationUtils.sanitizeText(displayLocation, 200),
      'lat': zone.lat,
      'lng': zone.lng,
      'maxRadiusKm': safeRadius,
      'budgetMin': safeMin,
      'budgetMax': safeMax,
      'estimatedBudget': estimated,
      'photos': photos,
      'contactPreview': ValidationUtils.sanitizeText(maskedPreview, 120),
      'status': 'open',
      'paymentStatus': 'unpaid',
      'paymentTxnId': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(reqRef.collection('contactDetails').doc('private'), {
      'requestId': reqRef.id,
      'clientId': currentUser.uid,
      'contactPhone': ValidationUtils.sanitizeText(
        contactPhone,
        ValidationUtils.phoneMax,
      ),
      'contactAddress': ValidationUtils.sanitizeText(
        contactAddress,
        300,
      ),
      'preferredWindow': ValidationUtils.sanitizeText(
        preferredWindow,
        100,
      ),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return reqRef.id;
  }

  Future<RequestContactDetails?> getPrivateContactDetails(
      String requestId) async {
    try {
      final doc = await _db
          .collection('serviceRequests')
          .doc(requestId)
          .collection('contactDetails')
          .doc('private')
          .get();
      if (!doc.exists) return null;
      return RequestContactDetails.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  Future<void> submitVendorCredential({
    required String displayName,
    required String trade,
    required int trainingDays,
    required String certificateId,
    required String trainingCenter,
    required int practicalScore,
    required double hourlyRate,
    required ServiceZone zone,
    required String bio,
    required List<String> modulesCompleted,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Sign in required.');

    final cleanCertId = certificateId.trim().toUpperCase();
    if (!ValidationUtils.certIdPattern.hasMatch(cleanCertId)) {
      throw Exception(
          'Certificate ID must match SOFTI-YYYY-XX-NNN (e.g. SOFTI-2026-EL-701).');
    }

    final batch = _db.batch();
    batch.set(_db.collection('providers').doc(currentUser.uid), {
      'uid': currentUser.uid,
      'displayName': ValidationUtils.sanitizeText(
          displayName, ValidationUtils.displayNameMax),
      'avatarUrl': AssetImages.forTrade(trade),
      'trade': trade,
      'trainingDays': ValidationUtils.clampInt(
        trainingDays,
        ValidationUtils.trainingDaysMin,
        ValidationUtils.trainingDaysMax,
      ),
      'certificateId': cleanCertId,
      'trainingCenter': ValidationUtils.sanitizeText(trainingCenter, 100),
      'practicalScore': ValidationUtils.clampInt(
        practicalScore,
        ValidationUtils.practicalScoreMin,
        ValidationUtils.practicalScoreMax,
      ),
      'verificationStatus': isAdmin ? 'verified' : 'pending',
      'isAvailable': true,
      'hourlyRate': ValidationUtils.clampDouble(
        hourlyRate,
        ValidationUtils.hourlyRateMin,
        ValidationUtils.hourlyRateMax,
      ),
      'completedJobs': 0,
      'rating': 5.0,
      'zoneName': zone.name,
      'lat': zone.lat,
      'lng': zone.lng,
      'bio': ValidationUtils.sanitizeText(bio, ValidationUtils.bioMax),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('certificates').doc(cleanCertId), {
      'certId': cleanCertId,
      'providerId': currentUser.uid,
      'holderName': ValidationUtils.sanitizeText(
          displayName, ValidationUtils.displayNameMax),
      'trade': trade,
      'trainingDays': ValidationUtils.clampInt(
        trainingDays,
        ValidationUtils.trainingDaysMin,
        ValidationUtils.trainingDaysMax,
      ),
      'practicalScore': ValidationUtils.clampInt(
        practicalScore,
        ValidationUtils.practicalScoreMin,
        ValidationUtils.practicalScoreMax,
      ),
      'centerName': ValidationUtils.sanitizeText(trainingCenter, 100),
      'modulesCompleted': modulesCompleted.isEmpty
          ? ['Practical Safety & Calibration', 'Live Fault Diagnostics']
          : modulesCompleted,
      'status': isAdmin ? 'verified' : 'pending',
      'issuedDate': DateTime.now().toIso8601String().split('T').first,
      if (isAdmin) 'verifiedBy': currentUser.email ?? 'Admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> acceptServiceRequest(ServiceRequest req) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Sign in required.');
    final prov = myProviderProfile;
    if (prov == null) {
      throw Exception(
          'Complete Practical Lab registration before accepting jobs.');
    }

    await _db.collection('serviceRequests').doc(req.id).update({
      'status': 'accepted',
      'providerId': currentUser.uid,
      'providerName': prov.displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> advanceJobStatus(ServiceRequest req, String nextStatus) async {
    await _db.collection('serviceRequests').doc(req.id).update({
      'status': nextStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelServiceRequest(ServiceRequest req) async {
    await _db.collection('serviceRequests').doc(req.id).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> authorizeEscrowPayment({
    required ServiceRequest request,
    required String method,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Sign in required.');

    final amount = request.estimatedBudget;
    final platformFee = (amount * 0.06 * 100).round() / 100.0;
    final providerPayout = ((amount - platformFee) * 100).round() / 100.0;
    final targetStatus =
        request.status == 'completed' ? 'released' : 'escrow_held';

    final randHex = math.Random()
        .nextInt(0xFFFFFFFF)
        .toRadixString(16)
        .toUpperCase()
        .padLeft(8, '0');
    final txnId =
        'TXN-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}-$randHex';
    final hashDigest = sha256
        .convert(utf8.encode('$txnId:${request.id}:${currentUser.uid}:$amount'))
        .toString()
        .substring(0, 32)
        .toUpperCase();

    final batch = _db.batch();
    batch.set(_db.collection('payments').doc(txnId), {
      'txnId': txnId,
      'requestId': request.id,
      'clientId': currentUser.uid,
      'providerId': request.providerId,
      'amount': amount,
      'platformFee': platformFee,
      'providerPayout': providerPayout,
      'method': method,
      'status': targetStatus,
      'receiptHash': hashDigest,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('serviceRequests').doc(request.id), {
      'paymentStatus': targetStatus,
      'paymentTxnId': txnId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return txnId;
  }

  Future<void> releaseHeldEscrow(ServiceRequest request) async {
    if (request.paymentTxnId.isEmpty) return;
    final batch = _db.batch();
    batch.update(_db.collection('payments').doc(request.paymentTxnId), {
      'status': 'released',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('serviceRequests').doc(request.id), {
      'paymentStatus': 'released',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> adminUpdateVerification({
    required String providerDocId,
    required String certificateId,
    required String nextStatus, // 'verified' | 'revoked'
  }) async {
    if (!isAdmin || _user == null) return;
    final batch = _db.batch();
    batch.update(_db.collection('providers').doc(providerDocId), {
      'verificationStatus': nextStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final certRef = _db.collection('certificates').doc(certificateId);
    final certSnap = await certRef.get();
    if (certSnap.exists) {
      batch.update(certRef, {
        'status': nextStatus,
        'verifiedBy': _user!.email ?? 'Softi Practical Board',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<PracticalCertificate?> lookupCertificate(String rawId) async {
    final cleaned = rawId.trim().toUpperCase();
    if (!ValidationUtils.certIdPattern.hasMatch(cleaned)) {
      return null;
    }
    final snap = await _db.collection('certificates').doc(cleaned).get();
    if (!snap.exists) return null;
    return PracticalCertificate.fromFirestore(snap);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _providersSub?.cancel();
    _certsSub?.cancel();
    _cancelPrivateListeners();
    super.dispose();
  }
}