import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDeletionBlockingGroup {
  const AccountDeletionBlockingGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.otherMemberCount,
    required this.canTransferOwnership,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final int memberCount;
  final int otherMemberCount;
  final bool canTransferOwnership;

  factory AccountDeletionBlockingGroup.fromMap(Map<String, dynamic> map) {
    return AccountDeletionBlockingGroup(
      id: map['id']?.toString() ?? '',
      name: _textOrFallback(map['name'], 'Unnamed group'),
      description: _textOrNull(map['description']),
      memberCount: _intValue(map['memberCount']),
      otherMemberCount: _intValue(map['otherMemberCount']),
      canTransferOwnership: map['canTransferOwnership'] == true,
    );
  }

  static String _textOrFallback(dynamic value, String fallback) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return fallback;
    }

    return text;
  }

  static String? _textOrNull(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AccountDeletionBlockedException implements Exception {
  const AccountDeletionBlockedException({
    required this.message,
    required this.soleOwnerGroupCount,
    this.soleOwnerGroups = const [],
    this.rawData,
  });

  final String message;
  final int soleOwnerGroupCount;
  final List<AccountDeletionBlockingGroup> soleOwnerGroups;
  final Map<String, dynamic>? rawData;

  @override
  String toString() {
    return message;
  }
}

class AccountRepository {
  AccountRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> dryRunDeleteCurrentAccount() async {
    return _invokeDeleteAccount(
      dryRun: true,
      debugLabel: 'delete-account dryRun',
    );
  }

  Future<void> deleteCurrentAccount() async {
    await _invokeDeleteAccount(
      dryRun: false,
      debugLabel: 'delete-account real delete',
    );

    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>> _invokeDeleteAccount({
    required bool dryRun,
    required String debugLabel,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'delete-account',
        body: {'dryRun': dryRun},
      );

      return _handleResponse(
        status: response.status,
        data: _asMap(response.data),
        debugLabel: debugLabel,
      );
    } catch (error, stackTrace) {
      _debugPrintFunctionException(
        label: debugLabel,
        error: error,
        stackTrace: stackTrace,
      );

      final mapped = _tryMapBlockedError(error);

      if (mapped != null) {
        throw mapped;
      }

      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse({
    required int status,
    required Map<String, dynamic> data,
    required String debugLabel,
  }) {
    _debugPrintFunctionResponse(label: debugLabel, status: status, data: data);

    if (data['code'] == 'sole_owner_groups') {
      throw AccountDeletionBlockedException(
        message:
            data['error']?.toString() ??
            'You must transfer or delete owned groups before deleting your account.',
        soleOwnerGroupCount: _intValue(data['soleOwnerGroupCount']),
        soleOwnerGroups: _blockingGroupsFromData(data),
        rawData: data,
      );
    }

    if (status < 200 || status >= 300) {
      throw Exception(
        data['error']?.toString() ??
            'Account deletion failed with status $status.',
      );
    }

    return data;
  }

  AccountDeletionBlockedException? _tryMapBlockedError(Object error) {
    final text = error.toString();

    if (!text.contains('sole_owner_groups')) {
      return null;
    }

    return AccountDeletionBlockedException(
      message:
          'You must transfer or delete owned groups before deleting your account.',
      soleOwnerGroupCount: _extractSoleOwnerGroupCount(text),
    );
  }

  List<AccountDeletionBlockingGroup> _blockingGroupsFromData(
    Map<String, dynamic> data,
  ) {
    final rawGroups = data['soleOwnerGroups'];

    if (rawGroups is! List) {
      return const [];
    }

    return rawGroups
        .whereType<Map>()
        .map((group) {
          return AccountDeletionBlockingGroup.fromMap(
            Map<String, dynamic>.from(group),
          );
        })
        .where((group) => group.id.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Fall through to plain value below.
      }
    }

    return {'value': value?.toString()};
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _extractSoleOwnerGroupCount(String text) {
    final patterns = [
      RegExp(r'"soleOwnerGroupCount"\s*:\s*(\d+)'),
      RegExp(r'soleOwnerGroupCount[:=]\s*(\d+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match != null) {
        return int.tryParse(match.group(1) ?? '') ?? 0;
      }
    }

    return 0;
  }

  void _debugPrintFunctionResponse({
    required String label,
    required int status,
    required Map<String, dynamic> data,
  }) {
    if (kReleaseMode) return;

    const encoder = JsonEncoder.withIndent('  ');

    debugPrint('================ EDGE FUNCTION RESPONSE ================');
    debugPrint('Function: $label');
    debugPrint('HTTP status: $status');
    debugPrint('Response data:');
    debugPrint(encoder.convert(data));
    debugPrint('========================================================');
  }

  void _debugPrintFunctionException({
    required String label,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (kReleaseMode) return;

    debugPrint('================ EDGE FUNCTION EXCEPTION ===============');
    debugPrint('Function: $label');
    debugPrint('Error: $error');
    debugPrintStack(stackTrace: stackTrace);
    debugPrint('========================================================');
  }
}
