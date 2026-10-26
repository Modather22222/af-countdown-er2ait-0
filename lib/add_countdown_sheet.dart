import 'package:flutter/material.dart';

import 'countdown_event.dart';

Future<CountdownEvent?> showAddCountdownSheet(BuildContext context) {
  return showModalBottomSheet<CountdownEvent>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const AddCountdownSheet(),
  );
}

class AddCountdownSheet extends StatefulWidget {
  const AddCountdownSheet({super.key});

  @override
  State<AddCountdownSheet> createState() => _AddCountdownSheetState();
}

class _AddCountdownSheetState extends State<AddCountdownSheet> {
  static const _emojis = ['⏳', '🚀', '✈️', '🎂', '🎉', '🎯'];

  final _titleController = TextEditingController();
  late DateTime _target;
  String _emoji = '⏳';
  String? _titleError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _target = DateTime(now.year, now.month, now.day + 1, 9);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _target.isAfter(now) ? _target : now,
      firstDate: DateUtils.dateOnly(now),
      lastDate: DateTime(now.year + 10, now.month, now.day),
      helpText: 'Pick a date',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _target = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _target.hour,
        _target.minute,
      );
      _timeError = null;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_target),
      helpText: 'Pick a time',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _target = DateTime(
        _target.year,
        _target.month,
        _target.day,
        picked.hour,
        picked.minute,
      );
      _timeError = null;
    });
  }

  void _usePreset(Duration offset) {
    setState(() {
      _target = DateTime.now().add(offset);
      _timeError = null;
    });
  }

  void _useTomorrow() {
    final now = DateTime.now();
    setState(() {
      _target = DateTime(now.year, now.month, now.day + 1, 9);
      _timeError = null;
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final isValidTime = _target.isAfter(DateTime.now());

    setState(() {
      _titleError = title.isEmpty ? 'Give your countdown a name.' : null;
      _timeError = isValidTime ? null : 'Choose a moment in the future.';
    });

    if (title.isEmpty || !isValidTime) {
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      CountdownEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        target: _target,
        emoji: _emoji,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final timeLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(_target),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New countdown',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What are you looking forward to?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() => _titleError = null);
                }
              },
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Event name',
                hintText: 'e.g. Summer holiday',
                prefixIcon: const Icon(Icons.edit_calendar_rounded),
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'WHEN',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'DATE',
                    value: localizations.formatMediumDate(_target),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerTile(
                    icon: Icons.schedule_rounded,
                    label: 'TIME',
                    value: timeLabel,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            if (_timeError != null) ...[
              const SizedBox(height: 8),
              Text(
                _timeError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('In 1 hour'),
                  onPressed: () => _usePreset(const Duration(hours: 1)),
                ),
                ActionChip(
                  label: const Text('Tomorrow'),
                  onPressed: _useTomorrow,
                ),
                ActionChip(
                  label: const Text('Next week'),
                  onPressed: () => _usePreset(const Duration(days: 7)),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'PICK AN ICON',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final emoji in _emojis)
                  _EmojiChoice(
                    emoji: emoji,
                    selected: _emoji == emoji,
                    onTap: () => setState(() => _emoji = emoji),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text('Start countdown'),
            ),
            const SizedBox(height: 10),
            Text(
              'Countdowns are kept for this session only.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiChoice extends StatelessWidget {
  const _EmojiChoice({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 21)),
      ),
    );
  }
}
