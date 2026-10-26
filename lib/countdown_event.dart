class CountdownEvent {
  const CountdownEvent({
    required this.id,
    required this.title,
    required this.target,
    required this.emoji,
  });

  final String id;
  final String title;
  final DateTime target;
  final String emoji;
}

List<CountdownEvent> demoCountdownEvents() {
  final now = DateTime.now();

  return [
    CountdownEvent(
      id: 'team-sync',
      title: 'Team sync',
      target: now.add(const Duration(minutes: 47)),
      emoji: '🎯',
    ),
    CountdownEvent(
      id: 'lisbon-getaway',
      title: 'Lisbon getaway',
      target: now.add(const Duration(days: 3, hours: 9)),
      emoji: '✈️',
    ),
    CountdownEvent(
      id: 'product-launch',
      title: 'Product launch',
      target: now.add(const Duration(days: 12, hours: 4, minutes: 30)),
      emoji: '🚀',
    ),
  ];
}
