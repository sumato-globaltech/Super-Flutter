import 'package:injectable/injectable.dart';

import '../entities/auth_status.dart';
import '../repositories/auth_repository.dart';

@injectable
class WatchAuthStatus {
  const WatchAuthStatus(this._repository);

  final AuthRepository _repository;

  Stream<AuthStatus> call() => _repository.status;
}
