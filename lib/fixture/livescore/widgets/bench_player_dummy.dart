import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/vm/lineups_vm.dart';

class BenchPlayerDummy extends StatelessWidget {
  final PlayerVm player;
  final double radius;

  const BenchPlayerDummy({
    Key key,
    @required this.player,
    @required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0.0,
          width: radius * 2.0,
          height: radius * 2.0,
          child: Card(
            color: Colors.deepOrangeAccent,
            elevation: 30.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/tshirt.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 22.0,
          child: Text(
            player.number.toString(),
            style: GoogleFonts.lexendMega(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0.0,
          child: Card(
            color: const Color.fromRGBO(238, 241, 246, 1.0),
            elevation: 30.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 84.0,
                  maxHeight: 15.0,
                  minHeight: 15.0,
                ),
                child: FittedBox(
                  child: Text(
                    player.displayName,
                    style: GoogleFonts.exo2(
                      textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
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
