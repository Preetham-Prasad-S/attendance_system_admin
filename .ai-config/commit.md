refactor(auth, ui): improve DI registration and desktop UI layout

- Updated BaseDesktopScreen to align children to start.
- Fixed DI registration to use concrete implementations (AuthDatasourceImpl, AuthRepositoryImpl) for AuthRepository and SignupUsecase.
- Removed debug print statements from AuthBloc.
- Removed unnecessary BouncingScrollPhysics from EmployeeDesktopScreen.
- Adjusted imports in main.dart and set home to BaseScreen for unified layout.
