import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/core/constants/spacings.dart';
import 'package:flutter_application/core/constants/urls.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_application/features/theme_mode/presentation/widget/theme_mode_settings_tile.dart';
import 'package:flutter_application/features/profile/presentation/page/notification_settings_page.dart';
//
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: Spacing.s24),
            
            // Profile Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Spacing.s16),
              padding: const EdgeInsets.all(Spacing.s24),
              decoration: BoxDecoration(
                gradient: isDark ? null : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8BBD0),
                    Color(0xFFFFCCBC),
                  ],
                ),
                color: isDark ? Colors.grey[850] : null,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: Colors.grey[700]!, width: 1) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: isDark ? Colors.pink[300] : AppColors.b93160,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthUserAuthenticated) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.user.email.split('@')[0],
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.user.email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Text(
                              "User",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Spacing.s24),
            
            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Spacing.s16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fitur Edit Profile sedang dalam pengembangan',
                            style: GoogleFonts.poppins(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  const ThemeModeSettingsTile(),
                  const Divider(height: 1),
                  
                  _ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notification Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),

                  const ThemeModeSettingsTile(),
                  // const Divider(height: 1),
                  _ProfileMenuItem(
                     icon: Icons.email_outlined,
                     title: 'Change Email',
                     onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text(
                             'Fitur Change Email sedang dalam pengembangan',
                             style: GoogleFonts.poppins(),
                           ),
                           behavior: SnackBarBehavior.floating,
                         ),
                       );
                     },
                   ),
                  const Divider(height: 1),
                  _ProfileMenuItem(
                  icon: Icons.forward_to_inbox,
                  title: 'Email Support',
                  subtitle: 'Tap here to contact over email',
                  onTap: () => launchUrl(Uri.parse("mailto:${Urls.contactEmail}")),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => launchUrl(Uri.parse(Urls.termsService)),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => launchUrl(Uri.parse(Urls.privacyPolicy)),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuItem(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: _packageInfo.version,
                    onTap: null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Spacing.s24),
            
            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Spacing.s16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _ProfileMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(
                        'Logout',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'Apakah Anda yakin ingin keluar?',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.read<AuthBloc>().add(const AuthLogoutButtonPressed());
                          },
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: Spacing.s24),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.b93160,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: titleColor ?? (isDark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            )
          : null,
      onTap: onTap,
    );
  }
}
