import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';

/// Reusable neumorphic (soft 3D) form text field.
///
/// Built on a custom [FormField] so the validation error renders *below* the
/// raised box rather than inside it. The box lifts off the background with a
/// light highlight (top-left) and a soft shadow (bottom-right); on focus it
/// gains a primary ring, and on error a red ring.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  // Neumorphic palette tuned for the light app background.
  static const _surface = Color(0xFFF2F7FB);
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
      builder: (field) {
        final hasError = field.hasError;
        final ringColor = hasError
            ? AppColors.error
            : _focused
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
                boxShadow: const [
                  // Soft shadow bottom-right — lifts the field.
                  BoxShadow(
                    color: _darkShadow,
                    offset: Offset(4, 4),
                    blurRadius: 10,
                  ),
                  // Light highlight top-left — the neumorphic sheen.
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.prefixIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Icon(widget.prefixIcon, color: AppColors.primary),
                    ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      onChanged: field.didChange,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textPrimary),
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
