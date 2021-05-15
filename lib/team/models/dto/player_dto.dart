import 'team_member_dto.dart';

class PlayerDto extends TeamMemberDto {
  final int number;
  final String position;

  PlayerDto.fromMap(Map<String, dynamic> map)
      : number = map['number'],
        position = map['position'],
        super.fromMap(map);
}
