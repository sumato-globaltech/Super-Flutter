import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
