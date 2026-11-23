import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geo_utils.dart';
import '../../models/request_contact_details.dart';
import '../../models/service_request.dart';
import '../../services/firebase_service.dart';
import '../../widgets/radius_radar_widget.dart';
import '../admin/admin_verification_screen.dart';
import 'provider_registration_sheet.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _tabIndex = 0;

  void _openCredentialSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ProviderRegistrationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();
    final profile = fs.myProviderProfile;

    final pages = [
      _buildDispatchRadarTab(fs),
      _buildActiveJobsTab(fs),
      _buildWalletAndLabTab(fs),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CraftBridge · Partner',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              profile != null
                  ? '${profile.certificateId} · ${profile.verificationStatus.toUpperCase()}'
                  : 'Credential Registration Required',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          if (fs.isAdmin)
            IconButton(
              tooltip: 'Admin Queue',
              icon: const Icon(Icons.admin_panel_settings,
                  color: AppColors.indigo),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminVerificationScreen()),
                );
              },
            ),
          TextButton.icon(
            onPressed: () => fs.setActivePortal('client'),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Client Mode'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => fs.signOut(),
          ),
        ],
      ),
      body: pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: fs.openRequests.isNotEmpty,
              label: Text('${fs.openRequests.length}'),
              child: const Icon(Icons.radar),
            ),
            label: 'Live Radar',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: fs.providerRequests.isNotEmpty,
              label: Text('${fs.providerRequests.length}'),
              child: const Icon(Icons.handyman_outlined),
            ),
            label: 'Active Jobs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Lab & Escrow',
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchRadarTab(FirebaseService fs) {
    final profile = fs.myProviderProfile;
    final originLat = profile?.lat ?? fs.userAccount?.lat ?? 12.9784;
    final originLng = profile?.lng ?? fs.userAccount?.lng ?? 77.6408;
    final originName =
        profile?.zoneName ?? fs.userAccount?.neighborhood ?? 'Indiranagar Central';

    final nearbyLeads = fs.openRequests.where((req) {
      final dist = haversineDistanceKm(originLat, originLng, req.lat, req.lng);
      return dist <= req.maxRadiusKm;
    }).toList();

    final pins = nearbyLeads.map((req) {
      final dist = haversineDistanceKm(originLat, originLng, req.lat, req.lng);
      return RadarPin(
        id: req.id,
        label: req.title,
        sublabel:
            '${req.trade} · \$${req.budgetMin.toInt()}–\$${req.budgetMax.toInt()}',
        lat: req.lat,
        lng: req.lng,
        distanceKm: dist,
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (profile == null)
          Card(
            color: AppColors.amber.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mandatory Practical Lab Gate',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Firestore security rules require a registered /providers/{uid} profile before you can accept local leads.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _openCredentialSheet,
                    child: const Text('Register Practical Certificate'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),
        RadiusRadarWidget(
          originName: originName,
          originLat: originLat,
          originLng: originLng,
          radiusKm: 15,
          pins: pins,
        ),
        const SizedBox(height: 16),
        Text(
          'Open Leads Within 10–15 km (${nearbyLeads.length})',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        ...nearbyLeads.map((req) {
          final dist =
              haversineDistanceKm(originLat, originLng, req.lat, req.lng);
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
                          req.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      Chip(label: Text('$dist km')),
                    ],
                  ),
                  Text(
                    '${req.trade} · ${req.urgency.toUpperCase()} · ${req.zoneName}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    req.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Budget: \$${req.budgetMin.toInt()} – \$${req.budgetMax.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.navy,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.emeraldDark,
                        ),
                        onPressed: profile == null
                            ? _openCredentialSheet
                            : () async {
                                try {
                                  await fs.acceptServiceRequest(req);
                                  if (mounted) {
                                    setState(() => _tabIndex = 1);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                        child: const Text('Accept Lead'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActiveJobsTab(FirebaseService fs) {
    final jobs = fs.providerRequests;
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'No accepted jobs yet. Accept an open lead on the Radar tab.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, idx) {
        return _ProviderActiveJobCard(request: jobs[idx]);
      },
    );
  }

  Widget _buildWalletAndLabTab(FirebaseService fs) {
    final profile = fs.myProviderProfile;
    final totalReleased = fs.payments
        .where((p) => p.status == 'released')
        .fold<double>(0, (sum, p) => sum + p.providerPayout);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settled Escrow Payouts',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  '\$${totalReleased.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emeraldDark,
                  ),
                ),
                const SizedBox(height: 12),
                if (profile != null) ...[
                  Text(
                    'Certificate: ${profile.certificateId} (${profile.verificationStatus})',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${profile.trainingCenter} · ${profile.trainingDays} Days · ${profile.practicalScore}% Score',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ] else
                  FilledButton(
                    onPressed: _openCredentialSheet,
                    child: const Text('Submit Practical Lab Credential'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderActiveJobCard extends StatefulWidget {
  final ServiceRequest request;

  const _ProviderActiveJobCard({required this.request});

  @override
  State<_ProviderActiveJobCard> createState() => _ProviderActiveJobCardState();
}

class _ProviderActiveJobCardState extends State<_ProviderActiveJobCard> {
  RequestContactDetails? _contact;
  bool _loadingContact = false;

  Future<void> _unlockContact() async {
    setState(() => _loadingContact = true);
    final details = await context
        .read<FirebaseService>()
        .getPrivateContactDetails(widget.request.id);
    if (mounted) {
      setState(() {
        _contact = details;
        _loadingContact = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirebaseService>();
    final req = widget.request;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    req.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Chip(label: Text(req.status.toUpperCase())),
              ],
            ),
            Text(
              'Client: ${req.clientName} · ${req.zoneName}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            if (_contact != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone: ${_contact!.contactPhone}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      'Address: ${_contact!.contactAddress}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (_contact!.preferredWindow != null)
                      Text(
                        'Window: ${_contact!.preferredWindow}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _loadingContact ? null : _unlockContact,
                icon: const Icon(Icons.lock_open, size: 16),
                label: Text(_loadingContact
                    ? 'Unlocking...'
                    : 'Unlock Customer Phone & Address'),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (req.status == 'accepted')
                  FilledButton(
                    onPressed: () => fs.advanceJobStatus(req, 'in_progress'),
                    child: const Text('Start On-Site Work'),
                  ),
                if (req.status == 'in_progress')
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emeraldDark),
                    onPressed: () => fs.advanceJobStatus(req, 'completed'),
                    child: const Text('Mark Completed'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
