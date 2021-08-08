enum ArticleType {
  News,
  Interview,
  MatchPreview,
  MatchReport,
  Highlights,
  BlogPost,
  Video,
}

extension ArticleTypeExtension on ArticleType {
  String getString() {
    switch (this) {
      case ArticleType.News:
        return 'News';
      case ArticleType.Interview:
        return 'Interview';
      case ArticleType.MatchPreview:
        return 'Match Preview';
      case ArticleType.MatchReport:
        return 'Match Report';
      case ArticleType.Highlights:
        return 'Highlights';
      case ArticleType.BlogPost:
        return 'Blog Post';
      case ArticleType.Video:
        return 'Video';
    }

    return null;
  }
}
