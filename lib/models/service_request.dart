import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest {
  final String id;
  final String clientId;
  final String clientName;
  final String providerId;
  final String providerName;
  final String title;
  final String description;
  final String trade; // 'Electrical' | 'Plumbing' | 'Appliance Repair' | 'Cleaning'
  final String subService;
  final String urgency; // 'standard' | 'same_day' | 'emergency'
  final String scheduledDate;
  final String scheduledTime;
  final String zoneName;
  final double lat;
  final double lng;
  final double maxRadiusKm;
  final double budgetMin;
  final double budgetMax;
  final double estimatedBudget;
  final List<String> photos;
  final String contactPreview;
  final String status; // 'open' | 'accepted' | 'in_progress' | 'completed' | 'cancelled'
  final String paymentStatus; // 'unpaid' | 'escrow_held' | 'released'
  final String paymentTxnId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.providerId,
    required this.providerName,
    required this.title,
    required this.description,
    required this.trade,
    this.subService = '',
    required this.urgency,
    this.scheduledDate = '',
    this.scheduledTime = '',
    required this.zoneName,
    required this.lat,
    required this.lng,
    required this.maxRadiusKm,
    required this.budgetMin,
    required this.budgetMax,
    required this.estimatedBudget,
    required this.photos,
    required this.contactPreview,
    required this.status,
    required this.paymentStatus,
    required this.paymentTxnId,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawPhotos = data['photos'];
    return ServiceRequest(
      id: doc.id,
      clientId: (data['clientId'] as String?) ?? '',
      clientName: (data['clientName'] as String?) ?? 'Homeowner',
      providerId: (data['providerId'] as String?) ?? '',
      providerName: (data['providerName'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      trade: (data['trade'] as String?) ?? 'Electrical',
      subService: (data['subService'] as String?) ?? '',
      urgency: (data['urgency'] as String?) ?? 'standard',
      scheduledDate: (data['scheduledDate'] as String?) ?? '',
      scheduledTime: (data['scheduledTime'] as String?) ?? '',
      zoneName: (data['zoneName'] as String?) ?? 'Indiranagar Central',
      lat: (data['lat'] as num?)?.toDouble() ?? 12.9784,
      lng: (data['lng'] as num?)?.toDouble() ?? 77.6408,
      maxRadiusKm: (data['maxRadiusKm'] as num?)?.toDouble() ?? 12.0,
      budgetMin: (data['budgetMin'] as num?)?.toDouble() ?? 35.0,
      budgetMax: (data['budgetMax'] as num?)?.toDouble() ?? 75.0,
      estimatedBudget: (data['estimatedBudget'] as num?)?.toDouble() ?? 55.0,
      photos: rawPhotos is List
          ? rawPhotos.map((e) => e.toString()).toList()
          : const [],
      contactPreview: (data['contactPreview'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'open',
      paymentStatus: (data['paymentStatus'] as String?) ?? 'unpaid',
      paymentTxnId: (data['paymentTxnId'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
