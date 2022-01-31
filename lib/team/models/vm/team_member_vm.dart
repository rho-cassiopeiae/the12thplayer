import '../dto/team_member_dto.dart';

class TeamMemberVm {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String countryName;
  final String countryFlagUrl;
  final String imageUrl;

  String get fullName => ((firstName ?? '') + ' ' + (lastName ?? '')).trim();

  TeamMemberVm.fromDto(TeamMemberDto teamMember)
      : id = teamMember.id,
        firstName = teamMember.firstName,
        lastName = teamMember.lastName,
        birthDate = teamMember.birthDate == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                teamMember.birthDate,
                isUtc: true,
              ),
        countryName = teamMember.countryName,
        countryFlagUrl = teamMember.countryFlagUrl,
        imageUrl = teamMember.imageUrl ??
            'https://cdn.sportmonks.com/images/soccer/placeholder.png'; // @@TODO: Another way to specify dummy image.
}
