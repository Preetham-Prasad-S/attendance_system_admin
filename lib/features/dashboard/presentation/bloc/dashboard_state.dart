// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:flutter/foundation.dart';

/// Dashboard states.
@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final KpiStats kpis;
  final List<DailyAttendancePoint> trend;
  final TrendPeriod period;
  final List<DepartmentStat> departments;
  final List<DashboardAlert> alerts;

  DashboardLoaded({
    required this.kpis,
    required this.trend,
    required this.period,
    required this.departments,
    required this.alerts,
  });
}

class DashboardFailureState extends DashboardState {
  final String message;

  DashboardFailureState(this.message);
}
