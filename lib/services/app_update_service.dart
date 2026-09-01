import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/color/colors.dart';
import '../config/components/button.dart';
import '../config/components/textwidgets.dart';
import '../config/flash_bar/flash_bar.dart';
import '../viewModel/bloc/theme/theme_bloc.dart';

class AppUpdateService {
  static const String _owner = 'dev-abdul-haseeb';
  static const String _repo = 'spend_wise';
  static const String _releasesApiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  /// Checks GitHub Releases for a newer version than currently installed.
  /// If [showNoUpdateDialog] is true, shows feedback if already up-to-date.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool showNoUpdateDialog = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(_releasesApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawTagName = data['tag_name'] as String? ?? '';
        final releaseNotes = data['body'] as String? ?? '';
        final htmlUrl = data['html_url'] as String? ?? '';

        // Select platform-specific release asset download URL (Windows release vs Android APK vs Web)
        String downloadUrl = htmlUrl;
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null && assets.isNotEmpty) {
          downloadUrl = _getPlatformSpecificAssetUrl(assets, htmlUrl);
        }

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        final latestVersion = _cleanVersion(rawTagName);

        if (_isNewerVersion(latestVersion, currentVersion)) {
          if (context.mounted) {
            _showUpdateDialog(
              context,
              latestVersion: rawTagName.isNotEmpty ? rawTagName : latestVersion,
              currentVersion: currentVersion,
              releaseNotes: releaseNotes,
              downloadUrl: downloadUrl,
            );
          }
        } else if (showNoUpdateDialog && context.mounted) {
          showFlashbar(
            context,
            'You are on the latest version ($currentVersion)',
            true,
          );
        }
      } else if (showNoUpdateDialog && context.mounted) {
        showFlashbar(context, 'No releases found on GitHub.', false);
      }
    } catch (e) {
      if (showNoUpdateDialog && context.mounted) {
        showFlashbar(
          context,
          'Unable to check for updates. Please check your internet connection.',
          false,
        );
      }
    }
  }

  /// Cleans strings like "v1.2.0" or "v1.2.0+3" into pure version "1.2.0"
  static String _cleanVersion(String tag) {
    var cleaned = tag.trim();
    if (cleaned.startsWith('v') || cleaned.startsWith('V')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.contains('+')) {
      cleaned = cleaned.split('+').first;
    }
    return cleaned;
  }

  /// Returns true if [remote] > [local]
  static bool _isNewerVersion(String remote, String local) {
    try {
      final remoteParts = remote
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final localParts = local
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      while (remoteParts.length < 3) {
        remoteParts.add(0);
      }
      while (localParts.length < 3) {
        localParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (remoteParts[i] > localParts[i]) return true;
        if (remoteParts[i] < localParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Shows the styled in-app update prompt dialog
  static void _showUpdateDialog(
    BuildContext context, {
    required String latestVersion,
    required String currentVersion,
    required String releaseNotes,
    required String downloadUrl,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final primary = themeState.theme[appColors.primaryColor]!;
            final cardBg = themeState.theme[appColors.cardColor]!;
            final textPrimary = themeState.theme[appColors.textPrimaryColor]!;
            final textSecondary =
                themeState.theme[appColors.textSecondaryColor]!;
            final accent = themeState.theme[appColors.accentColor]!;

            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      color: primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Update Available',
                          color: textPrimary,
                          type: TextType.screenTitles,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$currentVersion  ➔  $latestVersion',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'A new version of SpendWise is available. Update now to get the latest features and improvements.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (releaseNotes.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      "What's New:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 140),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          releaseNotes.trim(),
                          style: TextStyle(
                            fontSize: 13,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        'Update Now',
                        color: themeState.theme[appColors.textSecondaryColor]!,
                        bgcolor: accent,
                        type: ButtonType.primary,
                        size: ButtonSize.small,
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          final uri = Uri.parse(downloadUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Selects the appropriate release asset download URL for the current platform
  static String _getPlatformSpecificAssetUrl(
    List<dynamic> assets,
    String defaultHtmlUrl,
  ) {
    if (kIsWeb) {
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.contains('web')) {
          return asset['browser_download_url'] as String? ?? defaultHtmlUrl;
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.exe') ||
            name.endsWith('.msi') ||
            (name.contains('windows') && name.endsWith('.zip'))) {
          return asset['browser_download_url'] as String? ?? defaultHtmlUrl;
        }
      }
      // General zip fallback for Windows desktop builds
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.zip')) {
          return asset['browser_download_url'] as String? ?? defaultHtmlUrl;
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk') || name.endsWith('.aab')) {
          return asset['browser_download_url'] as String? ?? defaultHtmlUrl;
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.dmg') ||
            name.endsWith('.pkg') ||
            (name.contains('mac') && name.endsWith('.zip'))) {
          return asset['browser_download_url'] as String? ?? defaultHtmlUrl;
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.appimage') ||
            name.endsWith('.deb') ||
            (name.contains('linux') && name.endsWith('.zip'))) {
          return asset['browser_download_url'] as String? ?? defaultHtmlUrl;
        }
      }
    }
    return defaultHtmlUrl;
  }
}
