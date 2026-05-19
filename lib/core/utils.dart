import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetCurrentUser extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    return null;
  }

  void setCurrentUser(UserEntity user) {
    state = user;
  }

  void clearCurrentUser(UserEntity user) {
    state = null;
  }
}

final getCurrentUserProvider = NotifierProvider(() => GetCurrentUser());
