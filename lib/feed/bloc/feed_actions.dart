import 'package:flutter/foundation.dart';

abstract class FeedAction {}

class CreateNewArticle extends FeedAction {
  final String content;

  CreateNewArticle({@required this.content});
}
