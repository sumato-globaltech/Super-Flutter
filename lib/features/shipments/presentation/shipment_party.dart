import 'package:super_flutter/domain/auth/entities/access_policy.dart';

enum ShipmentParty {
  farmer,
  vendor,
  driver;

  static ShipmentParty of(AccessPolicy policy) => switch (policy.role) {
    Roles.vendor => ShipmentParty.vendor,
    Roles.driver => ShipmentParty.driver,
    _ => ShipmentParty.farmer,
  };
}
