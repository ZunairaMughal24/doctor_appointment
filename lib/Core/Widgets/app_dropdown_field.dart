import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';

/// Dropdown counterpart to [AppTextField] — same neumorphic (soft 3D) box, hint
/// and below-the-box error text, so dropdowns sit visually identical to the
/// text fields in a form. Selecting an option writes it into [controller], so
/// existing save/validation logic that reads `controller.text` keeps working.
///
/// Constrains input to [options] only (you can't type a free-form value), which
/// is how the "accept input in the format shown in the hint only" rule is
/// enforced. When [enabled] is false it renders as a calm read-only display
/// (used for the profile view mode).
class AppDropdownField extends FormField<String> {
  final TextEditingController controller;
  final String hint;
  final List<String> options;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;

  AppDropdownField({
    super.key,
    required this.controller,
    required this.hint,
    required this.options,
    this.prefixIcon,
    super.enabled,
    this.onChanged,
    super.validator,
  }) : super(
          initialValue: controller.text,
          builder: (FormFieldState<String> field) {
            final state = field as _AppDropdownFieldState;
            final w = state.widget;
            final hasError = state.hasError;
            final ringColor = hasError ? AppColors.error : Colors.transparent;

            // DropdownButton asserts its value is one of its items; stored data
            // that predates these options shows as "unselected" (hint) instead.
            final current =
                w.options.contains(w.controller.text) ? w.controller.text : null;

            final Widget inner = !w.enabled
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Text(
                      w.controller.text.isEmpty ? w.hint : w.controller.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: w.controller.text.isEmpty
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: current,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(14),
                        hint: Text(
                          w.hint,
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.textHint),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary),
                        items: [
                          for (final o in w.options)
                            DropdownMenuItem(
                              value: o,
                              child: Text(
                                o,
                                style: const TextStyle(
                                    fontSize: 15, color: AppColors.textPrimary),
                              ),
                            ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          w.controller.text = v;
                          state.didChange(v);
                          w.onChanged?.call(v);
                        },
                      ),
                    ),
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ringColor,
                      width: ringColor == Colors.transparent ? 0 : 1.4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFC2D2E1),
                        offset: Offset(4, 5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (w.prefixIcon != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child:
                              Icon(w.prefixIcon, color: AppColors.primary),
                        ),
                      Expanded(child: inner),
                    ],
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            );
          },
        );

  @override
  FormFieldState<String> createState() => _AppDropdownFieldState();
}

class _AppDropdownFieldState extends FormFieldState<String> {
  @override
  AppDropdownField get widget => super.widget as AppDropdownField;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(AppDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (value != widget.controller.text) didChange(widget.controller.text);
  }
}
