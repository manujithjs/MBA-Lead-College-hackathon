import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geo_utils.dart';
import '../../services/firebase_service.dart';

class AuthOnboardingScreen extends StatefulWidget {
  const AuthOnboardingScreen({super.key});

  @override
  State<AuthOnboardingScreen> createState() => _AuthOnboardingScreenState();
}

class _AuthOnboardingScreenState extends State<AuthOnboardingScreen> {
  String _selectedRole = 'client'; // 'client' | 'provider'
  bool _isRegister = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+91 98450 72410');
  ServiceZone _selectedZone = serviceZones.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final fs = context.read<FirebaseService>();
    if (_isRegister) {
      await fs.registerWithEmail(
        displayName: _nameCtrl.text.trim().isEmpty
            ? 'CraftBridge User'
            : _nameCtrl.text.trim(),
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        phone: _phoneCtrl.text,
        portalType: _selectedRole,
        zone: _selectedZone,
      );
    } else {
      await fs.signInWithEmail(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        portalType: _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: AppColors.emerald,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CraftBridge · Softi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                              Text(
                                'Lab-Vetted Local Trade Network',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '10–15 km',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Select Account Experience',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _roleCard(
                        role: 'client',
                        title: 'Homeowner',
                        subtitle: 'Post issues, photos & budget range',
                        icon: Icons.home_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _roleCard(
                        role: 'provider',
                        title: 'Service Partner',
                        subtitle: 'Practical Lab certified technicians',
                        icon: Icons.build_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isRegister
                              ? 'Create Firebase Account'
                              : 'Sign In to CraftBridge',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                          ),
                          onPressed: fs.authLoading
                              ? null
                              : () => fs.signInWithGoogle(
                                  portalType: _selectedRole),
                          icon: const Icon(Icons.login),
                          label: const Text('Continue with Google'),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'or email',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textMuted),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        if (_isRegister) ...[
                          TextField(
                            controller: _nameCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Full Name'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Mobile Number (Private PII)'),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<ServiceZone>(
                            initialValue: _selectedZone,
                            decoration: const InputDecoration(
                                labelText: 'Neighborhood Zone'),
                            items: serviceZones
                                .map((z) => DropdownMenuItem(
                                    value: z, child: Text(z.name)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedZone = v);
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                        ),
                        if (fs.authError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            fs.authError!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.red),
                          ),
                        ],
                        const SizedBox(height: 14),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: fs.authLoading ? null : _submitEmail,
                          child: Text(
                            fs.authLoading
                                ? 'Authenticating...'
                                : _isRegister
                                    ? 'Create Account & Launch'
                                    : 'Sign In & Launch',
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _isRegister = !_isRegister),
                          child: Text(
                            _isRegister
                                ? 'Already have an account? Sign In'
                                : 'New to CraftBridge? Create Account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final active = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryBlue.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.primaryBlue : AppColors.border,
            width: active ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primaryBlue : AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
