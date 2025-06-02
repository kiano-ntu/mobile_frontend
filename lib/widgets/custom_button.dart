import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final bool enabled;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius,
    this.icon,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || isLoading || onPressed == null;
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined ? _buildOutlinedButton(isDisabled) : _buildFilledButton(isDisabled),
    );
  }

  Widget _buildFilledButton(bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled 
            ? AppColors.greyLight 
            : backgroundColor ?? AppColors.primary,
        foregroundColor: isDisabled 
            ? AppColors.grey 
            : textColor ?? AppColors.white,
        elevation: isDisabled ? 0 : 2,
        shadowColor: AppColors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.greyLight : AppColors.white,
        foregroundColor: isDisabled 
            ? AppColors.grey 
            : backgroundColor ?? AppColors.primary,
        side: BorderSide(
          color: isDisabled 
              ? AppColors.greyLight 
              : backgroundColor ?? AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined 
              ? backgroundColor ?? AppColors.primary 
              : textColor ?? AppColors.white,
        ),
      ),
    );
  }
}