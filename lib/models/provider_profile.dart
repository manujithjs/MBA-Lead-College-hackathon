import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderProfile {
  final String id;
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final String trade; // 'Electrical' | 'Plumbing' | 'Appliance Repair' | 'Cleaning'
  final int trainingDays;
  final String certificateId;
  final String trainingCenter;
  final int practicalScore;
  final String verificationStatus; // 'pending' | 'verified' | 'revoked'
  final bool isAvailable;
  final double hourlyRate;
  final int completedJobs;
  final double rating;
  final String zoneName;
  final double lat;
  final double lng;
  final String? bio;

  const ProviderProfile({
    required this.id,
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.trade,
    required this.trainingDays,
    required this.certificateId,
    required this.trainingCenter,
    required this.practicalScore,
    required this.verificationStatus,
    required this.isAvailable,
    required this.hourlyRate,
    required this.completedJobs,
    required this.rating,
    required this.zoneName,
    required this.lat,
    required this.lng,
    this.bio,
  });

  factory ProviderProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProviderProfile(
      id: doc.id,
      uid: (data['uid'] as String?) ?? doc.id,
      displayName: (data['displayName'] as String?) ?? 'Certified Vendor',
      avatarUrl: data['avatarUrl'] as String?,
      trade: (data['trade'] as String?) ?? 'Electrical',
      trainingDays: (data['trainingDays'] as num?)?.toInt() ?? 20,
      certificateId: (data['certificateId'] as String?) ?? '',
      trainingCenter:
          (data['trainingCenter'] as String?) ?? 'Softi Practical Lab',
      practicalScore: (data['practicalScore'] as num?)?.toInt() ?? 90,
      verificationStatus:
          (data['verificationStatus'] as String?) ?? 'pending',
      isAvailable: (data['isAvailable'] as bool?) ?? true,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 35.0,
      completedJobs: (data['completedJobs'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      zoneName: (data['zoneName'] as String?) ?? 'Indiranagar Central',
      lat: (data['lat'] as num?)?.toDouble() ?? 12.9784,
      lng: (data['lng'] as num?)?.toDouble() ?? 77.6408,
      bio: data['bio'] as String?,
    );
  }
}
