import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/models/admin_dashboard.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';
import 'package:nightoutadmin/providers/api.provider.dart';

/// Null when the rpc returns no row (web shows 0 on every card).
final dashboardProvider = FutureProvider.autoDispose<AdminDashboard?>(
  (ref) async {
    final auth = ref.read(authCtrl.notifier);
    try {
      return await ref
          .watch(apiClientProvider)
          .get(
            '/admin/dashboard',
            (data) => data == null ? null : AdminDashboard.fromJson(data as Map<String, dynamic>),
          );
    } on ApiException catch (e) {
      if (e.code == mfaRequiredCode) unawaited(auth.requireMfa());
      rethrow;
    }
  },
  // The tab has a retry button; automatic retries would repeat failing requests and call requireMfa again.
  retry: (_, _) => null,
);
