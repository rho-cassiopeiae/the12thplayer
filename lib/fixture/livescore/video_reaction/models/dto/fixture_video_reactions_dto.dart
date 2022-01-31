import 'video_reaction_dto.dart';

class FixtureVideoReactionsDto {
  final int page;
  final int totalPages;
  final Iterable<VideoReactionDto> videoReactions;

  FixtureVideoReactionsDto.fromMap(Map<String, dynamic> map)
      : page = map['page'],
        totalPages = map['totalPages'],
        videoReactions = (map['videoReactions'] as List)
            .map((reactionMap) => VideoReactionDto.fromMap(reactionMap));
}
