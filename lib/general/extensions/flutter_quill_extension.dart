import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class HostedVideoButton extends StatelessWidget {
  const HostedVideoButton({
    @required this.icon,
    @required this.controller,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    Key key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final Color fillColor;
  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuillIconButton(
      icon: Icon(
        icon,
        size: iconSize,
        color: theme.iconTheme.color,
      ),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: fillColor ?? theme.canvasColor,
      onPressed: () => _handleHostedVideoButtonTap(context, controller),
    );
  }
}

void _handleHostedVideoButtonTap(
  BuildContext context,
  QuillController controller,
) async {
  final index = controller.selection.baseOffset;
  final length = controller.selection.extentOffset - index;

  var videoUrl = await showDialog<String>(
    context: context,
    builder: (ctx) => const _LinkDialog(),
  );

  if (videoUrl != null && videoUrl.isNotEmpty) {
    controller.replaceText(index, length, BlockEmbed.video(videoUrl), null);
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({Key key}) : super(key: key);

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  String _link;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        decoration: const InputDecoration(labelText: 'Paste a video link'),
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _link = value;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _link),
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
