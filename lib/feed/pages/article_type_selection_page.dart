import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:flutter/material.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:google_fonts/google_fonts.dart';

import 'article_preview_compose_page.dart';
import 'video_article_compose_page.dart';
import '../enums/article_type.dart';

// @@NOTE: We mutate data but don't actually need to redraw, so using stateful widget is not necessary.
// ignore: must_be_immutable
class ArticleTypeSelectionPage extends StatelessWidget {
  static const routeName = '/feed/article-type';

  ArticleType _type = ArticleType.News;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF273469),
        title: Text(
          'The12thPlayer',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: DirectSelectContainer(
        child: Column(
          children: [
            Spacer(flex: 2),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 8,
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Expanded(
                    child: DirectSelectList<ArticleType>(
                      values: ArticleType.values,
                      itemBuilder: (value) => DirectSelectItem<ArticleType>(
                        itemHeight: 56,
                        value: value,
                        itemBuilder: (_, value) => Text(
                          value.getString(),
                          style: GoogleFonts.exo2(fontSize: 20),
                        ),
                      ),
                      focusedItemDecoration: BoxDecoration(
                        border: BorderDirectional(
                          top: BorderSide(
                            width: 1,
                            color: Colors.black12,
                          ),
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.black12,
                          ),
                        ),
                      ),
                      onItemSelectedListener: (value, _, __) {
                        _type = value;
                      },
                    ),
                  ),
                  Icon(
                    Icons.unfold_more,
                    color: Colors.black38,
                  )
                ],
              ),
            ),
            Spacer(flex: 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF273469),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        onPressed: () {
          assert(_type != null);
          if (_type == ArticleType.Highlights || _type == ArticleType.Video) {
            Navigator.of(context).pushNamed(
              VideoArticleComposePage.routeName,
              arguments: _type,
            );
          } else {
            Navigator.of(context).pushNamed(
              ArticlePreviewComposePage.routeName,
              arguments: _type,
            );
          }
        },
      ),
    );
  }
}
