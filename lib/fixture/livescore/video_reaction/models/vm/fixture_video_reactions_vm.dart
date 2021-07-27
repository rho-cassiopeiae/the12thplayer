import '../dto/fixture_video_reactions_dto.dart';
import 'video_reaction_vm.dart';

class FixtureVideoReactionsVm {
  final int fixtureId;
  final List<VideoReactionVm> reactions;

  FixtureVideoReactionsVm._(
    this.fixtureId,
    this.reactions,
  );

  FixtureVideoReactionsVm.fromDto(
    FixtureVideoReactionsDto fixtureVideoReactions,
  )   : fixtureId = fixtureVideoReactions.fixtureId,
        reactions = fixtureVideoReactions.reactions
            .map((reaction) => VideoReactionVm.fromDto(reaction))
            .toList();

  FixtureVideoReactionsVm copy() {
    return FixtureVideoReactionsVm._(
      fixtureId,
      List<VideoReactionVm>.from(reactions),
    );
  }
}
