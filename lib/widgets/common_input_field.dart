import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final void Function()? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CommonTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          onTap: onTap,
          readOnly: readOnly,
          maxLines: maxLines,
          controller: controller,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class CommonDropdownButton<T> extends StatelessWidget {
  final T? value;
  final String? labelText;
  final String? hintText;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool isExpanded;
  const CommonDropdownButton({
    super.key,
    this.value,
    this.labelText,
    this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            value: value,
            hint: Text(
              hintText ?? 'Select',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            isExpanded: true,
            alignment: Alignment.centerLeft,
            items: items,
            onChanged: onChanged,
            menuItemStyleData: MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              selectedMenuItemBuilder: (context, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerLeft,
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: child,
                  ),
                );
              },
            ),
            buttonStyleData: ButtonStyleData(
              padding: EdgeInsets.zero,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
            ),

            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              elevation: 4,
              offset: const Offset(0, 4),
              padding: EdgeInsets.zero,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            customButton: IgnorePointer(
              ignoring: true,
              child: CommonTextField(
                hintText: hintText,
                controller: TextEditingController(
                  text: value?.toString() ?? "",
                ),
                readOnly: true,
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
