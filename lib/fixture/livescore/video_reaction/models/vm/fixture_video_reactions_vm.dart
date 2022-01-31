import 'package:flutter/foundation.dart';

import '../dto/fixture_video_reactions_dto.dart';
import 'video_reaction_vm.dart';

class FixtureVideoReactionsVm {
  final int page;
  final int totalPages;
  final List<VideoReactionVm> videoReactions;

  FixtureVideoReactionsVm({
    @required this.page,
    @required this.totalPages,
    @required this.videoReactions,
  });

  FixtureVideoReactionsVm.fromDto(
    FixtureVideoReactionsDto fixtureVideoReactions,
  )   : page = fixtureVideoReactions.page,
        totalPages = fixtureVideoReactions.totalPages,
        videoReactions = fixtureVideoReactions.videoReactions
            .map((reaction) => VideoReactionVm.fromDto(reaction))
            .toList();

  FixtureVideoReactionsVm copy() => FixtureVideoReactionsVm(
        page: page,
        totalPages: totalPages,
        videoReactions: videoReactions.toList(),
      );
}
