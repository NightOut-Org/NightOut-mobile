import 'package:json_annotation/json_annotation.dart';

part 'admin_dashboard.g.dart';

/// `GET /admin/dashboard`: one row of the `admin_dashboard()` rpc (web `Db.AdminDashboard`).
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class AdminDashboard {
  const AdminDashboard({
    required this.bookingsToday,
    required this.forfeitedToday,
    required this.barsPending,
    required this.depositsToVerify,
    required this.payoutsPending,
    required this.promoSlipsPending,
    required this.reviewsReported,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) => _$AdminDashboardFromJson(json);

  final int bookingsToday;
  final int forfeitedToday;
  final int barsPending;
  final int depositsToVerify;
  final int payoutsPending;
  final int promoSlipsPending;
  final int reviewsReported;
}
