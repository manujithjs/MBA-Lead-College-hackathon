import 'package:cloud_firestore/cloud_firestore.dart';

class EscrowPayment {
  final String id;
  final String txnId;
  final String requestId;
  final String clientId;
  final String providerId;
  final double amount;
  final double platformFee;
  final double providerPayout;
  final String method; // 'upi' | 'card' | 'netbanking' | 'wallet'
  final String status; // 'escrow_held' | 'released'
  final String receiptHash;
  final DateTime? createdAt;

  const EscrowPayment({
    required this.id,
    required this.txnId,
    required this.requestId,
    required this.clientId,
    required this.providerId,
    required this.amount,
    required this.platformFee,
    required this.providerPayout,
    required this.method,
    required this.status,
    required this.receiptHash,
    this.createdAt,
  });

  factory EscrowPayment.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EscrowPayment(
      id: doc.id,
      txnId: (data['txnId'] as String?) ?? doc.id,
      requestId: (data['requestId'] as String?) ?? '',
      clientId: (data['clientId'] as String?) ?? '',
      providerId: (data['providerId'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      platformFee: (data['platformFee'] as num?)?.toDouble() ?? 0,
      providerPayout: (data['providerPayout'] as num?)?.toDouble() ?? 0,
      method: (data['method'] as String?) ?? 'upi',
      status: (data['status'] as String?) ?? 'escrow_held',
      receiptHash: (data['receiptHash'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
