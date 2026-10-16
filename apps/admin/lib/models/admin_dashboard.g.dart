// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDashboard _$AdminDashboardFromJson(Map<String, dynamic> json) => AdminDashboard(
  bookingsToday: (json['bookings_today'] as num).toInt(),
  forfeitedToday: (json['forfeited_today'] as num).toInt(),
  barsPending: (json['bars_pending'] as num).toInt(),
  depositsToVerify: (json['deposits_to_verify'] as num).toInt(),
  payoutsPending: (json['payouts_pending'] as num).toInt(),
  promoSlipsPending: (json['promo_slips_pending'] as num).toInt(),
  reviewsReported: (json['reviews_reported'] as num).toInt(),
);
