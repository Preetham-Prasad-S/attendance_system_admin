import 'package:attendance_system_admin/core/entities/account_status.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/institutes_fixture.dart';

class MockGetInstitutesUsecase extends Mock implements GetInstitutesUsecase {}

class MockCreateInstituteUsecase extends Mock
    implements CreateInstituteUsecase {}

class MockUpdateInstituteUsecase extends Mock
    implements UpdateInstituteUsecase {}

class MockGetInstituteAdminsUsecase extends Mock
    implements GetInstituteAdminsUsecase {}

class MockAssignAdminToInstituteUsecase extends Mock
    implements AssignAdminToInstituteUsecase {}

class MockInviteInstituteAdminUsecase extends Mock
    implements InviteInstituteAdminUsecase {}

class FakeNoParams extends Fake implements NoParams {}

class FakeInstituteSlugParams extends Fake implements InstituteSlugParams {}

class FakeUpdateInstituteRequest extends Fake
    implements UpdateInstituteRequest {}

class FakeAssignAdminParams extends Fake implements AssignAdminParams {}

class FakeInviteAdminParams extends Fake implements InviteAdminParams {}

class FakeCreateInstituteParams extends Fake implements CreateInstituteParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeInstituteSlugParams());
    registerFallbackValue(FakeUpdateInstituteRequest());
    registerFallbackValue(FakeAssignAdminParams());
    registerFallbackValue(FakeInviteAdminParams());
    registerFallbackValue(FakeCreateInstituteParams());
  });

  late MockGetInstitutesUsecase getInstitutes;
  late MockCreateInstituteUsecase createInstitute;
  late MockUpdateInstituteUsecase updateInstitute;
  late MockGetInstituteAdminsUsecase getAdmins;
  late MockAssignAdminToInstituteUsecase assignAdmin;
  late MockInviteInstituteAdminUsecase inviteAdmin;
  late dynamic context;
  late InstitutesBloc bloc;

  final tAdmins = [
    InstituteAdmin(
      id: 'p1',
      email: 'a@example.com',
      name: 'A Admin',
      status: AccountStatus.invited,
    ),
  ];

  setUp(() {
    getInstitutes = MockGetInstitutesUsecase();
    createInstitute = MockCreateInstituteUsecase();
    updateInstitute = MockUpdateInstituteUsecase();
    getAdmins = MockGetInstituteAdminsUsecase();
    assignAdmin = MockAssignAdminToInstituteUsecase();
    inviteAdmin = MockInviteInstituteAdminUsecase();
    context = buildInstituteContext();
    bloc = InstitutesBloc(
      getInstitutesUsecase: getInstitutes,
      createInstituteUsecase: createInstitute,
      updateInstituteUsecase: updateInstitute,
      getInstituteAdminsUsecase: getAdmins,
      assignAdminToInstituteUsecase: assignAdmin,
      inviteInstituteAdminUsecase: inviteAdmin,
      instituteContext: context,
    );
  });

  tearDown(() => bloc.close());

  group('load', () {
    test('publishes the registry and keeps the context selection', () async {
      when(() => getInstitutes(any())).thenAnswer(
        (_) async => Right([tInstitute, tOtherInstitute]),
      );

      bloc.add(const InstitutesLoadRequested());
      await bloc.stream.firstWhere((s) => !s.isLoading && s.institutes.isNotEmpty);

      expect(bloc.state.institutes.length, 2);
      expect(bloc.state.selectedSlug, tInstituteSlug);
    });

    test('surfaces a failure as an error banner and stops loading', () async {
      when(() => getInstitutes(any())).thenAnswer(
        (_) async => Left(ServerFailure(message: 'registry unavailable')),
      );

      bloc.add(const InstitutesLoadRequested());
      await bloc.stream.firstWhere((s) => s.feedbackMessage != null);

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.feedbackMessage, 'registry unavailable');
      expect(bloc.state.feedbackIsError, isTrue);
    });

    test('adopts the user home institute when the context has none', () async {
      final emptyContext = buildInstituteContext(user: buildSuperAdmin());
      emptyContext.clear();
      final fresh = InstitutesBloc(
        getInstitutesUsecase: getInstitutes,
        createInstituteUsecase: createInstitute,
        updateInstituteUsecase: updateInstitute,
        getInstituteAdminsUsecase: getAdmins,
        assignAdminToInstituteUsecase: assignAdmin,
        inviteInstituteAdminUsecase: inviteAdmin,
        instituteContext: emptyContext,
      );
      addTearDown(fresh.close);

      // Super admin's home institute is CampusPulse, which is not in the list,
      // so nothing is selected rather than an unrelated institute.
      when(() => getInstitutes(any())).thenAnswer(
        (_) async => Right([tInstitute, tOtherInstitute]),
      );
      fresh.add(const InstitutesLoadRequested());
      await fresh.stream.firstWhere((s) => !s.isLoading && s.institutes.isNotEmpty);

      expect(emptyContext.selectedSlug, isNull);
      await fresh.close();
    });
  });

  group('selection', () {
    test('switching updates the context so datasources re-scope', () async {
      bloc.add(InstituteSelected(tOtherInstitute));
      await bloc.stream.firstWhere((s) => s.selectedSlug == tOtherInstituteSlug);

      expect(context.selectedSlug, tOtherInstituteSlug);
    });

    test('switching drops the previous institute admin list', () async {
      when(() => getAdmins(any())).thenAnswer((_) async => Right(tAdmins));
      bloc.add(InstituteAdminsRequested(tInstituteSlug));
      await bloc.stream.firstWhere((s) => s.admins.isNotEmpty);

      bloc.add(InstituteSelected(tOtherInstitute));
      await bloc.stream.firstWhere((s) => s.admins.isEmpty);

      expect(bloc.state.admins, isEmpty);
      expect(bloc.state.adminsForSlug, isNull);
    });
  });

  group('switchableInstitutes', () {
    test('omits deactivated institutes but keeps them in the list', () async {
      when(() => getInstitutes(any())).thenAnswer(
        (_) async => Right([
          tInstitute,
          const Institute(
            id: 'i3',
            slug: 'old-college',
            name: 'Old College',
            isActive: false,
          ),
        ]),
      );

      bloc.add(const InstitutesLoadRequested());
      await bloc.stream.firstWhere((s) => !s.isLoading && s.institutes.isNotEmpty);

      expect(bloc.state.institutes.length, 2);
      expect(bloc.state.switchableInstitutes.length, 1);
      expect(bloc.state.switchableInstitutes.single.slug, tInstituteSlug);
    });
  });

  group('create', () {
    test('appends the new institute and confirms', () async {
      when(() => getInstitutes(any())).thenAnswer(
        (_) async => Right([tInstitute]),
      );
      bloc.add(const InstitutesLoadRequested());
      await bloc.stream.firstWhere((s) => !s.isLoading && s.institutes.isNotEmpty);

      final created = const Institute(id: 'i4', slug: 'new-one', name: 'New One');
      when(() => createInstitute(any())).thenAnswer((_) async => Right(created));

      bloc.add(
        InstituteCreateRequested(const CreateInstituteParams(name: 'New One')),
      );
      await bloc.stream.firstWhere((s) => s.institutes.length == 2);

      expect(bloc.state.feedbackMessage, contains('New One'));
      expect(bloc.state.feedbackIsError, isFalse);
    });

    test('reports a duplicate slug as an error', () async {
      when(() => createInstitute(any())).thenAnswer(
        (_) async => Left(
          ServerFailure(message: 'An institute named "New One" already exists.'),
        ),
      );

      bloc.add(
        InstituteCreateRequested(const CreateInstituteParams(name: 'New One')),
      );
      await bloc.stream.firstWhere((s) => s.feedbackMessage != null);

      expect(bloc.state.feedbackIsError, isTrue);
      expect(bloc.state.isSubmitting, isFalse);
    });
  });

  group('update', () {
    test('deactivating reports the institute was deactivated', () async {
      when(() => getInstitutes(any())).thenAnswer(
        (_) async => Right([tInstitute]),
      );
      bloc.add(const InstitutesLoadRequested());
      await bloc.stream.firstWhere((s) => !s.isLoading && s.institutes.isNotEmpty);

      when(() => updateInstitute(any())).thenAnswer(
        (_) async => Right(tInstitute.copyWith(isActive: false)),
      );

      bloc.add(
        InstituteUpdateRequested(
          UpdateInstituteRequest(
            slug: tInstituteSlug,
            changes: const UpdateInstituteParams(isActive: false),
          ),
        ),
      );
      await bloc.stream.firstWhere((s) => !s.institutes.first.isActive);

      expect(bloc.state.feedbackMessage, contains('deactivated'));
    });
  });

  group('admins', () {
    test('loads the admin list for the requested institute', () async {
      when(() => getAdmins(any())).thenAnswer((_) async => Right(tAdmins));

      bloc.add(InstituteAdminsRequested(tInstituteSlug));
      await bloc.stream.firstWhere((s) => s.admins.isNotEmpty);

      expect(bloc.state.adminsForSlug, tInstituteSlug);
      expect(bloc.state.admins.single.email, 'a@example.com');
    });

    test('keeps the admin list scoped to the requested institute', () async {
      when(() => getAdmins(any())).thenAnswer((_) async => Right(tAdmins));

      bloc.add(InstituteAdminsRequested(tOtherInstituteSlug));
      await bloc.stream.firstWhere((s) => s.admins.isNotEmpty);

      expect(bloc.state.adminsForSlug, tOtherInstituteSlug);
    });
  });

  group('invite', () {
    test('stores the returned setup link for sharing', () async {
      when(() => getAdmins(any())).thenAnswer((_) async => Right(tAdmins));
      when(() => inviteAdmin(any())).thenAnswer(
        (_) async => const Right(
          InviteAdminResult(
            profileId: 'p9',
            setupLink: 'https://app.example.com/#access_token=abc',
          ),
        ),
      );

      bloc.add(
        InstituteAdminInvited(
          const InviteAdminParams(
            name: 'A Admin',
            email: 'a@example.com',
            instituteSlug: tInstituteSlug,
          ),
        ),
      );
      await bloc.stream.firstWhere((s) => s.inviteSetupLink != null);

      expect(bloc.state.feedbackMessage, contains('a@example.com'));
      expect(
        bloc.state.inviteSetupLink,
        'https://app.example.com/#access_token=abc',
      );
    });

    test('surfaces the function error message', () async {
      when(() => getAdmins(any())).thenAnswer((_) async => Right(tAdmins));
      when(() => inviteAdmin(any())).thenAnswer(
        (_) async => Left(
          ServerFailure(message: 'Only a super admin can invite admins.'),
        ),
      );

      bloc.add(
        InstituteAdminInvited(
          const InviteAdminParams(
            name: 'A Admin',
            email: 'a@example.com',
            instituteSlug: tInstituteSlug,
          ),
        ),
      );
      await bloc.stream.firstWhere((s) => s.feedbackMessage != null);

      expect(bloc.state.feedbackMessage, 'Only a super admin can invite admins.');
      expect(bloc.state.feedbackIsError, isTrue);
      expect(bloc.state.inviteSetupLink, isNull);
    });
  });
}
