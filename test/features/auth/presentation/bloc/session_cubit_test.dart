import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_state.dart';
import 'package:attendance_system_admin/features/institutes/domain/services/institute_context.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/institutes_fixture.dart';

class MockGetSessionUsecase extends Mock implements GetSessionUsecase {}

class MockGetInstitutesUsecase extends Mock implements GetInstitutesUsecase {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  setUpAll(() => registerFallbackValue(FakeNoParams()));

  late MockGetSessionUsecase getSession;
  late MockGetInstitutesUsecase getInstitutes;
  late InstituteContext context;

  setUp(() {
    getSession = MockGetSessionUsecase();
    getInstitutes = MockGetInstitutesUsecase();
    context = InstituteContext();
  });

  SessionCubit buildCubit() => SessionCubit(
    getSessionUsecase: getSession,
    getInstitutesUsecase: getInstitutes,
    instituteContext: context,
  );

  test('an activated super admin reaches SessionActive and is super admin', () async {
    final user = buildSuperAdmin(organization: tInstituteSlug);
    when(() => getSession(any())).thenAnswer((_) async => Right(user));
    when(
      () => getInstitutes(any()),
    ).thenAnswer((_) async => Right([tInstitute, tOtherInstitute]));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect((cubit.state as SessionActive).user.isSuperAdmin, isTrue);
    expect(context.isSuperAdmin, isTrue);
    expect(context.currentUser, user);
  });

  test('an invited account is routed to password setup, not the shell', () async {
    final invited = buildInvitedAdmin();
    when(() => getSession(any())).thenAnswer((_) async => Right(invited));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    final state = cubit.state as SessionInvited;
    expect(state.user.email, 'invited@example.com');
    expect(state.user.isActivated, isFalse);
    // No institute is selected for an account that cannot enter the app.
    expect(context.selectedSlug, isNull);
    verifyNever(() => getInstitutes(any()));
  });

  test('a regular admin is not a super admin', () async {
    final user = buildRegularAdmin(organization: tInstituteSlug);
    when(() => getSession(any())).thenAnswer((_) async => Right(user));
    when(
      () => getInstitutes(any()),
    ).thenAnswer((_) async => Right([tInstitute, tOtherInstitute]));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<SessionActive>());
    expect(context.isSuperAdmin, isFalse);
  });

  test('defaults the selection to the home institute', () async {
    // Home institute is Apex, which is in the registry.
    final user = buildSuperAdmin(organization: tInstituteSlug);
    when(() => getSession(any())).thenAnswer((_) async => Right(user));
    when(
      () => getInstitutes(any()),
    ).thenAnswer((_) async => Right([tOtherInstitute, tInstitute]));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(context.selectedSlug, tInstituteSlug);
    expect(context.homeSlug, tInstituteSlug);
  });

  test('still opens the shell when the registry fails to load', () async {
    final user = buildSuperAdmin();
    when(() => getSession(any())).thenAnswer((_) async => Right(user));
    when(() => getInstitutes(any())).thenAnswer(
      (_) async => Left(ServerFailure(message: 'registry unavailable')),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<SessionActive>());
  });

  test('a failed profile read does not open the shell', () async {
    when(() => getSession(any())).thenAnswer(
      (_) async => Left(ServerFailure(message: 'profile unavailable')),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect((cubit.state as SessionFailure).message, 'profile unavailable');
    expect(context.currentUser, isNull);
  });

  test('reload after password setup promotes an invited account', () async {
    final invited = buildInvitedAdmin(organization: tInstituteSlug);
    final activated = UserEntity(
      id: invited.id,
      email: invited.email,
      name: invited.name,
      department: invited.department,
      phoneNo: invited.phoneNo,
      role: invited.role,
      organization: invited.organization,
    );
    when(() => getSession(any())).thenAnswer((_) async => Right(invited));
    when(
      () => getInstitutes(any()),
    ).thenAnswer((_) async => Right([tInstitute]));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    // The profile read now reports 'active'.
    when(() => getSession(any())).thenAnswer((_) async => Right(activated));
    await cubit.reload();

    expect(context.selectedSlug, tInstituteSlug);
  });

  test('reset clears the cached identity on sign-out', () async {
    final user = buildSuperAdmin(organization: tInstituteSlug);
    when(() => getSession(any())).thenAnswer((_) async => Right(user));
    when(() => getInstitutes(any())).thenAnswer((_) async => Right([tInstitute]));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    cubit.reset();

    expect(cubit.state, isA<SessionInitial>());
    expect(context.currentUser, isNull);
    expect(context.selectedSlug, isNull);
  });
}