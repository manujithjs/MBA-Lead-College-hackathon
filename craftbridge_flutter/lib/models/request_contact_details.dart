import 'package:cloud_firestore/cloud_firestore.dart';

class RequestContactDetails {
  final String requestId;
  final String clientId;
  final String contactPhone;
  final String contactAddress;
  final String? preferredWindow;

  const RequestContactDetails({
    required this.requestId,
    required this.clientId,
    required this.contactPhone,
    required this.contactAddress,
    this.preferredWindow,
  });

  factory RequestContactDetails.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RequestContactDetails(
      requestId: (data['requestId'] as String?) ?? '',
      clientId: (data['clientId'] as String?) ?? '',
      contactPhone: (data['contactPhone'] as String?) ?? '',
      contactAddress: (data['contactAddress'] as String?) ?? '',
      preferredWindow: data['preferredWindow'] as String?,
    );
  }
}
