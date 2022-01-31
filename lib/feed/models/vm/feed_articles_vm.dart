import 'package:flutter/foundation.dart';

import 'article_vm.dart';

class FeedArticlesVm {
  final int page;
  final List<ArticleVm> articles;

  FeedArticlesVm({
    @required this.page,
    @required this.articles,
  });

  FeedArticlesVm copy() => FeedArticlesVm(
        page: page,
        articles: articles.toList(),
      );
}
