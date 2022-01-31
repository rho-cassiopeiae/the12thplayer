import 'package:flutter/foundation.dart';

import '../../../enums/article_filter.dart';

class GetArticlesForTeamRequestDto {
  final int teamId;
  final ArticleFilter filter;
  final int page;

  GetArticlesForTeamRequestDto({
    @required this.teamId,
    @required this.filter,
    @required this.page,
  });

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map['teamId'] = teamId;
    map['filter'] = filter.index;
    map['page'] = page;

    return map;
  }
}
