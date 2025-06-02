import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final int maxLines;
  final String? errorText;
  final bool showError;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.maxLines = 1,
    this.errorText,
    this.showError = true,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: 8),
        
        // Text Field
        TextFormField(
          controller: widget.controller,
          validator: (value) {
            final error = widget.validator?.call(value);
            setState(() {
              _errorText = error;
            });
            return error;
          },
          onChanged: (value) {
            widget.onChanged?.call(value);
            // Clear error saat user mulai mengetik
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
          onFieldSubmitted: widget.onSubmitted,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.greyDark,
          ),
          decoration: InputDecoration(
            hintText: widget.hint ?? widget.label,
            hintStyle: const TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
            prefixIcon: widget.prefixIcon != null 
                ? Icon(
                    widget.prefixIcon,
                    color: _errorText != null ? AppColors.error : AppColors.grey,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: widget.enabled ? AppColors.white : AppColors.greyLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _buildBorder(AppColors.greyLight),
            enabledBorder: _buildBorder(AppColors.greyLight),
            focusedBorder: _buildBorder(AppColors.primary),
            errorBorder: _buildBorder(AppColors.error),
            focusedErrorBorder: _buildBorder(AppColors.error),
            errorStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ),
        
        // Custom Error Text
        if (widget.showError && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      // Password visibility toggle
      return IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.grey,
        ),
      );
    } else if (widget.suffixIcon != null) {
      // Custom suffix icon
      return IconButton(
        onPressed: widget.onSuffixIconPressed,
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.grey,
        ),
      );
    }
    return null;
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: 1.5,
      ),
    );
  }
}