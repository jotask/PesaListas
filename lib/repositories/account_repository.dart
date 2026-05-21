import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDeletionBlockedException implements Exception {
  const AccountDeletionBlockedException({
    required this.message,
    required this.soleOwnerGroupCount,
    this.rawData,
  });

  final String message;
  final int soleOwnerGroupCount;
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
    final response = await _client.functions.invoke(
      'delete-account',
      body: {'dryRun': true},
    );

    return _handleResponse(response, debugLabel: 'delete-account dryRun');
  }

  Future<void> deleteCurrentAccount() async {
    final response = await _client.functions.invoke(
      'delete-account',
      body: {'dryRun': false},
    );

    _handleResponse(response, debugLabel: 'delete-account real delete');

    await _client.auth.signOut();
  }

  Map<String, dynamic> _handleResponse(
    FunctionResponse response, {
    required String debugLabel,
  }) {
    final data = _asMap(response.data);

    _debugPrintFunctionResponse(
      label: debugLabel,
      status: response.status,
      data: data,
    );

    if (response.status == 409 && data['code'] == 'sole_owner_groups') {
      throw AccountDeletionBlockedException(
        message:
            data['error']?.toString() ??
            'You must transfer or delete owned groups before deleting your account.',
        soleOwnerGroupCount: _intValue(data['soleOwnerGroupCount']),
        rawData: data,
      );
    }

    if (response.status < 200 || response.status >= 300) {
      throw Exception(
        data['error']?.toString() ??
            'Account deletion failed with status ${response.status}.',
      );
    }

    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {'value': value?.toString()};
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
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
}
