import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geo_utils.dart';
import '../../data/academy_data.dart';
import '../../models/service_request.dart';
import '../../services/firebase_service.dart';
import '../../widgets/certificate_verifier_card.dart';
import '../../widgets/payment_checkout_sheet.dart';
import '../../widgets/radius_radar_widget.dart';
import '../admin/admin_verification_screen.dart';
import 'service_request_form_sheet.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _tabIndex = 0;
  String _selectedTrade = 'All';
  double _radiusKm = 15.0;

  void _openPostSheet([String? trade]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ServiceRequestFormSheet(initialTrade: trade),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();
    final userZone = serviceZones.firstWhere(
      (z) => z.name == fs.userAccount?.neighborhood,
      orElse: () => serviceZones.first,
    );

    final pages = [
      _buildExploreTab(fs, userZone),
      _buildMyJobsTab(fs),
      _buildVerifyAndProfileTab(fs, userZone),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CraftBridge · Homeowner',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              userZone.name,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          if (fs.isAdmin)
            IconButton(
              tooltip: 'Admin Verification Queue',
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
            onPressed: () => fs.setActivePortal('provider'),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Partner Mode'),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () => fs.signOut(),
          ),
        ],
      ),
      body: pages[_tabIndex],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _openPostSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Post Issue'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore Pros',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: fs.clientRequests.isNotEmpty,
              label: Text('${fs.clientRequests.length}'),
              child: const Icon(Icons.work_outline),
            ),
            label: 'My Jobs',
          ),
          const NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified),
            label: 'Verify & Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTab(FirebaseService fs, ServiceZone userZone) {
    final verifiedPros = fs.providers.where((p) {
      if (p.verificationStatus != 'verified') return false;
      if (_selectedTrade != 'All' && p.trade != _selectedTrade) return false;
      final dist =
          haversineDistanceKm(userZone.lat, userZone.lng, p.lat, p.lng);
      return dist <= _radiusKm;
    }).toList();

    final pins = verifiedPros.map((p) {
      final dist =
          haversineDistanceKm(userZone.lat, userZone.lng, p.lat, p.lng);
      return RadarPin(
        id: p.id,
        label: p.displayName,
        sublabel: '${p.trade} · ${p.certificateId} · \$${p.hourlyRate.toInt()}/hr',
        lat: p.lat,
        lng: p.lng,
        distanceKm: dist,
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tradeCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, idx) {
              final cat = tradeCategories[idx];
              return GestureDetector(
                onTap: () => _openPostSheet(cat.trade),
                child: Container(
                  width: 155,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.trade,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        cat.priceFrom,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Text(
                        cat.avgEta,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Electrical',
                    'Plumbing',
                    'Appliance Repair',
                    'Cleaning'
                  ].map((t) {
                    final selected = _selectedTrade == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(t),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedTrade = t),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Search Radius: ${_radiusKm.toInt()} km',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            Expanded(
              child: Slider(
                value: _radiusKm,
                min: 5,
                max: 15,
                divisions: 10,
                onChanged: (v) => setState(() => _radiusKm = v),
              ),
            ),
          ],
        ),
        RadiusRadarWidget(
          originName: userZone.name,
          originLat: userZone.lat,
          originLng: userZone.lng,
          radiusKm: _radiusKm,
          pins: pins,
        ),
        const SizedBox(height: 16),
        Text(
          'Certified Vendors Nearby (${verifiedPros.length})',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        if (verifiedPros.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                fs.providers.isEmpty
                    ? 'No vendors seeded yet. Sign in as Admin (manujith.js@lead.ac.in) to seed initial Softi Academy graduates.'
                    : 'No verified vendors match this filter within ${_radiusKm.toInt()} km.',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ...verifiedPros.map((pro) {
          final dist =
              haversineDistanceKm(userZone.lat, userZone.lng, pro.lat, pro.lng);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      AssetImages.forTrade(pro.trade),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pro.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$dist km',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emeraldDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pro.trade} · ${pro.trainingDays}d Lab · ${pro.practicalScore}% Score',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cert: ${pro.certificateId} · ★ ${pro.rating} (${pro.completedJobs} jobs) · \$${pro.hourlyRate.toInt()}/hr',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget _buildMyJobsTab(FirebaseService fs) {
    final jobs = fs.clientRequests;
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No service requests posted yet.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _openPostSheet(),
                child: const Text('Post Your First Request'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, idx) {
        final req = jobs[idx];
        return _ClientJobCard(request: req);
      },
    );
  }

  Widget _buildVerifyAndProfileTab(FirebaseService fs, ServiceZone userZone) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fs.userAccount?.displayName ?? 'Homeowner',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  fs.user?.email ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ServiceZone>(
                  initialValue: userZone,
                  decoration:
                      const InputDecoration(labelText: 'Active Service Zone'),
                  items: serviceZones
                      .map((z) =>
                          DropdownMenuItem(value: z, child: Text(z.name)))
                      .toList(),
                  onChanged: (z) {
                    if (z != null) fs.updateUserZone(z);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const CertificateVerifierCard(),
        const SizedBox(height: 70),
      ],
    );
  }
}

class _ClientJobCard extends StatelessWidget {
  final ServiceRequest request;

  const _ClientJobCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirebaseService>();

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
                    request.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            Text(
              '${request.trade} · ${request.zoneName} · Est. \$${request.estimatedBudget.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (request.providerName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Assigned Partner: ${request.providerName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Escrow: ${request.paymentStatus}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                if (request.status == 'open')
                  TextButton(
                    onPressed: () => fs.cancelServiceRequest(request),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.red)),
                  ),
                if (request.paymentStatus == 'unpaid' &&
                    request.status != 'cancelled')
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.indigo),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) =>
                            PaymentCheckoutSheet(request: request),
                      );
                    },
                    child: const Text('Fund Escrow'),
                  ),
                if (request.paymentStatus == 'escrow_held' &&
                    request.status == 'completed')
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emerald),
                    onPressed: () => fs.releaseHeldEscrow(request),
                    child: const Text('Release Payout'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
