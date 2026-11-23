import 'package:equatable/equatable.dart';

class FarmPhotoModel extends Equatable {
  final String? id;
  final String? url;
  final String? mimeType;
  final int? size;
  final String? createdAt;

  const FarmPhotoModel({
    this.id,
    this.url,
    this.mimeType,
    this.size,
    this.createdAt,
  });

  factory FarmPhotoModel.fromJson(Map<String, dynamic> json) {
    return FarmPhotoModel(
      id: json['id'] as String?,
      url: json['url'] as String?,
      mimeType: json['mime_type'] as String?,
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse('${json['size']}'),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'mime_type': mimeType,
      'size': size,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, url, mimeType, size, createdAt];
}
