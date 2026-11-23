import 'package:equatable/equatable.dart';

sealed class CropsListEvent extends Equatable {
  const CropsListEvent();

  @override
  List<Object?> get props => [];
}

class CropsListStarted extends CropsListEvent {
  final String? search;
  final String? type;

  const CropsListStarted({this.search, this.type});

  @override
  List<Object?> get props => [search, type];
}

class CropsListSearchChanged extends CropsListEvent {
  final String search;

  const CropsListSearchChanged(this.search);

  @override
  List<Object?> get props => [search];
}

class CropsListTypeSelected extends CropsListEvent {
  final String? type;

  const CropsListTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class CropsListMoreRequested extends CropsListEvent {
  const CropsListMoreRequested();
}

class CropsListRefreshed extends CropsListEvent {
  const CropsListRefreshed();
}
