import 'package:injectable/injectable.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

@injectable
class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({required String email, required String password}) {
    return _repository.login(email: email.trim(), password: password);
  }
}
