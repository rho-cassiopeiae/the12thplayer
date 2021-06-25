import 'package:flutter/foundation.dart';

import '../models/vm/fixture_discussions_vm.dart';
import '../models/vm/discussion_entry_vm.dart';

abstract class DiscussionState {}

abstract class LoadDiscussionsState extends DiscussionState {}

class DiscussionsLoading extends LoadDiscussionsState {}

class DiscussionsReady extends LoadDiscussionsState {
  final FixtureDiscussionsVm fixtureDiscussions;

  DiscussionsReady({@required this.fixtureDiscussions});
}

class DiscussionsError extends LoadDiscussionsState {
  final String message;

  DiscussionsError({@required this.message});
}

abstract class LoadDiscussionState extends DiscussionState {}

class DiscussionLoading extends LoadDiscussionState {}

class DiscussionReady extends LoadDiscussionState {
  final List<DiscussionEntryVm> entries;

  DiscussionReady({@required this.entries});
}

class DiscussionError extends LoadDiscussionState {
  final String message;

  DiscussionError({@required this.message});
}

abstract class PostDiscussionEntryState extends DiscussionState {}

class PostDiscussionEntryError extends PostDiscussionEntryState {
  final String message;

  PostDiscussionEntryError({@required this.message});
}

class PostDiscussionEntryReady extends PostDiscussionEntryState {}
