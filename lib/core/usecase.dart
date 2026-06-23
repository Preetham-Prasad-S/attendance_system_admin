import 'package:attendance_system_admin/core/failure.dart';
import 'package:fpdart/fpdart.dart';

/// Base Usecase interface.
abstract class Usecase<UsecaseType, UsecaseParams> {
  /// Executes the usecase with the given [params].
  /// Returns an [Either] containing a [Failure] on the left side or the
  /// successful [Output] on the right side.
  Future<Either<Failure, UsecaseType>> call(UsecaseParams params);
}

/// Use when a usecase does not require any parameters.
class NoParams {}
