import '../../fixture/livescore/discussion/models/vm/discussion_entry_vm.dart';
import '../../team/models/entities/team_entity.dart';
import '../../account/models/entities/account_entity.dart';

class Cache {
  AccountEntity _account;
  AccountEntity loadAccount() => _account;
  void saveAccount(AccountEntity account) => _account = account;

  TeamEntity _currentTeam;
  TeamEntity loadCurrentTeam() => _currentTeam;
  void saveCurrentTeam(TeamEntity team) => _currentTeam = team;

  final List<DiscussionEntryVm> _discussionEntries = [];

  void clearDiscussionEntries() => _discussionEntries.clear();

  void addDiscussionEntries(List<DiscussionEntryVm> entries) {
    entries.removeWhere(
      (entry) =>
          _discussionEntries.indexWhere(
            (e) => e.id == entry.id,
          ) >=
          0,
    );

    _discussionEntries.insertAll(0, entries);
    _discussionEntries.sort((e1, e2) {
      var e1IdSplit = e1.id.split('-');
      var e2IdSplit = e2.id.split('-');
      var c = int.parse(e1IdSplit[0]).compareTo(int.parse(e2IdSplit[0]));

      return c != 0
          ? c
          : int.parse(e1IdSplit[1]).compareTo(int.parse(e2IdSplit[1]));
    });
  }

  List<DiscussionEntryVm> getDiscussionEntries() => _discussionEntries;
}
