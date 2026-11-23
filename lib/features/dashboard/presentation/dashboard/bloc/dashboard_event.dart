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
