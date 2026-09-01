import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/services/profile_photo_service.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';

import '../../config/color/colors.dart';
import '../../services/app_update_service.dart';
import '../../viewModel/bloc/theme/theme_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final List<String> labels = const [
    'Name',
    'Occupation',
    'Email',
  ];

  final List<IconData> icons = const [
    Icons.person_outline_rounded,
    Icons.work_outline_rounded,
    Icons.mail_outline_rounded,
  ];

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(Icons.photo_library_rounded, color: Color(0xFF4F46E5)),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await ProfilePhotoService.pickAndSavePhoto();
                  },
                ),
                if (ProfilePhotoService.photoNotifier.value != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFEE2E2),
                      child: Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                    ),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      await ProfilePhotoService.removePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > 600;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final primaryColor = themeState.theme[appColors.primaryColor]!;
        final cardColor = themeState.theme[appColors.cardColor]!;
        final textPrimary = themeState.theme[appColors.textPrimaryColor]!;
        final textSecondary = themeState.theme[appColors.textSecondaryColor]!;
        final accent = themeState.theme[appColors.accentColor]!;

        return Scaffold(
          backgroundColor: themeState.theme[appColors.appBGColor],
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    themeState.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.read<ThemeBloc>().add(ToggleTheme());
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              width: screenWidth,
              constraints: BoxConstraints(
                minHeight: screenHeight - kToolbarHeight - kBottomNavigationBarHeight,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.85),
                    themeState.theme[appColors.appBGColor]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final Map<String, String> values = {
                    'Name': authState.userModel.name,
                    'Occupation': authState.userModel.occupation,
                    'Email': authState.userModel.email,
                  };

                  final userName = authState.userModel.name;
                  final initials = userName.isNotEmpty
                      ? userName
                          .split(' ')
                          .where((w) => w.isNotEmpty)
                          .map((w) => w[0].toUpperCase())
                          .take(2)
                          .join()
                      : 'U';

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? screenWidth * 0.15 : 20.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Interactive Profile Avatar with Camera Badge
                        GestureDetector(
                          onTap: () => _showPhotoOptions(context),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ValueListenableBuilder<String?>(
                                valueListenable: ProfilePhotoService.photoNotifier,
                                builder: (context, photoPath, _) {
                                  final hasPhoto = photoPath != null &&
                                      photoPath.isNotEmpty &&
                                      File(photoPath).existsSync();

                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: isWide ? 55 : 45,
                                      backgroundColor: primaryColor,
                                      backgroundImage:
                                          hasPhoto ? FileImage(File(photoPath)) : null,
                                      child: !hasPhoto
                                          ? Text(
                                              initials,
                                              style: TextStyle(
                                                color: accent,
                                                fontSize: isWide ? 36 : 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          'Tap avatar to update photo',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Account Details',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Information Card
                        Card(
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          color: cardColor,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: labels.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: textSecondary.withValues(alpha: 0.1),
                              indent: 56,
                            ),
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    icons[index],
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  labels[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  values[labels[index]] ?? '—',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Check for Updates Card
                        Card(
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          color: cardColor,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            onTap: () {
                              AppUpdateService.checkForUpdate(
                                context,
                                showNoUpdateDialog: true,
                              );
                            },
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.system_update_rounded,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Check for Updates',
                              style: TextStyle(
                                fontSize: 14,
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Version 1.2.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Log Out Button
                        AppButton(
                          'Log Out',
                          color: Colors.white,
                          bgcolor: themeState.theme[appColors.expenseColor]!,
                          type: ButtonType.primary,
                          size: ButtonSize.medium,
                          leadingIcon: Icons.logout_rounded,
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogOut());
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
