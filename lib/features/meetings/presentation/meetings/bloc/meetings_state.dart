import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/meetings/model/district_option_model.dart';

import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/meetings/model/meeting_model.dart';

enum MeetingsStatus { initial, loading, success, failure }

class MeetingsState extends Equatable {
  const MeetingsState({
    this.status = MeetingsStatus.initial,
    this.meetings,
    this.loadingMore = false,
    this.errorMessage,
    this.district,
    this.districts = const [],
  });

  final MeetingsStatus status;
  final Paged<MeetingModel>? meetings;
  final bool loadingMore;
  final String? errorMessage;
  final String? district;
  final List<DistrictOptionModel> districts;

  MeetingsState copyWith({
    MeetingsStatus? status,
    Paged<MeetingModel>? meetings,
    bool? loadingMore,
    String? errorMessage,
    String? district,
    List<DistrictOptionModel>? districts,
    bool clear = false,
  }) {
    return MeetingsState(
      status: status ?? this.status,
      meetings: clear ? null : (meetings ?? this.meetings),
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
      district: district ?? this.district,
      districts: districts ?? this.districts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    meetings,
    loadingMore,
    errorMessage,
    district,
    districts,
  ];
}
