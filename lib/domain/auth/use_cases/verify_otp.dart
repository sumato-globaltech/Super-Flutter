import 'package:injectable/injectable.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({required String phone, required String otp}) =>
      _repository.verifyOtp(phone: phone.trim(), otp: otp.trim());
}
