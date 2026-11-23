import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/academy_data.dart';
import '../../services/firebase_service.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  bool _seeding = false;
  String? _notice;

  Future<void> _seedRegistry() async {
    final fs = context.read<FirebaseService>();
    if (fs.user?.email == null) return;
    setState(() {
      _seeding = true;
      _notice = null;
    });
    final created = await AcademyDataSeeder.seedInitialAcademyRegistry(
      fs.db,
      fs.user!.email!,
    );
    setState(() {
      _seeding = false;
      _notice = created
          ? 'Seeded 5 verified Softi Academy vendors and sample 10–15 km customer requests.'
          : 'Registry already contains vendor records.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Verification Queue'),
        actions: [
          if (fs.providers.isEmpty)
            TextButton.icon(
              onPressed: _seeding ? null : _seedRegistry,
              icon: const Icon(Icons.storage),
              label: Text(_seeding ? 'Seeding...' : 'Seed Vendors'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_notice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: AppColors.emerald.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_notice!),
                ),
              ),
            ),
          ...fs.providers.map((prov) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prov.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Chip(label: Text(prov.verificationStatus.toUpperCase())),
                      ],
                    ),
                    Text(
                      '${prov.trade} · ${prov.zoneName} · Cert: ${prov.certificateId}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    Text(
                      'Course: ${prov.trainingDays}d · Practical Score: ${prov.practicalScore}%',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (prov.verificationStatus != 'verified')
                          FilledButton(
                            onPressed: () => fs.adminUpdateVerification(
                              providerDocId: prov.id,
                              certificateId: prov.certificateId,
                              nextStatus: 'verified',
                            ),
                            child: const Text('Verify'),
                          ),
                        const SizedBox(width: 8),
                        if (prov.verificationStatus != 'revoked')
                          OutlinedButton(
                            onPressed: () => fs.adminUpdateVerification(
                              providerDocId: prov.id,
                              certificateId: prov.certificateId,
                              nextStatus: 'revoked',
                            ),
                            child: const Text('Revoke'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
