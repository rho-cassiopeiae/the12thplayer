import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';

import '../models/dto/comment_rating_dto.dart';
import '../models/dto/requests/vote_for_comment_request_dto.dart';
import '../models/dto/article_rating_dto.dart';
import '../models/dto/requests/vote_for_article_request_dto.dart';
import '../models/dto/requests/post_comment_request_dto.dart';
import '../models/dto/comment_dto.dart';
import '../models/dto/requests/get_comments_for_article_request_dto.dart';
import '../enums/article_filter.dart';
import '../../general/errors/file_error.dart';
import '../models/dto/requests/get_articles_for_team_request_dto.dart';
import '../models/dto/article_dto.dart';
import '../models/dto/requests/get_article_request_dto.dart';
import '../models/dto/requests/post_article_request_dto.dart';
import '../enums/article_type.dart';
import '../errors/article_error.dart';
import '../../general/errors/connection_error.dart';
import '../../general/errors/server_error.dart';
import '../interfaces/ifeed_api_service.dart';
import '../../../../general/errors/api_error.dart';
import '../../../../general/errors/authentication_token_expired_error.dart';
import '../../../../general/errors/forbidden_error.dart';
import '../../../../general/errors/invalid_authentication_token_error.dart';
import '../../../../general/errors/validation_error.dart';
import '../../../../general/services/server_connector.dart';

class FeedApiService implements IFeedApiService {
  final ServerConnector _serverConnector;

  HubConnection get _connection => _serverConnector.feedConnection;
  Dio get _dio => _serverConnector.dioFeed;

  FeedApiService(this._serverConnector);

  dynamic _wrapHubException(Exception ex) {
    var errorMessage = ex.toString();
    if (errorMessage.contains('[AuthorizationError]')) {
      if (errorMessage.contains('Forbidden')) {
        return ForbiddenError();
      } else if (errorMessage.contains('token expired at')) {
        return AuthenticationTokenExpiredError();
      } else {
        return InvalidAuthenticationTokenError(
          errorMessage.split('[AuthorizationError] ').last,
        );
      }
    } else if (errorMessage.contains('[ValidationError]')) {
      return ValidationError();
    } else if (errorMessage.contains('[ArticleError]')) {
      return ArticleError(errorMessage.split('[ArticleError] ').last);
    }

    print(ex);

    return ServerError();
  }

  dynamic _wrapError(DioError dioError) {
    // ignore: missing_enum_constant_in_switch
    switch (dioError.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return ConnectionError();
      case DioErrorType.response:
        var statusCode = dioError.response.statusCode;
        if (statusCode >= 500) {
          return ServerError();
        }

        switch (statusCode) {
          case 400:
            var error = dioError.response.data['error'];
            if (error['type'] == 'Validation') {
              return ValidationError();
            } else if (error['type'] == 'File') {
              return FileError(
                error['errors'].values.first.first,
              );
            } else if (error['type'] == 'Article') {
              return ArticleError(
                error['errors'].values.first.first,
              );
            }
            break; // @@NOTE: Should never actually reach here.
          case 401:
            var errorMessage =
                dioError.response.data['error']['errors'].values.first.first;
            if (errorMessage.contains('token expired at')) {
              return AuthenticationTokenExpiredError();
            }
            return InvalidAuthenticationTokenError(errorMessage);
          case 403:
            return ForbiddenError();
        }
    }

    print(dioError);

    return ApiError();
  }

  @override
  Future<Iterable<ArticleDto>> getArticlesForTeam(
    int teamId,
    ArticleFilter filter,
    int page,
  ) async {
    await _serverConnector.ensureFeedConnected();

    try {
      var result = await _connection.invoke(
        'GetArticlesForTeam',
        args: [
          GetArticlesForTeamRequestDto(
            teamId: teamId,
            filter: filter,
            page: page,
          ),
        ],
      );

      return (result['data'] as List).map(
        (articleMap) => ArticleDto.fromMap(articleMap),
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<ArticleDto> getArticle(int articleId) async {
    await _serverConnector.ensureFeedConnected();

    try {
      var result = await _connection.invoke(
        'GetArticle',
        args: [
          GetArticleRequestDto(articleId: articleId),
        ],
      );

      return ArticleDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future postVideoArticle(
    int teamId,
    ArticleType type,
    String title,
    Uint8List thumbnailBytes,
    String summary,
    String videoUrl,
  ) async {
    var formData = FormData.fromMap(
      {
        'type': type.index,
        'title': title,
        'thumbnail': MultipartFile.fromBytes(
          thumbnailBytes,
          filename: 'thumbnail.jpg',
        ),
        'content': videoUrl,
      },
    );
    if (summary != null) {
      formData.fields.add(MapEntry('summary', summary));
    }

    try {
      await _dio.post(
        '/feed/teams/$teamId/video-article',
        options: Options(
          headers: {'Authorization': 'Bearer ${_serverConnector.accessToken}'},
        ),
        data: formData,
      );
    } on DioError catch (error) {
      throw _wrapError(error);
    }
  }

  @override
  Future postArticle(
    int teamId,
    ArticleType type,
    String title,
    String previewImageUrl,
    String summary,
    String content,
  ) async {
    await _serverConnector.ensureFeedConnected();

    try {
      await _connection.invoke(
        'PostArticle',
        args: [
          PostArticleRequestDto(
            teamId: teamId,
            type: type,
            title: title,
            previewImageUrl: previewImageUrl,
            summary: summary,
            content: content,
          ),
        ],
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<ArticleRatingDto> voteForArticle(int articleId, int userVote) async {
    await _serverConnector.ensureFeedConnected();

    try {
      var result = await _connection.invoke(
        'VoteForArticle',
        args: [
          VoteForArticleRequestDto(
            articleId: articleId,
            userVote: userVote,
          ),
        ],
      );

      return ArticleRatingDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<Iterable<CommentDto>> getCommentsForArticle(int articleId) async {
    await _serverConnector.ensureFeedConnected();

    try {
      var result = await _connection.invoke(
        'GetCommentsForArticle',
        args: [
          GetCommentsForArticleRequestDto(
            articleId: articleId,
          )
        ],
      );

      return (result['data'] as List).map(
        (map) => CommentDto.fromMap(map),
      );
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<CommentRatingDto> voteForComment(
    int articleId,
    String commentId,
    int userVote,
  ) async {
    await _serverConnector.ensureFeedConnected();

    try {
      var result = await _connection.invoke(
        'VoteForComment',
        args: [
          VoteForCommentRequestDto(
            articleId: articleId,
            commentId: commentId,
            userVote: userVote,
          ),
        ],
      );

      return CommentRatingDto.fromMap(result['data']);
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }

  @override
  Future<String> postComment(
    int articleId,
    String rootCommentId,
    String parentCommentId,
    String body,
  ) async {
    await _serverConnector.ensureFeedConnected();

    try {
      var result = await _connection.invoke(
        'PostComment',
        args: [
          PostCommentRequestDto(
            articleId: articleId,
            threadRootCommentId: rootCommentId,
            parentCommentId: parentCommentId,
            body: body,
          ),
        ],
      );

      return result['data'];
    } on Exception catch (ex) {
      throw _wrapHubException(ex);
    }
  }
}
