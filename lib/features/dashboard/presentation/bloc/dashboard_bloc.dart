import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_attendance_trend_usecase.dart';
import 'package:attendance_system_admin/features/dashboard/domain/usecases/get_kpis_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Bloc driving the dashboard's KPI row and attendance trend chart.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKpisUsecase _getKpisUsecase;
  final GetAttendanceTrendUsecase _getAttendanceTrendUsecase;

  DashboardBloc({
    required GetKpisUsecase getKpisUsecase,
    required GetAttendanceTrendUsecase getAttendanceTrendUsecase,
  }) : _getKpisUsecase = getKpisUsecase,
       _getAttendanceTrendUsecase = getAttendanceTrendUsecase,
       super(DashboardInitial()) {
    on<LoadDashboardRequested>(_onLoadDashboardRequested);
    on<TrendPeriodChanged>(_onTrendPeriodChanged);
  }

  Future<void> _onLoadDashboardRequested(
    LoadDashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final kpisResult = await _getKpisUsecase.call(NoParams());
    final trendResult = await _getAttendanceTrendUsecase.call(
      GetAttendanceTrendUsecaseParams(days: TrendPeriod.weekly.days),
    );

    final failure =
        kpisResult.fold((f) => f, (_) => null) ??
        trendResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(DashboardFailureState(failure.message));
      return;
    }

    final kpis = kpisResult.fold(
      (f) => throw StateError(f.message),
      (stats) => stats,
    );
    final trend = trendResult.fold(
      (f) => throw StateError(f.message),
      (points) => points,
    );

    emit(
      DashboardLoaded(kpis: kpis, trend: trend, period: TrendPeriod.weekly),
    );
  }

  Future<void> _onTrendPeriodChanged(
    TrendPeriodChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    if (current is! DashboardLoaded) {
      add(LoadDashboardRequested());
      return;
    }

    final trendResult = await _getAttendanceTrendUsecase.call(
      GetAttendanceTrendUsecaseParams(days: event.period.days),
    );
    trendResult.fold(
      // Keep the previous chart visible if the refresh fails.
      (failure) {},
      (trend) => emit(
        DashboardLoaded(
          kpis: current.kpis,
          trend: trend,
          period: event.period,
        ),
      ),
    );
  }
}
