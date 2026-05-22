import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_diagnostics.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  PackageInfo? packageInfo;
  DiagnosticsReport? report;
  Object? loadError;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadDiagnostics();
  }

  Future<void> loadDiagnostics() async {
    setState(() {
      loading = true;
      loadError = null;
    });

    try {
      final info = await PackageInfo.fromPlatform();
      final diagnosticsReport = await AppDiagnostics.runAll();

      if (!mounted) return;

      setState(() {
        packageInfo = info;
        report = diagnosticsReport;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadError = error;
        loading = false;
      });
    }
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

    if (text.length <= 10) {
      return 'configured';
    }

    return '${text.substring(0, 4)}…${text.substring(text.length - 4)}';
  }

  String get supabaseHost {
    try {
      return Uri.parse(AppConfig.supabaseUrl).host;
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

  @override
  Widget build(BuildContext context) {
    final info = packageInfo;
    final currentReport = report;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Run diagnostics again',
            onPressed: loading ? null : loadDiagnostics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: loadDiagnostics,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DiagnosticsSection(
                title: 'App',
                icon: Icons.phone_android_outlined,
                children: [
                  _DiagnosticsInfoRow(
                    label: 'App name',
                    value: info?.appName ?? '—',
                  ),
                  _DiagnosticsInfoRow(
                    label: 'Package',
                    value: info?.packageName ?? '—',
                  ),
                  _DiagnosticsInfoRow(
                    label: 'Version',
                    value: info == null
                        ? '—'
                        : '${info.version}+${info.buildNumber}',
                  ),
                  _DiagnosticsInfoRow(label: 'Platform', value: platformLabel),
                  _DiagnosticsInfoRow(label: 'Build mode', value: buildMode),
                ],
              ),
              const SizedBox(height: 12),
              _DiagnosticsSection(
                title: 'Session',
                icon: Icons.account_circle_outlined,
                children: [
                  _DiagnosticsInfoRow(
                    label: 'Supabase project',
                    value: supabaseHost,
                  ),
                  _DiagnosticsInfoRow(label: 'Session', value: sessionStatus),
                  _DiagnosticsInfoRow(label: 'User id', value: userId),
                  _DiagnosticsInfoRow(
                    label: 'Session expires',
                    value: sessionExpiresAt,
                  ),
                  _DiagnosticsInfoRow(
                    label: 'OpenFoodFacts staging',
                    value: AppConfig.useOpenFoodFactsStaging ? 'yes' : 'no',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DiagnosticsSection(
                title: 'Health checks',
                icon: Icons.health_and_safety_outlined,
                children: [
                  if (loading)
                    const AppMessageCard(
                      icon: Icons.sync_outlined,
                      message: 'Running diagnostics...',
                    ),
                  if (loadError != null)
                    AppMessageCard(
                      icon: Icons.error_outline,
                      message: loadError.toString(),
                      tone: AppMessageCardTone.error,
                    ),
                  if (!loading && currentReport != null) ...[
                    _DiagnosticsSummary(report: currentReport),
                    const SizedBox(height: 12),
                    for (final item in currentReport.items)
                      _DiagnosticItemTile(item: item),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              const _DiagnosticsNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagnosticsSection extends StatelessWidget {
  const _DiagnosticsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

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
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DiagnosticsInfoRow extends StatelessWidget {
  const _DiagnosticsInfoRow({required this.label, required this.value});

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

class _DiagnosticsSummary extends StatelessWidget {
  const _DiagnosticsSummary({required this.report});

  final DiagnosticsReport report;

  @override
  Widget build(BuildContext context) {
    final errors = report.items
        .where((item) => item.status == DiagnosticStatus.error)
        .length;
    final warnings = report.items
        .where((item) => item.status == DiagnosticStatus.warning)
        .length;
    final success = report.items
        .where((item) => item.status == DiagnosticStatus.success)
        .length;

    String message;
    IconData icon;

    if (errors > 0) {
      message = '$errors error(s), $warnings warning(s), $success passed';
      icon = Icons.error_outline;
    } else if (warnings > 0) {
      message = '$warnings warning(s), $success passed';
      icon = Icons.warning_amber_rounded;
    } else {
      message = 'All $success checks passed';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            _timeLabel(report.generatedAt),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _timeLabel(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}

class _DiagnosticItemTile extends StatelessWidget {
  const _DiagnosticItemTile({required this.item});

  final DiagnosticItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.status) {
      DiagnosticStatus.success => Icons.check_circle_outline,
      DiagnosticStatus.warning => Icons.warning_amber_rounded,
      DiagnosticStatus.error => Icons.error_outline,
      DiagnosticStatus.info => Icons.info_outline,
    };

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  item.message,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.details != null && item.details!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SelectableText(
                    item.details!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
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
          'This page only shows safe diagnostics. It does not show API keys, tokens, passwords, emails, or private user content.',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
