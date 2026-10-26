import 'dart:async';

import 'package:flutter/material.dart';

import 'add_countdown_sheet.dart';
import 'countdown_card.dart';
import 'countdown_event.dart';
import 'countdown_store.dart';
import 'next_countdown_card.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key, this.initialEvents});

  final List<CountdownEvent>? initialEvents;

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late final CountdownStore _store;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _store = CountdownStore(
      initialEvents: widget.initialEvents ?? demoCountdownEvents(),
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _store.dispose();
    super.dispose();
  }

  Future<void> _showAddSheet() async {
    final event = await showAddCountdownSheet(context);
    if (event == null || !mounted) {
      return;
    }

    _store.add(event);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('"${event.title}" added')));
  }

  void _removeEvent(CountdownEvent event) {
    final messenger = ScaffoldMessenger.of(context);
    _store.remove(event.id);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${event.title}" removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _store.add(event),
        ),
      ),
    );
  }

  void _showAbout() {
    final colorScheme = Theme.of(context).colorScheme;

    showAboutDialog(
      context: context,
      applicationName: 'Countdown',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B3ED9), Color(0xFF916FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.hourglass_bottom_rounded,
          color: Colors.white,
        ),
      ),
      children: [
        Text(
          'A quiet place to count down to the moments that matter. '
          'Countdowns are kept in memory for this session.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New countdown'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _store,
          builder: (context, _) {
            final events = _store.events;
            final nextEvent = _store.nextAfter(now);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                _Header(onAbout: _showAbout),
                const SizedBox(height: 24),
                NextCountdownCard(
                  event: nextEvent,
                  now: now,
                  onAdd: _showAddSheet,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      'Upcoming',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '${events.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (events.isEmpty)
                  _EmptyState(onAdd: _showAddSheet)
                else
                  for (var index = 0; index < events.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == events.length - 1 ? 0 : 12,
                      ),
                      child: CountdownCard(
                        event: events[index],
                        now: now,
                        onDelete: () => _removeEvent(events[index]),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAbout});

  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5B3ED9), Color(0xFF916FFF)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B3ED9).withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.hourglass_bottom_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Countdown',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Every second counts.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onAbout,
          tooltip: 'About Countdown',
          icon: const Icon(Icons.info_outline_rounded),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Nothing on the horizon',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a date worth waiting for.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text('Add countdown'),
          ),
        ],
      ),
    );
  }
}
