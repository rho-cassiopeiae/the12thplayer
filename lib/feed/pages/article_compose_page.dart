import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:google_fonts/google_fonts.dart';

import '../bloc/feed_states.dart';
import '../enums/article_type.dart';
import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../../general/extensions/kiwi_extension.dart';

class ArticleComposePage extends StatefulWidget
    with DependencyResolver<FeedBloc> {
  static const routeName = '/feed/article-compose';

  final ArticleType type;

  const ArticleComposePage({
    Key key,
    @required this.type,
  }) : super(key: key);

  @override
  _ArticleComposePageState createState() => _ArticleComposePageState(resolve());
}

class _ArticleComposePageState extends State<ArticleComposePage> {
  final FeedBloc _feedBloc;

  bool _disposed;
  QuillController _controller;
  FocusNode _focusNode;
  ScrollController _scrollController;

  _ArticleComposePageState(this._feedBloc);

  @override
  void initState() {
    super.initState();

    _disposed = false;
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    var action = LoadArticleContent();
    _feedBloc.dispatchAction(action);

    action.state.then((state) {
      if (!_disposed) {
        var content = (state as ArticleContentReady).content;
        QuillController controller;
        if (content != null) {
          controller = QuillController(
            document: Document.fromJson(content),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          controller = QuillController.basic();
        }

        setState(() {
          _controller = controller;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _disposed = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF398AE5),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: _controller == null
              ? () => Navigator.of(context).pop()
              : () async {
                  var action = SaveArticleContent(
                    content: _controller.document.toDelta().toJson(),
                  );
                  _feedBloc.dispatchAction(action);

                  await action.state;

                  Navigator.of(context).pop();
                },
        ),
        actions: [
          TextButton(
            child: Text(
              'Publish',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _controller == null
                ? null
                : () async {
                    var action = PostArticle(
                      type: widget.type,
                      content: _controller.document.toDelta().toJson(),
                    );
                    _feedBloc.dispatchAction(action);

                    var state = await action.state;
                    if (state is ArticlePostingSucceeded) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
          ),
        ],
      ),
      body: _controller != null
          ? _buildEditor(context)
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: QuillEditor(
                controller: _controller,
                scrollController: _scrollController,
                focusNode: _focusNode,
                scrollable: true,
                autoFocus: false,
                readOnly: false,
                expands: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            child: QuillToolbar.basic(
              controller: _controller,
              multiRowsDisplay: false,
            ),
          ),
        ],
      ),
    );
  }
}
