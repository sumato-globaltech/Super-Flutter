import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RefreshUser {
  const RefreshUser(this._repository);

  final AuthRepository _repository;

  Future<User> call() => _repository.refreshUser();
}
