import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccount {
  final String uid;
  final String displayName;
  final String email;
  final String? phone;
  final String portalType; // 'client' | 'provider'
  final String neighborhood;
  final double lat;
  final double lng;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserAccount({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phone,
    required this.portalType,
    required this.neighborhood,
    required this.lat,
    required this.lng,
    this.createdAt,
    this.updatedAt,
  });

  factory UserAccount.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserAccount(
      uid: (data['uid'] as String?) ?? doc.id,
      displayName: (data['displayName'] as String?) ?? 'CraftBridge Member',
      email: (data['email'] as String?) ?? '',
      phone: data['phone'] as String?,
      portalType: (data['portalType'] as String?) ?? 'client',
      neighborhood: (data['neighborhood'] as String?) ?? 'Indiranagar Central',
      lat: (data['lat'] as num?)?.toDouble() ?? 12.9784,
      lng: (data['lng'] as num?)?.toDouble() ?? 77.6408,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
