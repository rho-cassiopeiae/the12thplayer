import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/link_dialog.dart';
import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_states.dart';
import '../enums/article_type.dart';
import '../../general/extensions/kiwi_extension.dart';
import 'article_compose_page.dart';

class ArticlePreviewComposePage extends StatefulWidget
    with DependencyResolver<FeedBloc> {
  static const routeName = '/feed/article-preview-compose';

  final ArticleType type;

  const ArticlePreviewComposePage({
    Key key,
    @required this.type,
  }) : super(key: key);

  @override
  _ArticlePreviewComposePageState createState() =>
      _ArticlePreviewComposePageState(resolve());
}

class _ArticlePreviewComposePageState extends State<ArticlePreviewComposePage> {
  final FeedBloc _feedBloc;

  String _title;
  String _previewImageUrl;
  String _summary;

  _ArticlePreviewComposePageState(this._feedBloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF398AE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF398AE5),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CA8F1),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    onChanged: (value) => _title = value,
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 14.0),
                      prefixIcon: Icon(
                        Icons.text_fields,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  border: _previewImageUrl == null
                      ? Border.all(
                          color: Colors.white,
                          width: 4,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: _previewImageUrl == null
                    ? InkWell(
                        onTap: () async {
                          var url = await showDialog<String>(
                            context: context,
                            builder: (_) => const LinkDialog(),
                          );

                          if (url != null) {
                            setState(() {
                              _previewImageUrl = url;
                            });
                          }
                        },
                        child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 120,
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _previewImageUrl,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CA8F1),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    onChanged: (value) => _summary = value,
                    minLines: 3,
                    maxLines: 3,
                    maxLength: 110,
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        onPressed: () async {
          var action = SaveArticlePreview(
            title: _title,
            previewImageUrl: _previewImageUrl,
            summary: _summary,
          );
          _feedBloc.dispatchAction(action);

          var state = await action.state;
          if (state is SaveArticlePreviewReady) {
            Navigator.of(context).pushNamed(
              ArticleComposePage.routeName,
              arguments: widget.type,
            );
          }
        },
      ),
    );
  }
}
