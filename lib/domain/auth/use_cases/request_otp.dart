import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class RequestOtp {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  Future<int> call({required String phone}) =>
      _repository.requestOtp(phone: phone.trim());
}
