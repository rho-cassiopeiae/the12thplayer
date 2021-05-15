import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/vm/lineups_vm.dart';

class PlayerDummy extends StatelessWidget {
  final PlayerVm player;
  final Color color;
  final Color fontColor;
  final double radius;

  const PlayerDummy({
    Key key,
    @required this.player,
    @required this.color,
    @required this.fontColor,
    @required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          width: radius * 2,
          height: radius * 2,
          child: Card(
            color: color,
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                player.number?.toString() ?? '',
                style: GoogleFonts.lexendMega(
                  textStyle: TextStyle(
                    color: fontColor,
                    fontSize: radius - 6,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Card(
            color: Color.fromRGBO(238, 241, 246, 1.0),
            elevation: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 84,
                  maxHeight: 15,
                  minHeight: 15,
                ),
                child: FittedBox(
                  child: Text(
                    player.name
                        .split(' ')
                        .last, // @@TODO: Find a better way to shorten a name.
                    style: GoogleFonts.exo2(
                      textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
