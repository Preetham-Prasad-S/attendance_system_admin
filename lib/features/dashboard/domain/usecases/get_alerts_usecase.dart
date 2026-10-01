// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:attendance_system_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that derives operational alerts from attendance data.
class GetAlertsUsecase implements Usecase<List<DashboardAlert>, NoParams> {
  final DashboardRepository _dashboardRepository;

  GetAlertsUsecase({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  @override
  Future<Either<Failure, List<DashboardAlert>>> call(NoParams params) {
    return _dashboardRepository.getAlerts();
  }
}
