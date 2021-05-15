import 'team_member_vm.dart';
import '../dto/manager_dto.dart';

class ManagerVm extends TeamMemberVm {
  ManagerVm.fromDto(ManagerDto manager) : super.fromDto(manager);
}
