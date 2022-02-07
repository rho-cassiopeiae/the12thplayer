import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:google_fonts/google_fonts.dart';

import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_states.dart';
import '../../general/extensions/kiwi_extension.dart';

class ArticlePage extends StatefulWidget {
  static const routeName = '/feed/article';

  final int articleId;

  const ArticlePage({
    Key key,
    @required this.articleId,
  }) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends StateWith<ArticlePage, FeedBloc> {
  FeedBloc get _feedBloc => service;

  bool _disposed;
  QuillController _controller;
  FocusNode _focusNode;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _disposed = false;
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    var action = LoadArticle(articleId: widget.articleId);
    _feedBloc.dispatchAction(action);

    action.state.then((state) {
      if (_disposed) {
        return;
      }

      if (state is ArticleReady) {
        setState(() {
          _controller = QuillController(
            document: Document.fromJson(state.article.contentList),
            selection: const TextSelection.collapsed(offset: 0),
          );
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

  Widget _buildBody() {
    if (_controller == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
        child: QuillEditor(
          controller: _controller,
          scrollController: _scrollController,
          focusNode: _focusNode,
          scrollable: true,
          autoFocus: true,
          readOnly: true,
          showCursor: false,
          expands: false,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF273469),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }
}
