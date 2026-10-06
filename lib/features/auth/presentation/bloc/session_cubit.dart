import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:attendance_system_admin/features/institutes/domain/services/institute_context.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'session_state.dart';

/// Resolves who is signed in and which institute is being viewed, and gates
/// the app: [SessionInvited] sends an account that has not completed password
/// setup to the setup screen, [SessionActive] opens the shell.
///
/// The institute list is awaited here on purpose. A super admin's RLS allows
/// rows from every institute, so entering the shell with a null selection
/// would issue an unscoped query and merge all institutes into one table.
/// Only once the registry is loaded is a default selection guaranteed.
///
/// (This is the one place the auth feature reaches into the institutes
/// feature; the alternative is every page racing an unscoped load.)
class SessionCubit extends Cubit<SessionState> {
  final GetSessionUsecase _getSessionUsecase;
  final GetInstitutesUsecase _getInstitutesUsecase;
  final InstituteContext _instituteContext;

  SessionCubit({
    required GetSessionUsecase getSessionUsecase,
    required GetInstitutesUsecase getInstitutesUsecase,
    required InstituteContext instituteContext,
  }) : _getSessionUsecase = getSessionUsecase,
       _getInstitutesUsecase = getInstitutesUsecase,
       _instituteContext = instituteContext,
       super(const SessionInitial());

  Future<void> load() async {
    emit(const SessionLoading());

    final userResult = await _getSessionUsecase(NoParams());
    final user = userResult.fold(
      (failure) => null,
      (user) => user,
    );
    if (user == null) {
      emit(
        SessionFailure(
          userResult.fold((failure) => failure.message, (_) => ''),
        ),
      );
      return;
    }

    _instituteContext.setCurrentUser(user);

    if (!user.isActivated) {
      emit(SessionInvited(user));
      return;
    }

    // Default the selection to the user's own institute. A failure here is not
    // fatal: the pages surface their own empty/error state instead.
    final institutesResult = await _getInstitutesUsecase(NoParams());
    institutesResult.fold(
      (_) {},
      (institutes) => _instituteContext.selectHomeInstitute(institutes),
    );

    emit(SessionActive(user));
  }

  /// Re-runs [load] after the invited account finishes password setup.
  Future<void> reload() => load();

  /// Clears cached identity on sign-out.
  void reset() {
    _instituteContext.clear();
    emit(const SessionInitial());
  }
}