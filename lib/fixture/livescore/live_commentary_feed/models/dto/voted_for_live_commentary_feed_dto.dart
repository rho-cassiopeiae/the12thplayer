class VotedForLiveCommentaryFeedDto {
  final int updatedRating;
  final int updatedVoteAction;

  VotedForLiveCommentaryFeedDto.fromMap(Map<String, dynamic> map)
      : updatedRating = map['updatedRating'],
        updatedVoteAction = map.containsKey('updatedVoteAction')
            ? map['updatedVoteAction']
            : null;
}
