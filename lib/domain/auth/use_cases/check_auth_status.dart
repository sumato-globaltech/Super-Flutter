import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class CheckAuthStatus {
  const CheckAuthStatus(this._repository);

  final AuthRepository _repository;

  Future<bool> call() {
    return _repository.hasSession();
  }
}
