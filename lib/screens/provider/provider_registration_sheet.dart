import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../services/firebase_service.dart';

class ProviderRegistrationSheet extends StatefulWidget {
  const ProviderRegistrationSheet({super.key});

  @override
  State<ProviderRegistrationSheet> createState() =>
      _ProviderRegistrationSheetState();
}

class _ProviderRegistrationSheetState extends State<ProviderRegistrationSheet> {
  final _nameCtrl = TextEditingController();
  final _certCtrl = TextEditingController(text: 'SOFTI-2026-EL-701');
  final _centerCtrl =
      TextEditingController(text: 'East Metro Practical Trade Campus');
  final _daysCtrl = TextEditingController(text: '24');
  final _scoreCtrl = TextEditingController(text: '93');
  final _rateCtrl = TextEditingController(text: '36');
  final _bioCtrl = TextEditingController(
      text: 'Certified practical technician ready for 10–15 km local dispatch.');
  String _trade = 'Electrical';
  ServiceZone _zone = serviceZones.first;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final fs = context.read<FirebaseService>();
    _nameCtrl.text =
        fs.userAccount?.displayName ?? fs.user?.displayName ?? 'Partner Tech';
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final fs = context.read<FirebaseService>();
      await fs.submitVendorCredential(
        displayName: _nameCtrl.text,
        trade: _trade,
        trainingDays: int.tryParse(_daysCtrl.text) ?? 24,
        certificateId: _certCtrl.text,
        trainingCenter: _centerCtrl.text,
        practicalScore: int.tryParse(_scoreCtrl.text) ?? 90,
        hourlyRate: double.tryParse(_rateCtrl.text) ?? 35,
        zone: _zone,
        bio: _bioCtrl.text,
        modulesCompleted: const [
          'Core Safety & Calibration',
          'Live Fault Diagnostics',
          'Capstone Practical Assessment',
        ],
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _certCtrl.dispose();
    _centerCtrl.dispose();
    _daysCtrl.dispose();
    _scoreCtrl.dispose();
    _rateCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollCtrl) {
        return ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Practical Lab Credential Gate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Submit your 10–30 day practical academy certificate to unlock live customer leads.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Technician Full Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _trade,
              decoration: const InputDecoration(labelText: 'Certified Trade'),
              items: ValidationUtils.validTrades
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _trade = v ?? 'Electrical'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _certCtrl,
              decoration: const InputDecoration(
                labelText: 'Certificate ID (SOFTI-YYYY-XX-NNN)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _centerCtrl,
              decoration:
                  const InputDecoration(labelText: 'Practical Training Center'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _daysCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Days (10–30)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _scoreCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Score (60–100)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _rateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rate \$/hr'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceZone>(
              initialValue: _zone,
              decoration: const InputDecoration(labelText: 'Base Dispatch Zone'),
              items: serviceZones
                  .map((z) => DropdownMenuItem(value: z, child: Text(z.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _zone = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Technical Bio'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.emeraldDark,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _submitting ? null : _submit,
              child: Text(
                _submitting
                    ? 'Registering...'
                    : 'Submit Certificate & Unlock Radar',
              ),
            ),
          ],
        );
      },
    );
  }
}
