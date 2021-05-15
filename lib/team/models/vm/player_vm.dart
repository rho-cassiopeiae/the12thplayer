import 'team_member_vm.dart';
import '../dto/player_dto.dart';

class PlayerVm extends TeamMemberVm {
  final int number;
  final String position;

  PlayerVm.fromDto(PlayerDto player)
      : number = player.number,
        position = player.position,
        super.fromDto(player);
}
