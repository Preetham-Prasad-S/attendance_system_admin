// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:attendance_system_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that fetches daily attendance points for the trend chart.
class GetAttendanceTrendUsecase
    implements
        Usecase<List<DailyAttendancePoint>, GetAttendanceTrendUsecaseParams> {
  final DashboardRepository _dashboardRepository;

  GetAttendanceTrendUsecase({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  @override
  Future<Either<Failure, List<DailyAttendancePoint>>> call(
    GetAttendanceTrendUsecaseParams params,
  ) {
    return _dashboardRepository.getAttendanceTrend(params.days);
  }
}

/// Parameters for the attendance trend use case.
class GetAttendanceTrendUsecaseParams {
  final int days;

  GetAttendanceTrendUsecaseParams({required this.days});
}
