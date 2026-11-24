import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/meetings/model/district_option_model.dart';
import 'package:super_flutter/data/support/model/category_model.dart';

import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/facilities/model/facility_model.dart';

enum FacilitiesStatus { initial, loading, success, failure }

/// Category and district ids; null shows all of them.
typedef FacilitiesFilter = ({String? category, String? district});

class FacilitiesState extends Equatable {
  const FacilitiesState({
    this.status = FacilitiesStatus.initial,
    this.facilities,
    this.loadingMore = false,
    this.errorMessage,
    this.filter = (category: null, district: null),
    this.categories = const [],
    this.districts = const [],
  });

  final FacilitiesStatus status;
  final Paged<FacilityModel>? facilities;
  final bool loadingMore;
  final String? errorMessage;
  final FacilitiesFilter filter;
  final List<CategoryModel> categories;
  final List<DistrictOptionModel> districts;

  FacilitiesState copyWith({
    FacilitiesStatus? status,
    Paged<FacilityModel>? facilities,
    bool? loadingMore,
    String? errorMessage,
    FacilitiesFilter? filter,
    List<CategoryModel>? categories,
    List<DistrictOptionModel>? districts,
    bool clear = false,
  }) {
    return FacilitiesState(
      status: status ?? this.status,
      facilities: clear ? null : (facilities ?? this.facilities),
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
      categories: categories ?? this.categories,
      districts: districts ?? this.districts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    facilities,
    loadingMore,
    errorMessage,
    filter,
    categories,
    districts,
  ];
}
