// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:flutter/foundation.dart';

/// Dashboard events.
@immutable
abstract class DashboardEvent {}

class LoadDashboardRequested extends DashboardEvent {}

class TrendPeriodChanged extends DashboardEvent {
  final TrendPeriod period;

  TrendPeriodChanged({required this.period});
}
