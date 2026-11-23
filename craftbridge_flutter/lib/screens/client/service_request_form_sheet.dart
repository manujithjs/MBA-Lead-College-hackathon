import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../data/academy_data.dart';
import '../../services/firebase_service.dart';

class ServiceRequestFormSheet extends StatefulWidget {
  final String? initialTrade;

  const ServiceRequestFormSheet({super.key, this.initialTrade});

  @override
  State<ServiceRequestFormSheet> createState() =>
      _ServiceRequestFormSheetState();
}

class _ServiceRequestFormSheetState extends State<ServiceRequestFormSheet> {
  late String _trade;
  String _urgency = 'same_day';
  ServiceZone _zone = serviceZones.first;
  double _radiusKm = 12.0;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _minCtrl = TextEditingController(text: '45');
  final _maxCtrl = TextEditingController(text: '110');
  final _phoneCtrl = TextEditingController(text: '+91 98450 14821');
  final _addressCtrl = TextEditingController(
      text: '42, 12th Main, 100ft Road, Indiranagar Central');
  final _windowCtrl = TextEditingController(text: 'Today 2:00 PM – 5:00 PM');
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _trade = widget.initialTrade ?? 'Electrical';
    _applySampleForTrade(_trade);
  }

  void _applySampleForTrade(String trade) {
    final meta = tradeCategories.firstWhere(
      (c) => c.trade == trade,
      orElse: () => tradeCategories.first,
    );
    _titleCtrl.text = meta.sampleTitle;
    _descCtrl.text = meta.sampleDescription;
    _minCtrl.text = meta.defaultMin.toInt().toString();
    _maxCtrl.text = meta.defaultMax.toInt().toString();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final fs = context.read<FirebaseService>();
      await fs.createServiceRequest(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        trade: _trade,
        urgency: _urgency,
        zone: _zone,
        maxRadiusKm: _radiusKm,
        budgetMin: double.tryParse(_minCtrl.text) ?? 40,
        budgetMax: double.tryParse(_maxCtrl.text) ?? 100,
        contactPhone: _phoneCtrl.text,
        contactAddress: _addressCtrl.text,
        preferredWindow: _windowCtrl.text,
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
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _windowCtrl.dispose();
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
                  'Broadcast Service Request',
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
              'Phone & street address stay masked in Firestore (/contactDetails/private) until a certified vendor accepts.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _trade,
              decoration: const InputDecoration(labelText: 'Trade Category'),
              items: ValidationUtils.validTrades
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _trade = v;
                    _applySampleForTrade(v);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Issue Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: 'Fault Description'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Min Budget (\$)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Max Budget (\$)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _urgency,
              decoration: const InputDecoration(labelText: 'Urgency'),
              items: const [
                DropdownMenuItem(value: 'standard', child: Text('Standard')),
                DropdownMenuItem(value: 'same_day', child: Text('Same Day')),
                DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
              ],
              onChanged: (v) => setState(() => _urgency = v ?? 'same_day'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceZone>(
              initialValue: _zone,
              decoration: const InputDecoration(labelText: 'Service Zone'),
              items: serviceZones
                  .map((z) => DropdownMenuItem(value: z, child: Text(z.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _zone = v);
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Geo-Dispatch Radius: ${_radiusKm.toInt()} km (max 15 km)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            Slider(
              value: _radiusKm,
              min: 5,
              max: 15,
              divisions: 10,
              label: '${_radiusKm.toInt()} km',
              onChanged: (v) => setState(() => _radiusKm = v),
            ),
            const Divider(height: 24),
            const Text(
              'PII-Isolated Contact Details (Unlocked Only to Assigned Pro)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Contact Phone'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Street Address'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _windowCtrl,
              decoration:
                  const InputDecoration(labelText: 'Preferred Time Window'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _submitting ? null : _submit,
              child: Text(
                _submitting ? 'Broadcasting...' : 'Broadcast Within ${_radiusKm.toInt()} km',
              ),
            ),
          ],
        );
      },
    );
  }
}
