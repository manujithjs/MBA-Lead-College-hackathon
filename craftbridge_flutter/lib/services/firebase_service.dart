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

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: DefaultFirebaseOptions.firestoreDatabaseId,
  );

  User? _user;
  bool _authReady = false;
  UserAccount? _userAccount;
  String _activePortal = 'client'; // 'client' | 'provider'
  bool _authLoading = false;
  String? _authError;

  List<ProviderProfile> _providers = [];
  List<PracticalCertificate> _certificates = [];
  List<ServiceRequest> _openRequests = [];
  List<ServiceRequest> _clientRequests = [];
  List<ServiceRequest> _providerRequests = [];
  List<EscrowPayment> _payments = [];

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _providersSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _certsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _openReqSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _clientReqSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _provReqSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _paymentsSub;

  FirebaseService() {
    _init();
  }

  FirebaseFirestore get db => _db;
  User? get user => _user;
  bool get authReady => _authReady;
  UserAccount? get userAccount => _userAccount;
  String get activePortal => _activePortal;
  bool get authLoading => _authLoading;
  String? get authError => _authError;

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
        _userAccount = UserAccount.fromFirestore(snap);
        _activePortal = _userAccount!.portalType;
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
      final payload = <String, dynamic>{
        'uid': signedUser.uid,
        'displayName': safeName,
        'email': signedUser.email ?? '',
        'portalType': portalType,
        'neighborhood': defaultZone.name,
        'lat': defaultZone.lat,
        'lng': defaultZone.lng,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (phoneOverride != null && phoneOverride.trim().isNotEmpty) {
        payload['phone'] = ValidationUtils.sanitizeText(
          phoneOverride,
          ValidationUtils.phoneMax,
        );
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
  /// strictly adhering to `firestore.rules`.
  Future<String> createServiceRequest({
    required String title,
    required String description,
    required String trade,
    required String urgency,
    required ServiceZone zone,
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
    final maskedPreview =
        '${ValidationUtils.maskPhoneNumber(contactPhone)} · ${zone.name}';

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
      'urgency': urgency,
      'zoneName': zone.name,
      'lat': zone.lat,
      'lng': zone.lng,
      'maxRadiusKm': safeRadius,
      'budgetMin': safeMin,
      'budgetMax': safeMax,
      'estimatedBudget': estimated,
      'photos': [AssetImages.forTrade(trade)],
      'contactPreview': ValidationUtils.sanitizeText(maskedPreview, 100),
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

  /// Fetches PII-isolated customer contact details (allowed only for owning client, assigned provider, or admin)
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

  /// Registers a Vendor Partner profile & Practical Training Certificate in `pending` state.
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

  /// Provider accepts an open request (must have `/providers/{uid}` per `firestore.rules`)
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

  /// Provider advances job status: `accepted` -> `in_progress` -> `completed`
  Future<void> advanceJobStatus(ServiceRequest req, String nextStatus) async {
    await _db.collection('serviceRequests').doc(req.id).update({
      'status': nextStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Client cancels an open request
  Future<void> cancelServiceRequest(ServiceRequest req) async {
    await _db.collection('serviceRequests').doc(req.id).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Client authorizes escrow hold or releases final payout
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

  /// Client releases already-held escrow funds once job is completed
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

  /// Admin verifies or revokes a vendor & certificate
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
