import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';

/// Reusable neumorphic (soft 3D) form text field.
///
/// Built on a custom [FormField] so the validation error renders *below* the
/// raised box rather than inside it. The box lifts off the background with a
/// soft shadow (bottom-right) for a clean 3D depth; on focus it gains a primary
/// ring, and on error a red ring. When [enabled] is false it reads as a calm,
/// non-editable display (used for profile view mode).
class AppTextField extends FormField<String> {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;

  /// Optional trailing widget (e.g. a dropdown chevron). Ignored on password
  /// fields, which show the show/hide eye toggle instead.
  final Widget? suffix;

  AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    super.validator,
    this.maxLines = 1,
    super.enabled,
    this.suffix,
  }) : super(
          initialValue: controller.text,
          builder: (FormFieldState<String> field) {
            final state = field as _AppTextFieldState;
            final hasError = state.hasError;
            final ringColor = hasError
                ? AppColors.error
                : state._focused && state.widget.enabled
                    ? AppColors.primary
                    : Colors.transparent;

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
                    // 3D depth only — soft shadow cast bottom-right, no top sheen.
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFC2D2E1),
                        offset: Offset(4, 5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: state.widget.maxLines > 1
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      if (state.widget.prefixIcon != null)
                        Padding(
                          padding: EdgeInsets.only(
                              left: 14,
                              top: state.widget.maxLines > 1 ? 14 : 0),
                          child: Icon(state.widget.prefixIcon,
                              color: AppColors.primary),
                        ),
                      Expanded(
                        child: TextField(
                          controller: state.widget.controller,
                          focusNode: state._focusNode,
                          enabled: state.widget.enabled,
                          obscureText: state._obscured,
                          keyboardType: state.widget.keyboardType,
                          maxLines: state.widget.obscureText
                              ? 1
                              : state.widget.maxLines,
                          onChanged: state.didChange,
                          style: TextStyle(
                              fontSize: 16,
                              color: state.widget.enabled
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: state.widget.hint,
                            hintStyle: const TextStyle(
                                fontSize: 16, color: AppColors.textHint),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      // Show/hide toggle — only on password (obscured) fields.
                      if (state.widget.obscureText && state.widget.enabled)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              state._obscured
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.primary,
                              size: 21,
                            ),
                            onPressed: state.toggleObscure,
                          ),
                        )
                      // Otherwise an optional trailing widget (e.g. dropdown chevron).
                      else if (state.widget.suffix != null &&
                          state.widget.enabled)
                        state.widget.suffix!,
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
  FormFieldState<String> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends FormFieldState<String> {
  late final FocusNode _focusNode;
  bool _focused = false;

  /// Live obscuring state — starts matching [AppTextField.obscureText] and is
  /// flipped by the show/hide eye toggle.
  bool _obscured = false;

  @override
  AppTextField get widget => super.widget as AppTextField;

  /// Flips password visibility for the eye toggle.
  void toggleObscure() => setState(() => _obscured = !_obscured);

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _focused = _focusNode.hasFocus));
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (value != widget.controller.text) {
      didChange(widget.controller.text);
    }
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      widget.controller.text = widget.initialValue ?? '';
    });
  }
}
