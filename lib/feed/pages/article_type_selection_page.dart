import 'package:flutter/material.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:direct_select_flutter/direct_select_container.dart';

import 'video_article_compose_page.dart';
import '../enums/article_type.dart';

// @@NOTE: We mutate data but don't actually need to redraw, so using stateful widget is not necessary.
// ignore: must_be_immutable
class ArticleTypeSelectionPage extends StatelessWidget {
  static const routeName = '/feed/article-type';

  ArticleType _type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBar,
      body: DirectSelectContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              SizedBox(height: 150.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: AlignmentDirectional.centerStart,
                      margin: EdgeInsets.only(left: 4),
                      child: Text('Select type'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Card(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: DirectSelectList<ArticleType>(
                                  values: ArticleType.values,
                                  itemBuilder: (value) =>
                                      DirectSelectItem<ArticleType>(
                                    itemHeight: 56,
                                    value: value,
                                    itemBuilder: (_, value) => Text(
                                      value.getString(),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.unfold_more,
                                color: Colors.black38,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          assert(_type != null);
          if (_type == ArticleType.Highlights || _type == ArticleType.Video) {
            Navigator.of(context).pushNamed(
              VideoArticleComposePage.routeName,
              arguments: _type,
            );
          }
        },
      ),
    );
  }
}
