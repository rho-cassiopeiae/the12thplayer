class PostedVideoReactionDto {
  final String videoId;
  final String thumbnailUrl;

  PostedVideoReactionDto.fromMap(Map<String, dynamic> map)
      : videoId = map['videoId'],
        thumbnailUrl = map['thumbnailUrl'];
}
