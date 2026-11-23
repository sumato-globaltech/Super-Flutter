import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardSignOutRequested extends DashboardEvent {
  const DashboardSignOutRequested({this.allDevices = false});

  final bool allDevices;

  @override
  List<Object?> get props => [allDevices];
}

/// Loads the home, or loads it again on a pull. [districtId] adds the
/// district's alerts to the statewide ones.
class DashboardStarted extends DashboardEvent {
  const DashboardStarted({this.districtId});

  final String? districtId;

  @override
  List<Object?> get props => [districtId];
}
