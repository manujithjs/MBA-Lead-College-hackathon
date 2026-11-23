import 'package:cloud_firestore/cloud_firestore.dart';

class PracticalCertificate {
  final String certId;
  final String providerId;
  final String holderName;
  final String trade;
  final int trainingDays;
  final int practicalScore;
  final String centerName;
  final List<String> modulesCompleted;
  final String status; // 'pending' | 'verified' | 'revoked'
  final String issuedDate;
  final String? verifiedBy;

  const PracticalCertificate({
    required this.certId,
    required this.providerId,
    required this.holderName,
    required this.trade,
    required this.trainingDays,
    required this.practicalScore,
    required this.centerName,
    required this.modulesCompleted,
    required this.status,
    required this.issuedDate,
    this.verifiedBy,
  });

  factory PracticalCertificate.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawModules = data['modulesCompleted'];
    return PracticalCertificate(
      certId: (data['certId'] as String?) ?? doc.id,
      providerId: (data['providerId'] as String?) ?? '',
      holderName: (data['holderName'] as String?) ?? '',
      trade: (data['trade'] as String?) ?? '',
      trainingDays: (data['trainingDays'] as num?)?.toInt() ?? 20,
      practicalScore: (data['practicalScore'] as num?)?.toInt() ?? 90,
      centerName: (data['centerName'] as String?) ?? 'Softi Practical Academy',
      modulesCompleted: rawModules is List
          ? rawModules.map((e) => e.toString()).toList()
          : const ['Practical Safety', 'Field Fault Diagnostics'],
      status: (data['status'] as String?) ?? 'pending',
      issuedDate: (data['issuedDate'] as String?) ?? '2026-10-01',
      verifiedBy: data['verifiedBy'] as String?,
    );
  }
}
