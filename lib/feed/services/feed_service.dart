import 'package:either_option/either_option.dart';

import '../interfaces/ifeed_api_service.dart';
import '../models/vm/article_vm.dart';
import '../../general/persistence/storage.dart';
import '../../general/errors/error.dart';

class FeedService {
  final Storage _storage;
  final IFeedApiService _feedApiService;

  FeedService(this._storage, this._feedApiService);

  Stream<Either<Error, List<ArticleVm>>> subscribeToFeed() async* {
    try {
      var currentTeam = await _storage.loadCurrentTeam();

      _storage.clearTeamFeedArticles();

      await for (var update
          in await _feedApiService.subscribeToTeamFeed(currentTeam.id)) {
        var articles = update.articles
            .map((article) => ArticleVm.fromDto(article))
            .toList();

        _storage.addTeamFeedArticles(articles);

        yield Right(_storage.getTeamFeedArticles());
      }
    } catch (error, stackTrace) {
      print('===== $error =====');
      print(stackTrace);

      yield Left(Error(error.toString()));
    }
  }

  Future createNewArticle(String content) async {
    print(content);
  }
}
