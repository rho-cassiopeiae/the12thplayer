import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../general/extensions/flutter_quill_extension.dart';
import '../bloc/feed_actions.dart';
import '../bloc/feed_bloc.dart';
import '../../general/extensions/kiwi_extension.dart';

class NewArticlePage extends StatefulWidget with DependencyResolver<FeedBloc> {
  static const routeName = '/feed/new-article';

  @override
  _NewArticlePageState createState() => _NewArticlePageState(resolve());
}

class _NewArticlePageState extends State<NewArticlePage> {
  final FeedBloc _feedBloc;

  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  _NewArticlePageState(this._feedBloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: false,
        title: const Text('Flutter Quill'),
      ),
      body: _buildEditor(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _feedBloc.dispatchAction(
            CreateNewArticle(
              content: jsonEncode(_controller.document.toDelta().toJson()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    var quillEditor = QuillEditor(
      controller: _controller,
      scrollController: ScrollController(),
      focusNode: _focusNode,
      scrollable: true,
      autoFocus: false,
      readOnly: false,
      expands: false,
      padding: EdgeInsets.zero,
    );

    var toolbar = QuillToolbar.basic(
      controller: _controller,
      onImagePickCallback: _onImagePickCallback,
    );

    var buttons = List<Widget>.from(toolbar.children);
    var index = buttons.indexWhere((button) => button is ImageButton);
    buttons.insert(
      index + 1,
      HostedVideoButton(
        icon: Icons.movie_creation,
        controller: _controller,
      ),
    );

    toolbar = QuillToolbar(
      children: buttons,
      toolBarHeight: toolbar.toolBarHeight,
      multiRowsDisplay: toolbar.multiRowsDisplay,
    );

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: quillEditor,
            ),
          ),
          Container(child: toolbar),
        ],
      ),
    );
  }

  Future<String> _onImagePickCallback(File file) async {
    var dir = await getApplicationDocumentsDirectory();
    return (await file.copy('${dir.path}/${basename(file.path)}')).path;
  }
}
