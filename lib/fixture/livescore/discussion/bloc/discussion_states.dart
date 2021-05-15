import 'package:flutter/foundation.dart';

import '../models/vm/discussion_entry_vm.dart';

abstract class DiscussionState {}

class DiscussionLoading extends DiscussionState {}

class DiscussionReady extends DiscussionState {
  final List<DiscussionEntryVm> entries;

  DiscussionReady({@required this.entries});
}

class DiscussionError extends DiscussionState {
  final String message;

  DiscussionError({@required this.message});
}

abstract class PostDiscussionEntryState extends DiscussionState {}

class PostDiscussionEntryError extends PostDiscussionEntryState {
  final String message;

  PostDiscussionEntryError({@required this.message});
}

class PostDiscussionEntryReady extends PostDiscussionEntryState {}
