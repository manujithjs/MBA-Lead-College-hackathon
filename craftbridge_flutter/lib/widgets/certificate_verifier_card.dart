import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/practical_certificate.dart';
import '../services/firebase_service.dart';

class CertificateVerifierCard extends StatefulWidget {
  const CertificateVerifierCard({super.key});

  @override
  State<CertificateVerifierCard> createState() =>
      _CertificateVerifierCardState();
}

class _CertificateVerifierCardState extends State<CertificateVerifierCard> {
  final _queryController = TextEditingController(text: 'SOFTI-2026-EL-104');
  PracticalCertificate? _selectedCert;
  bool _searching = false;
  String? _message;

  Future<void> _lookup() async {
    final fs = context.read<FirebaseService>();
    final id = _queryController.text.trim().toUpperCase();
    setState(() {
      _searching = true;
      _message = null;
    });
    final found = await fs.lookupCertificate(id);
    setState(() {
      _searching = false;
      _selectedCert = found;
      if (found == null) {
        _message =
            'No certificate found for "$id". Format: SOFTI-YYYY-XX-NNN';
      }
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();
    final cert = _selectedCert ??
        fs.certificates
            .where((c) =>
                c.certId.toUpperCase() ==
                _queryController.text.trim().toUpperCase())
            .firstOrNull ??
        fs.certificates.firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendor Practical Credential Verifier',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Inspect 10–30 day hands-on practical training certificates in real time.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      hintText: 'SOFTI-2026-EL-104',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    minimumSize: const Size(110, 48),
                  ),
                  onPressed: _searching ? null : _lookup,
                  icon: const Icon(Icons.search, size: 18),
                  label: Text(_searching ? '...' : 'Verify'),
                ),
              ],
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                style: const TextStyle(fontSize: 12, color: AppColors.amber),
              ),
            ],
            if (fs.certificates.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: fs.certificates.take(6).map((c) {
                  return ActionChip(
                    label: Text(
                      c.certId,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onPressed: () {
                      setState(() {
                        _queryController.text = c.certId;
                        _selectedCert = c;
                        _message = null;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            if (cert != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.certId,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          cert.holderName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          '${cert.trade} · ${cert.centerName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(cert.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _metricBox('Training', '${cert.trainingDays} Days'),
                  const SizedBox(width: 8),
                  _metricBox('Score', '${cert.practicalScore}/100'),
                  const SizedBox(width: 8),
                  _metricBox('Issued', cert.issuedDate),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cert.modulesCompleted.map((m) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      m,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(val,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy)),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isVerified = status == 'verified';
    final isRevoked = status == 'revoked';
    final color = isVerified
        ? AppColors.emeraldDark
        : isRevoked
            ? AppColors.red
            : AppColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isVerified
            ? 'Verified'
            : isRevoked
                ? 'Revoked'
                : 'Pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
