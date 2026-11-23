import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/service_request.dart';
import '../../services/firebase_service.dart';
import 'profile_screen.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  String _formatRequestId(String rawId) {
    if (rawId.startsWith('REQ')) return rawId;
    final clean = rawId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (clean.length >= 8) {
      return 'REQ${clean.substring(0, 8)}';
    }
    return 'REQ0000000${clean.padRight(1, 'U')}';
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();
    final requests = fs.clientRequests;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1E36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              'ZOWFITY',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'My Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF20324D),
              child: const Icon(Icons.person, color: Colors.white70, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: const Color(0xFF0D1B2A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Requests Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.radar_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Active Requests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF243B66),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${requests.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Requests List or Empty State
            Expanded(
              child: requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No active service requests',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select a service category from Home to request a Zowmate.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: requests.length,
                      itemBuilder: (context, idx) {
                        final req = requests[idx];
                        return _RequestCard(
                          request: req,
                          displayId: _formatRequestId(req.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final String displayId;

  const _RequestCard({
    required this.request,
    required this.displayId,
  });

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirebaseService>();

    final subCategory = request.subService.isNotEmpty
        ? request.subService
        : 'Home cleaning';
    final tradeCategory = '${request.trade} Services';
    final dateDisplay = request.scheduledDate.isNotEmpty
        ? request.scheduledDate
        : '30 Oct 2026';
    final timeDisplay = request.scheduledTime.isNotEmpty
        ? request.scheduledTime
        : '5:15 PM';

    String statusLabel = 'Finding Zowmate';
    Color statusBg = AppColors.chipStatusBg;
    Color statusText = AppColors.chipStatusText;
    if (request.status == 'accepted' || request.providerName.isNotEmpty) {
      statusLabel = 'Assigned: ${request.providerName}';
      statusBg = const Color(0xFFDCFCE7);
      statusText = const Color(0xFF15803D);
    } else if (request.status == 'in_progress') {
      statusLabel = 'In Progress';
      statusBg = const Color(0xFFE0E7FF);
      statusText = const Color(0xFF4338CA);
    } else if (request.status == 'completed') {
      statusLabel = 'Completed';
      statusBg = const Color(0xFFDCFCE7);
      statusText = const Color(0xFF15803D);
    } else if (request.status == 'cancelled') {
      statusLabel = 'Cancelled';
      statusBg = const Color(0xFFFEE2E2);
      statusText = const Color(0xFFB91C1C);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Chips: Service Request & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.chipServiceBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.send_rounded,
                        size: 13, color: AppColors.chipServiceText),
                    SizedBox(width: 5),
                    Text(
                      'Service Request',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.chipServiceText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar_rounded, size: 13, color: statusText),
                    SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ID Line
          Row(
            children: [
              const Icon(Icons.assignment_outlined,
                  size: 16, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              Text(
                'ID: $displayId',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Hierarchy Category: Cleaning Services -> Home cleaning
          Row(
            children: [
              const Icon(Icons.account_tree_outlined,
                  size: 16, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$tradeCategory → $subCategory',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date & Time
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              Text(
                '$dateDisplay  •  $timeDisplay',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.zoneName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description (italic)
          if (request.description.isNotEmpty) ...[
            Text(
              '"${request.description}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Attached Photos preview
          if (request.photos.isNotEmpty) ...[
            const Text(
              'Attached Photos:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                request.photos.first,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Yellow Estimated Info Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.infoYellowBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.infoYellowBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.infoYellowText,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimated: ₹${request.budgetMin.toInt()} – ₹${request.budgetMax.toInt()} • Pay after service',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.infoYellowText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Cancel Request Outlined Button
          if (request.status != 'cancelled' && request.status != 'completed')
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cancel Request?'),
                      content: const Text(
                          'Are you sure you want to cancel this service request?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('No'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Cancel Request'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await fs.cancelServiceRequest(request);
                  }
                },
                child: const Text(
                  'Cancel Request',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
