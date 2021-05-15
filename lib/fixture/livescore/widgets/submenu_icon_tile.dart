import 'package:flutter/material.dart';

import '../../../general/extensions/color_extension.dart';

class SubmenuIconTile extends StatelessWidget {
  final double width;
  final double height;
  final IconData iconData;
  final double iconSize;
  final void Function() toggle;
  final bool selected;

  const SubmenuIconTile({
    Key key,
    this.width = 60,
    this.height = 60,
    @required this.iconData,
    @required this.iconSize,
    @required this.toggle,
    @required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: selected
              ? HexColor.fromHex('ddffffff')
              : HexColor.fromHex('44ffffff'),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Icon(
          iconData,
          color: selected ? Colors.black87 : Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
