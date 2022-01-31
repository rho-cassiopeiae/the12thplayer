import 'package:flutter/material.dart';

class CustomSheetColor {
  Color main;
  Color accent;
  Color icon;

  CustomSheetColor({
    @required this.main,
    @required this.accent,
    this.icon,
  });
}

class SweetSheetColor {
  // ignore: non_constant_identifier_names
  static CustomSheetColor DANGER = CustomSheetColor(
    main: const Color(0xffEF5350),
    accent: const Color(0xffD32F2F),
    icon: Colors.white,
  );
  // ignore: non_constant_identifier_names
  static CustomSheetColor SUCCESS = CustomSheetColor(
    main: const Color(0xff009688),
    accent: const Color(0xff00695C),
    icon: Colors.white,
  );
  // ignore: non_constant_identifier_names
  static CustomSheetColor WARNING = CustomSheetColor(
    main: const Color(0xffFF8C00),
    accent: const Color(0xffF55932),
    icon: Colors.white,
  );
  // ignore: non_constant_identifier_names
  static CustomSheetColor NICE = CustomSheetColor(
    main: const Color(0xff2979FF),
    accent: const Color(0xff0D47A1),
    icon: Colors.white,
  );
}

class SweetSheet {
  Future<T> show<T>({
    @required BuildContext context,
    Text title,
    @required Text description,
    @required CustomSheetColor color,
    @required SweetSheetAction positive,
    SweetSheetAction negative,
    IconData icon,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: color.main,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title == null
                      ? Container()
                      : DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                          child: title,
                        ),
                  _buildContent(color, description, icon)
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: color.accent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildActions(positive, negative),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildContent(
    CustomSheetColor color,
    Text description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: SingleChildScrollView(
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontFamily: 'circular',
                      ),
                      child: description,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Icon(
                    icon,
                    size: 52.0,
                    color: color.icon ?? Colors.white,
                  )
                ],
              )
            : DefaultTextStyle(
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
                child: description,
              ),
      ),
    );
  }

  List<SweetSheetAction> _buildActions(
    SweetSheetAction positive,
    SweetSheetAction negative,
  ) {
    List<SweetSheetAction> actions = [];

    if (negative != null) {
      actions.add(negative);
    }

    if (positive != null) {
      actions.add(positive);
    }

    return actions;
  }
}

class SweetSheetAction extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;

  SweetSheetAction({
    @required this.title,
    @required this.onPressed,
    this.icon,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? TextButton(
            onPressed: onPressed,
            child: Text(
              title,
              style: TextStyle(
                color: color,
              ),
            ),
          )
        : TextButton.icon(
            onPressed: onPressed,
            label: Text(
              title,
              style: TextStyle(
                color: color,
              ),
            ),
            icon: Icon(
              icon,
              color: color,
            ),
          );
  }
}
