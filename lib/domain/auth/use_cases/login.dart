import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<User> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
