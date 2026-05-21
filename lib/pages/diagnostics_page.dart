import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    loadPackageInfo();
  }

  Future<void> loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() => packageInfo = info);
  }

  String get platformLabel {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isLinux) return 'linux';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';

    return 'unknown';
  }

  String get buildMode {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }

  String mask(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return '—';
    }

    if (text.length <= 8) {
      return 'configured';
    }

    return '${text.substring(0, 4)}…${text.substring(text.length - 4)}';
  }

  String get supabaseHost {
    try {
      final url = AppConfig.supabaseUrl;
      return Uri.parse(url).host;
    } catch (_) {
      return '—';
    }
  }

  String get userId {
    return mask(Supabase.instance.client.auth.currentUser?.id);
  }

  String get sessionStatus {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return 'inactive';
    }

    return 'active';
  }

  String get sessionExpiresAt {
    final expiresAt = Supabase.instance.client.auth.currentSession?.expiresAt;

    if (expiresAt == null) {
      return '—';
    }

    final date = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);

    return date.toLocal().toIso8601String();
  }

  bool get omdbConfigured {
    return AppConfig.omdbApiKey.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final info = packageInfo;

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DiagnosticsSection(
              title: 'App',
              icon: Icons.phone_android_outlined,
              rows: [
                _DiagnosticsRow(label: 'App name', value: info?.appName ?? '—'),
                _DiagnosticsRow(
                  label: 'Package',
                  value: info?.packageName ?? '—',
                ),
                _DiagnosticsRow(
                  label: 'Version',
                  value: info == null
                      ? '—'
                      : '${info.version}+${info.buildNumber}',
                ),
                _DiagnosticsRow(label: 'Platform', value: platformLabel),
                _DiagnosticsRow(label: 'Build mode', value: buildMode),
              ],
            ),
            const SizedBox(height: 12),
            _DiagnosticsSection(
              title: 'Supabase',
              icon: Icons.cloud_outlined,
              rows: [
                _DiagnosticsRow(label: 'Project host', value: supabaseHost),
                _DiagnosticsRow(label: 'Session', value: sessionStatus),
                _DiagnosticsRow(label: 'User id', value: userId),
                _DiagnosticsRow(
                  label: 'Session expires',
                  value: sessionExpiresAt,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DiagnosticsSection(
              title: 'Configuration',
              icon: Icons.tune_outlined,
              rows: [
                _DiagnosticsRow(
                  label: 'OMDb key',
                  value: omdbConfigured ? 'configured' : 'missing',
                ),
                _DiagnosticsRow(
                  label: 'OpenFoodFacts staging',
                  value: AppConfig.useOpenFoodFactsStaging ? 'yes' : 'no',
                ),
                _DiagnosticsRow(
                  label: 'Default currency',
                  value: AppConfig.defaultCurrency,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _DiagnosticsNotice(),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticsSection extends StatelessWidget {
  const _DiagnosticsSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_DiagnosticsRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final row in rows) row,
          ],
        ),
      ),
    );
  }
}

class _DiagnosticsRow extends StatelessWidget {
  const _DiagnosticsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsNotice extends StatelessWidget {
  const _DiagnosticsNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'This page only shows safe diagnostics. It does not show API keys, tokens, passwords, or private user content.',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
