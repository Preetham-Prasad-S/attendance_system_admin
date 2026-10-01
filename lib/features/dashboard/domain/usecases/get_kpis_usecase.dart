// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:attendance_system_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that fetches the aggregated dashboard KPI figures.
class GetKpisUsecase implements Usecase<KpiStats, NoParams> {
  final DashboardRepository _dashboardRepository;

  GetKpisUsecase({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  @override
  Future<Either<Failure, KpiStats>> call(NoParams params) {
    return _dashboardRepository.getKpis();
  }
}
