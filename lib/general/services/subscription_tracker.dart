class SubscriptionTracker {
  final List<String> _subscriptions = [];

  List<String> get subscriptions => List<String>.unmodifiable(_subscriptions);

  void addSubscription(String identifier) => _subscriptions.add(identifier);

  void removeSubscription(String identifier) =>
      _subscriptions.remove(identifier);
}
