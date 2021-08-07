import '../models/dto/team_feed_update_dto.dart';

abstract class IFeedApiService {
  Future<Stream<TeamFeedUpdateDto>> subscribeToTeamFeed(int teamId);
}
