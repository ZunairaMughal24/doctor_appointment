import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/widgets/app_text_field.dart';
import 'package:fyp/core/widgets/modern_bottom_sheet.dart';

/// Editable field with a dropdown picker. The field itself is a full
/// [AppTextField] (so it looks identical to every other input and stays
/// type-able), with a trailing chevron that opens a modern bottom sheet of
/// [options]. Picking one writes it into the field; typing freely is still
/// allowed. Validation flows through the inner [AppTextField].
class AppDropdownField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final List<String> options;
  final IconData? prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;

  const AppDropdownField({
    super.key,
    required this.controller,
    required this.hint,
    required this.options,
    this.prefixIcon,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint,
      prefixIcon: prefixIcon,
      enabled: enabled,
      validator: validator,
      suffix: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: IconButton(
          splashRadius: 20,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary),
          onPressed: () => _openPicker(context),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        title: hint,
        options: options,
        current: controller.text,
      ),
    );
    if (selected != null) {
      controller.text = selected;
      controller.selection =
          TextSelection.collapsed(offset: selected.length);
    }
  }
}

class _OptionsSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String current;
  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      title: title,
      subtitle: 'Pick one or type your own',
      icon: Icons.tune_rounded,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final option = options[i];
            final selected = option == current;
            return Material(
              color: selected ? AppColors.primaryLighter : Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context, option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
