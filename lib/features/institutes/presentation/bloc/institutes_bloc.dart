import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/institutes/domain/services/institute_context.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_event.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives the institutes registry, the sidebar switcher and the Institutes
/// management page.
///
/// Handlers run concurrently (bloc default), so async continuations re-read
/// [state] and carry the slug they were asked about rather than trusting
/// [state]'s latest selection.
class InstitutesBloc extends Bloc<InstitutesEvent, InstitutesState> {
  final GetInstitutesUsecase _getInstitutesUsecase;
  final CreateInstituteUsecase _createInstituteUsecase;
  final UpdateInstituteUsecase _updateInstituteUsecase;
  final GetInstituteAdminsUsecase _getInstituteAdminsUsecase;
  final AssignAdminToInstituteUsecase _assignAdminToInstituteUsecase;
  final InviteInstituteAdminUsecase _inviteInstituteAdminUsecase;
  final InstituteContext _instituteContext;

  InstitutesBloc({
    required GetInstitutesUsecase getInstitutesUsecase,
    required CreateInstituteUsecase createInstituteUsecase,
    required UpdateInstituteUsecase updateInstituteUsecase,
    required GetInstituteAdminsUsecase getInstituteAdminsUsecase,
    required AssignAdminToInstituteUsecase assignAdminToInstituteUsecase,
    required InviteInstituteAdminUsecase inviteInstituteAdminUsecase,
    required InstituteContext instituteContext,
  }) : _getInstitutesUsecase = getInstitutesUsecase,
       _createInstituteUsecase = createInstituteUsecase,
       _updateInstituteUsecase = updateInstituteUsecase,
       _getInstituteAdminsUsecase = getInstituteAdminsUsecase,
       _assignAdminToInstituteUsecase = assignAdminToInstituteUsecase,
       _inviteInstituteAdminUsecase = inviteInstituteAdminUsecase,
       _instituteContext = instituteContext,
       super(const InstitutesState()) {
    on<InstitutesLoadRequested>(_onLoadRequested);
    on<InstituteSelected>(_onInstituteSelected);
    on<InstituteCreateRequested>(_onCreateRequested);
    on<InstituteUpdateRequested>(_onUpdateRequested);
    on<InstituteAdminsRequested>(_onAdminsRequested);
    on<InstituteAdminAssigned>(_onAdminAssigned);
    on<InstituteAdminInvited>(_onAdminInvited);
    on<InstitutesFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onLoadRequested(
    InstitutesLoadRequested event,
    Emitter<InstitutesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearFeedback: true));

    final result = await _getInstitutesUsecase(NoParams());
    final institutes = result.fold((_) => null, (list) => list);
    if (institutes == null) {
      emit(
        state.copyWith(
          isLoading: false,
          feedbackMessage: result.fold((f) => f.message, (_) => ''),
          feedbackIsError: true,
        ),
      );
      return;
    }

    // Adopt the context's selection (set by SessionCubit) if the registry
    // still contains it; otherwise fall back to the user's home institute.
    final contextSlug = _instituteContext.selectedSlug;
    final known = institutes.any((institute) => institute.slug == contextSlug);
    if (!known) {
      _instituteContext.selectHomeInstitute(institutes);
    }

    emit(
      state.copyWith(
        institutes: institutes,
        selectedSlug: _instituteContext.selectedSlug,
        isLoading: false,
      ),
    );
  }

  void _onInstituteSelected(
    InstituteSelected event,
    Emitter<InstitutesState> emit,
  ) {
    _instituteContext.selectInstitute(event.institute);
    // The loaded admin list belongs to the previous institute.
    emit(
      state.copyWith(
        selectedSlug: event.institute.slug,
        clearAdmins: true,
        clearFeedback: true,
        clearInviteSetupLink: true,
      ),
    );
  }

  Future<void> _onCreateRequested(
    InstituteCreateRequested event,
    Emitter<InstitutesState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));

    final result = await _createInstituteUsecase(event.params);
    final created = result.fold((_) => null, (institute) => institute);
    if (created == null) {
      emit(_failure(result.fold((f) => f.message, (_) => '')));
      return;
    }

    emit(
      state.copyWith(
        institutes: <dynamic>[...state.institutes, created].cast(),
        isSubmitting: false,
        feedbackMessage: 'Institute "${created.name}" was created.',
      ),
    );
  }

  Future<void> _onUpdateRequested(
    InstituteUpdateRequested event,
    Emitter<InstitutesState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));

    final result = await _updateInstituteUsecase(event.request);
    final updated = result.fold((_) => null, (institute) => institute);
    if (updated == null) {
      emit(_failure(result.fold((f) => f.message, (_) => '')));
      return;
    }

    final institutes = state.institutes
        .map((institute) => institute.slug == updated.slug ? updated : institute)
        .toList(growable: false);

    // Keep the switcher's selection in step with the edited record.
    if (_instituteContext.selectedSlug == updated.slug) {
      _instituteContext.selectInstitute(updated);
    }

    emit(
      state.copyWith(
        institutes: institutes,
        isSubmitting: false,
        feedbackMessage: updated.isActive
            ? 'Institute details saved.'
            : 'Institute "${updated.name}" was deactivated.',
      ),
    );
  }

  Future<void> _onAdminsRequested(
    InstituteAdminsRequested event,
    Emitter<InstitutesState> emit,
  ) async {
    final slug = event.slug;
    emit(state.copyWith(isLoadingAdmins: true, clearFeedback: true));

    final result = await _getInstituteAdminsUsecase(
      InstituteSlugParams(slug: slug),
    );
    final admins = result.fold((_) => null, (list) => list);
    if (admins == null) {
      emit(
        state.copyWith(
          isLoadingAdmins: false,
          feedbackMessage: result.fold((f) => f.message, (_) => ''),
          feedbackIsError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        admins: admins,
        adminsForSlug: slug,
        isLoadingAdmins: false,
      ),
    );
  }

  Future<void> _onAdminAssigned(
    InstituteAdminAssigned event,
    Emitter<InstitutesState> emit,
  ) async {
    final params = event.params;
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));

    final result = await _assignAdminToInstituteUsecase(params);
    final failed = result.fold((_) => true, (_) => false);
    if (failed) {
      emit(_failure(result.fold((f) => f.message, (_) => '')));
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        feedbackMessage: 'Admin assigned to this institute.',
      ),
    );
    add(InstituteAdminsRequested(params.slug));
  }

  Future<void> _onAdminInvited(
    InstituteAdminInvited event,
    Emitter<InstitutesState> emit,
  ) async {
    final params = event.params;
    emit(
      state.copyWith(
        isSubmitting: true,
        clearFeedback: true,
        clearInviteSetupLink: true,
      ),
    );

    final result = await _inviteInstituteAdminUsecase(params);
    final invited = result.fold((_) => null, (invite) => invite);
    if (invited == null) {
      emit(_failure(result.fold((f) => f.message, (_) => '')));
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        feedbackMessage: 'Invitation created for ${params.email}.',
        inviteSetupLink: invited.setupLink,
      ),
    );
    add(InstituteAdminsRequested(params.instituteSlug));
  }

  void _onFeedbackCleared(
    InstitutesFeedbackCleared event,
    Emitter<InstitutesState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true, clearInviteSetupLink: true));
  }

  InstitutesState _failure(String message) => state.copyWith(
    isSubmitting: false,
    feedbackMessage: message,
    feedbackIsError: true,
  );
}