import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/publications/model/publication_model.dart';

enum PublicationsStatus { initial, loading, success, failure }

class PublicationsState extends Equatable {
  const PublicationsState({
    this.status = PublicationsStatus.initial,
    this.publications,
    this.loadingMore = false,
    this.errorMessage,
  });

  final PublicationsStatus status;
  final Paged<PublicationModel>? publications;
  final bool loadingMore;
  final String? errorMessage;

  PublicationsState copyWith({
    PublicationsStatus? status,
    Paged<PublicationModel>? publications,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return PublicationsState(
      status: status ?? this.status,
      publications: publications ?? this.publications,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, publications, loadingMore, errorMessage];
}
