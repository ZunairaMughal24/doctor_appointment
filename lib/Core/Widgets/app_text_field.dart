import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';

/// Reusable neumorphic (soft 3D) form text field.
///
/// Built on a custom [FormField] so the validation error renders *below* the
/// raised box rather than inside it. The box lifts off the background with a
/// soft shadow (bottom-right) for a clean 3D depth; on focus it gains a primary
/// ring, and on error a red ring. When [enabled] is false it reads as a calm,
/// non-editable display (used for profile view mode).
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  // Same white tile surface as AppContainer, so fields and cards match.
  static const _surface = Colors.white;
  static const _darkShadow = Color(0xFFC2D2E1);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      // Seed the field value from the controller so validation works for
      // pre-filled fields (e.g. editing an existing profile).
      initialValue: widget.controller.text,
      builder: (field) {
        final hasError = field.hasError;
        final ringColor = hasError
            ? AppColors.error
            : _focused && widget.enabled
                ? AppColors.primary
                : Colors.transparent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ringColor,
                  width: ringColor == Colors.transparent ? 0 : 1.4,
                ),
                // 3D depth only — soft shadow cast bottom-right, no top sheen.
                boxShadow: const [
                  BoxShadow(
                    color: _darkShadow,
                    offset: Offset(4, 5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: widget.maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (widget.prefixIcon != null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: 14, top: widget.maxLines > 1 ? 14 : 0),
                      child: Icon(widget.prefixIcon, color: AppColors.primary),
                    ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      maxLines: widget.obscureText ? 1 : widget.maxLines,
                      onChanged: field.didChange,
                      style: TextStyle(
                          fontSize: 16,
                          color: widget.enabled
                              ? AppColors.textPrimary
                              : AppColors.textSecondary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: const TextStyle(
                            fontSize: 16, color: AppColors.textHint),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  field.errorText!,
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
  }
}
