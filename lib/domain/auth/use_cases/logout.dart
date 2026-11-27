import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/service/push_service.dart';

import '../repositories/auth_repository.dart';

@injectable
class Logout {
  const Logout(this._repository, this._pushService);

  final AuthRepository _repository;
  final PushService _pushService;

  Future<void> call({bool allDevices = false}) async {
    await _pushService.removeDevice();
    await _repository.logout(allDevices: allDevices);
  }
}
