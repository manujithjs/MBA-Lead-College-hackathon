import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../admin/admin_verification_screen.dart';
import 'my_requests_screen.dart';
import 'profile_screen.dart';

class ClientMenuScreen extends StatelessWidget {
  const ClientMenuScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();
    final userName = fs.userAccount?.displayName ?? fs.user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF20324D),
              child: const Icon(Icons.person, color: Colors.white70, size: 22),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_getGreeting()}, $userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Group 1
          _MenuGroupCard(
            children: [
              _MenuItemTile(
                icon: Icons.assignment_outlined,
                title: 'My Requests',
                badgeText: fs.clientRequests.isNotEmpty
                    ? '${fs.clientRequests.length}'
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyRequestsScreen()),
                  );
                },
              ),
              _MenuItemDivider(),
              _MenuItemTile(
                icon: Icons.shopping_bag_outlined,
                title: 'My Orders',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Orders are currently empty.')),
                  );
                },
              ),
              _MenuItemDivider(),
              _MenuItemTile(
                icon: Icons.shopping_cart_outlined,
                title: 'My Cart',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cart is currently empty.')),
                  );
                },
              ),
              _MenuItemDivider(),
              _MenuItemTile(
                icon: Icons.monetization_on_outlined,
                title: 'ZowCoins',
                subtitle: '50 Coins Available',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('You have 50 ZowCoins for your next booking!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Group 2
          _MenuGroupCard(
            children: [
              _MenuItemTile(
                icon: Icons.credit_card_outlined,
                title: 'Payments & History',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('All payments are protected via secure escrow.')),
                  );
                },
              ),
              _MenuItemDivider(),
              _MenuItemTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Group 3
          _MenuGroupCard(
            children: [
              _MenuItemTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('ZOWFITY Support'),
                      content: const Text(
                          'For help with bookings or trade services, reach out to support@zowfity.com or call +91 96335 97075.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _MenuItemDivider(),
              _MenuItemTile(
                icon: Icons.card_giftcard_outlined,
                title: 'Refer & Earn',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Invite friends and earn 100 ZowCoins!')),
                  );
                },
              ),
              _MenuItemDivider(),
              _MenuItemTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy & Terms',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Privacy & Protection'),
                      content: const Text(
                          'CraftBridge / ZOWFITY isolates client phone and full address in encrypted Firestore paths until a verified trade professional accepts your request.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Mode Switch Card
          _MenuGroupCard(
            children: [
              _MenuItemTile(
                icon: Icons.swap_horiz_rounded,
                title: 'Switch to Partner Mode',
                subtitle: 'Accept tasks as a certified technician',
                onTap: () => fs.setActivePortal('provider'),
              ),
              if (fs.isAdmin) ...[
                _MenuItemDivider(),
                _MenuItemTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Verification Queue',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminVerificationScreen()),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MenuGroupCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _MenuItemDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}

class _MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final VoidCallback onTap;

  const _MenuItemTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.navy, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
