import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final String id;
  final String url;
  final String title;
  final String size;

  const VideoEntity({
    required this.id,
    required this.url,
    required this.title,
    required this.size,
  });

  @override
  List<Object?> get props => [id, url, title, size];
}
