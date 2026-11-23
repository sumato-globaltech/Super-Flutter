import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class PasswordChanged {
  const PasswordChanged(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.passwordChanged();
}
