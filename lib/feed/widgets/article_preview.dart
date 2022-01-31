import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'post_comment_button.dart';
import '../models/vm/article_vm.dart';
import '../pages/article_comments_page.dart';
import '../pages/article_page.dart';
import '../pages/youtube_video_page.dart';
import '../enums/article_type.dart';
import 'article_rating.dart';

class ArticlePreview extends StatelessWidget {
  final ArticleVm article;
  final int index;
  final String commentBlocInstanceIdentifier;

  const ArticlePreview({
    Key key,
    @required this.article,
    this.index,
    this.commentBlocInstanceIdentifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          color: index == null
              ? Colors.deepPurpleAccent[400]
              : index % 2 == 0
                  ? const Color(0xccbc4749)
                  : const Color(0xFF219ebc),
          margin: const EdgeInsets.only(top: 12.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 8.0, 4.0),
            child: Text(
              DateFormat('h:mm a   MMM d').format(article.postedAt),
              style: GoogleFonts.patuaOne(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Card(
          color: const Color.fromRGBO(238, 241, 246, 1.0),
          elevation: 8.0,
          margin: const EdgeInsets.fromLTRB(16.0, 52.0, 16.0, 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.isVideo)
                AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: Container(
                    color: Colors.black87,
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          article.previewImageUrl,
                          fit: BoxFit.cover,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (article.isYoutubeVideo) {
                              Navigator.of(context).pushNamed(
                                YoutubeVideoPage.routeName,
                                arguments: article.content,
                              );
                            } else {
                              throw UnimplementedError();
                            }
                          },
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white54,
                            size: 80.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!article.isVideo && article.previewImageUrl != null)
                AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: Container(
                    color: Colors.black87,
                    child: Image.network(
                      article.previewImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (article.previewImageUrl == null) SizedBox(height: 14.0),
              GestureDetector(
                onTap: !article.isVideo
                    ? () {
                        if (index != null) {
                          Navigator.of(context).pushNamed(
                            ArticlePage.routeName,
                            arguments: article.id,
                          );
                        } else {
                          Navigator.of(context).pushReplacementNamed(
                            ArticlePage.routeName,
                            arguments: article.id,
                          );
                        }
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    article.title,
                    style: GoogleFonts.patuaOne(
                      fontSize: 24.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (article.summary != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
                  child: Text(
                    article.summary,
                    style: GoogleFonts.josefinSans(
                      fontSize: 22.0,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Row(
                children: [
                  index != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ArticleCommentsPage.routeName,
                              arguments: article,
                            );
                          },
                          child: Container(
                            width: 120.0,
                            height: 50.0,
                            decoration: const BoxDecoration(
                              color: const Color(0xff4059ad),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: const Radius.circular(4.0),
                                topRight: const Radius.circular(4.0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 30.0,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  article.commentCount.toString(),
                                  style: GoogleFonts.lexendMega(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Container(
                              width: 120.0,
                              height: 50.0,
                              decoration: const BoxDecoration(
                                color: const Color(0xff4059ad),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: const Radius.circular(4.0),
                                  topRight: const Radius.circular(4.0),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 30.0,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10.0),
                                  Text(
                                    article.commentCount.toString(),
                                    style: GoogleFonts.lexendMega(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PostCommentButton(
                              commentBlocInstanceIdentifier:
                                  commentBlocInstanceIdentifier,
                              articleId: article.id,
                              commentPath: null,
                              size: 50.0,
                              iconSize: 30.0,
                            ),
                          ],
                        ),
                  Spacer(),
                  ArticleRating(article: article),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 30.0,
          left: 12.0,
          child: Card(
            color: const Color(0xff2b2d42),
            elevation: 3.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6.0,
              ),
              child: Text(
                article.type.name,
                style: GoogleFonts.patuaOne(
                  fontSize: 21.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
