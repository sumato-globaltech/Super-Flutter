import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<void> call({bool allDevices = false}) =>
      _repository.logout(allDevices: allDevices);
}
