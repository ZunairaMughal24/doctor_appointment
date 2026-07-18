import 'package:flutter/material.dart';
import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/constants/app_text_styles.dart';
import 'package:medic/features/doctors/domain/entities/weekly_availability.dart';

/// A form widget that lets a doctor set their weekly schedule.
/// Shows Mon–Sun toggles; each enabled day gets from/to time pickers.
class WeeklyAvailabilityField extends StatefulWidget {
  final WeeklyAvailability value;
  final ValueChanged<WeeklyAvailability> onChanged;
  final bool enabled;

  const WeeklyAvailabilityField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<WeeklyAvailabilityField> createState() =>
      _WeeklyAvailabilityFieldState();
}

class _WeeklyAvailabilityFieldState extends State<WeeklyAvailabilityField> {
  late List<DayHours> _days;

  @override
  void initState() {
    super.initState();
    _days = _allDays(widget.value);
  }

  @override
  void didUpdateWidget(WeeklyAvailabilityField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      setState(() => _days = _allDays(widget.value));
    }
  }

  List<DayHours> _allDays(WeeklyAvailability wa) =>
      WeeklyAvailability.weekdayNames.map(wa.forDay).toList();

  void _toggle(int i, bool on) {
    final d = _days[i];
    setState(() {
      _days[i] = on
          ? DayHours(day: d.day, open: '09:00', close: '17:00')
          : DayHours(day: d.day);
    });
    widget.onChanged(WeeklyAvailability(List.from(_days)));
  }

  Future<void> _pickTime(int i, bool isOpen) async {
    if (!widget.enabled) return;
    final d = _days[i];
    final hhmm = isOpen ? (d.open ?? '09:00') : (d.close ?? '17:00');
    final parts = hhmm.split(':');
    final initHour = int.tryParse(parts[0]) ?? (isOpen ? 9 : 17);
    final initMinute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => _TimePickerSheet(
        dayName: d.day,
        label: isOpen ? 'Opening time' : 'Closing time',
        initialHour: initHour,
        initialMinute: initMinute,
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _days[i] = DayHours(
        day: d.day,
        open: isOpen ? result : d.open,
        close: isOpen ? d.close : result,
      );
    });
    widget.onChanged(WeeklyAvailability(List.from(_days)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _days.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.inputBorder,
              ),
            _DayRow(
              day: _days[i],
              enabled: widget.enabled,
              onToggle: (on) => _toggle(i, on),
              onPickOpen: () => _pickTime(i, true),
              onPickClose: () => _pickTime(i, false),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Day row ───────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final DayHours day;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  const _DayRow({
    required this.day,
    required this.enabled,
    required this.onToggle,
    required this.onPickOpen,
    required this.onPickClose,
  });

  @override
  Widget build(BuildContext context) {
    final open = day.isOpen;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 24,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: open,
                onChanged: enabled ? onToggle : null,
                activeThumbColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 34,
            child: Text(
              day.day.substring(0, 3),
              style: AppTextStyles.label.copyWith(
                fontWeight: open ? FontWeight.w600 : FontWeight.w400,
                color: open ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (open) ...[
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TimeChip(
                    label: WeeklyAvailability.to12h(day.open!),
                    enabled: enabled,
                    onTap: onPickOpen,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      '–',
                      style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.textSecondary),
                    ),
                  ),
                  _TimeChip(
                    label: WeeklyAvailability.to12h(day.close!),
                    enabled: enabled,
                    onTap: onPickClose,
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Closed',
              style: AppTextStyles.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Time chip — subtle edit pencil signals tappability ───────────────────────

class _TimeChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryLighter : AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            if (enabled) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit_rounded,
                size: 10,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Modern bottom-sheet drum-roll time picker ─────────────────────────────────

class _TimePickerSheet extends StatefulWidget {
  final String dayName;
  final String label;
  final int initialHour;
  final int initialMinute;

  const _TimePickerSheet({
    required this.dayName,
    required this.label,
    required this.initialHour,
    required this.initialMinute,
  });

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  // Quarter-hour steps match the 30-min slot granularity while still offering
  // fine-enough control (e.g. a clinic opening at 8:30 vs 9:00).
  static const _minuteSteps = [0, 15, 30, 45];

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;
  late int _hour;
  late int _minIndex;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour.clamp(0, 23);
    // Snap to the closest quarter-hour
    _minIndex = _snapMinuteIndex(widget.initialMinute);
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minCtrl = FixedExtentScrollController(initialItem: _minIndex);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  int _snapMinuteIndex(int m) {
    int best = 0;
    int bestDist = 60;
    for (int i = 0; i < _minuteSteps.length; i++) {
      final dist = (_minuteSteps[i] - m).abs();
      if (dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    return best;
  }

  int get _selectedMinute => _minuteSteps[_minIndex];

  String get _result =>
      '${_hour.toString().padLeft(2, '0')}:'
      '${_selectedMinute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(24, 10, 24, 20 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dayName,
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Drum roll ────────────────────────────────────────────────
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection highlight band
                Container(
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.6)),
                  ),
                ),

                // Hour drum + colon + minute drum
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Drum(
                      controller: _hourCtrl,
                      itemCount: 24,
                      selectedIndex: _hour,
                      labelOf: (i) => i.toString().padLeft(2, '0'),
                      onChanged: (i) => setState(() => _hour = i),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        ':',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                    ),
                    _Drum(
                      controller: _minCtrl,
                      itemCount: _minuteSteps.length,
                      selectedIndex: _minIndex,
                      labelOf: (i) =>
                          _minuteSteps[i].toString().padLeft(2, '0'),
                      onChanged: (i) => setState(() => _minIndex = i),
                    ),
                  ],
                ),

                // Top fade-out overlay (pointer-transparent)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 58,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom fade-out overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 58,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Live 12-hour preview
          Text(
            WeeklyAvailability.to12h(_result),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),

          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_result),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Set ${WeeklyAvailability.to12h(_result)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single drum-roll column ───────────────────────────────────────────────────

class _Drum extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final String Function(int) labelOf;
  final ValueChanged<int> onChanged;

  const _Drum({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 52,
        diameterRatio: 1.6,
        squeeze: 1.1,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (_, i) {
            final selected = i == selectedIndex;
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 120),
                style: AppTextStyles.h1.copyWith(
                  fontSize: selected ? 30 : 20,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textHint,
                  height: 1,
                ),
                child: Text(labelOf(i)),
              ),
            );
          },
        ),
      ),
    );
  }
}
