class VotedForVideoReactionDto {
  final int updatedRating;
  final int updatedVoteAction;

  VotedForVideoReactionDto.fromMap(Map<String, dynamic> map)
      : updatedRating = map['updatedRating'],
        updatedVoteAction = map.containsKey('updatedVoteAction')
            ? map['updatedVoteAction']
            : null;
}
