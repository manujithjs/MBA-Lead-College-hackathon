import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/service_request.dart';
import '../services/firebase_service.dart';

class PaymentCheckoutSheet extends StatefulWidget {
  final ServiceRequest request;

  const PaymentCheckoutSheet({super.key, required this.request});

  @override
  State<PaymentCheckoutSheet> createState() => _PaymentCheckoutSheetState();
}

class _PaymentCheckoutSheetState extends State<PaymentCheckoutSheet> {
  String _method = 'upi';
  final _detailController = TextEditingController(text: 'client@okaxis');
  bool _submitting = false;
  String? _error;

  void _selectMethod(String next) {
    setState(() {
      _method = next;
      _error = null;
      if (next == 'upi') _detailController.text = 'client@okaxis';
      if (next == 'card') _detailController.text = '4242 4242 4242 4242';
      if (next == 'netbanking') _detailController.text = 'HDFC NetBanking';
      if (next == 'wallet') _detailController.text = 'Softi Instant Wallet';
    });
  }

  Future<void> _authorize() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final fs = context.read<FirebaseService>();
      final txnId = await fs.authorizeEscrowPayment(
        request: widget.request,
        method: _method,
      );
      if (mounted) {
        Navigator.pop(context, txnId);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.request.estimatedBudget;
    final fee = (amount * 0.06 * 100).round() / 100.0;
    final payout = ((amount - fee) * 100).round() / 100.0;
    final isRelease = widget.request.status == 'completed';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: AppColors.emerald, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Escrow Protected Settlement',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.emerald,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            isRelease ? 'Complete Final Payout' : 'Fund Job Escrow',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          Text(
            widget.request.title,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _row('Service Job Estimate', '\$${amount.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                _row('Academy & Escrow Fee (6%)', '\$${fee.toStringAsFixed(2)}'),
                const Divider(height: 18),
                _row(
                  'Provider Guaranteed Payout',
                  '\$${payout.toStringAsFixed(2)}',
                  bold: true,
                  valueColor: AppColors.emerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'upi', label: Text('UPI')),
              ButtonSegment(value: 'card', label: Text('Card')),
              ButtonSegment(value: 'netbanking', label: Text('Bank')),
              ButtonSegment(value: 'wallet', label: Text('Wallet')),
            ],
            selected: {_method},
            onSelectionChanged: (s) => _selectMethod(s.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detailController,
            decoration: InputDecoration(
              labelText: _method == 'upi'
                  ? 'UPI Handle'
                  : _method == 'card'
                      ? 'Card Number'
                      : 'Account / Provider',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.red)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.indigo,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _submitting ? null : _authorize,
            child: Text(
              _submitting
                  ? 'Authorizing...'
                  : isRelease
                      ? 'Pay & Release \$${amount.toStringAsFixed(2)}'
                      : 'Authorize \$${amount.toStringAsFixed(2)} Escrow',
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String val,
      {bool bold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? AppColors.navy : AppColors.textMuted,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.navy,
          ),
        ),
      ],
    );
  }
}
