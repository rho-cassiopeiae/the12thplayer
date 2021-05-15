import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/vm/player_vm.dart';
import '../models/vm/team_member_vm.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamMemberVm teamMember;
  final Color borderColor;

  final Color _color = const Color.fromRGBO(238, 241, 246, 1.0);

  const TeamMemberCard({
    Key key,
    @required this.teamMember,
    @required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: _color,
        border: Border.all(
          width: 2,
          color: borderColor,
        ),
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: _color,
              border: Border.all(
                width: 2,
                color: Colors.black87,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 120,
              height: 117,
              decoration: BoxDecoration(
                color: _color,
                border: Border.all(
                  width: 2,
                  color: Colors.black87,
                ),
              ),
              child: Image.network(
                teamMember.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 65,
                  ),
                  child: Card(
                    color: _color,
                    elevation: 5,
                    shape: BeveledRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: AutoSizeText(
                          teamMember.fullName,
                          style: GoogleFonts.exo2(
                            textStyle: TextStyle(fontSize: 21),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (teamMember is PlayerVm)
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: theme.primaryColor,
                              alignment: Alignment.center,
                              child: Text(
                                (teamMember as PlayerVm).number.toString(),
                                style: GoogleFonts.lexendMega(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: theme.primaryColorLight,
                              alignment: Alignment.center,
                              child: Text(
                                (teamMember as PlayerVm).position[0],
                                style: GoogleFonts.squadaOne(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (teamMember.birthDate != null)
                        InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.red[300],
                              shape: BeveledRectangleBorder(
                                side: BorderSide(
                                  width: 2,
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  DateFormat.yMMMMd('en_US')
                                      .format(teamMember.birthDate),
                                  style: GoogleFonts.exo2(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: Colors.red[300],
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.date_range_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
