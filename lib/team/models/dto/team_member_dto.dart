class TeamMemberDto {
  final int id;
  final String firstName;
  final String lastName;
  final int birthDate;
  final String imageUrl;

  TeamMemberDto.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        firstName = map['firstName'],
        lastName = map['lastName'],
        birthDate = map['birthDate'],
        imageUrl = map['imageUrl'];
}
