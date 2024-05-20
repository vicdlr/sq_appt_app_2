
import 'package:flutter/material.dart';
import '../theme/them_helper.dart';


class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField(
      {super.key,
        this.alignment,
        this.width,
        this.controller,
        this.textStyle,
        this.obscureText = false,
        this.textInputAction = TextInputAction.next,
        this.textInputType = TextInputType.text,
        this.maxLines,
        this.hintText,
        this.hintStyle,
        this.prefix,
        this.prefixConstraints,
        this.suffix,
        this.suffixConstraints,
        this.contentPadding,
        this.borderDecoration,
        this.fillColor,
        this.filled = false,
        this.validator,
        this.readOnly = false,
        this.onTapOutside,
        this.onTap,
        this.onChanged
        ,
        this.textCapitalization
      }

      );

  final Alignment? alignment;

  final double? width;
  final bool readOnly;
  final TextEditingController? controller;

  final TextStyle? textStyle;

  final bool? obscureText;

  final TextInputAction? textInputAction;

  final TextInputType? textInputType;

  final int? maxLines;

  final String? hintText;

  final TextStyle? hintStyle;

  final Widget? prefix;

  final BoxConstraints? prefixConstraints;

  final Widget? suffix;

  final BoxConstraints? suffixConstraints;

  final EdgeInsets? contentPadding;

  final InputBorder? borderDecoration;

  final Color? fillColor;

  final bool? filled;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;

  final FormFieldValidator<String>? validator;
  final void Function(PointerDownEvent)? onTapOutside;
  final TextCapitalization? textCapitalization ;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return widget.alignment != null
        ? Align(
      alignment: widget.alignment ?? Alignment.center,
      child: textFormFieldWidget,
    )
        : textFormFieldWidget;
  }

  Widget get textFormFieldWidget => SizedBox(
    width: widget.width ?? double.maxFinite,
    child: TextFormField(
      onTapOutside: widget.onTapOutside ?? (PointerDownEvent){
        FocusScope.of(context).unfocus();
      },
      textCapitalization:widget.textCapitalization ?? TextCapitalization.none ,
      controller: widget.controller,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      // focusNode: focusNode ?? FocusNode(),
      // style: textStyle ?? theme.textTheme.titleMedium,
      obscureText: widget.obscureText!,
      textInputAction: widget.textInputAction,
      style: widget.textStyle ?? theme.textTheme.titleMedium,
      keyboardType: widget.textInputType,
      maxLines: widget.maxLines ?? 1,
      decoration: decoration,
      validator: widget.validator,
    ),
  );

  InputDecoration get decoration => InputDecoration(
    hintText: widget.hintText ?? "",
    hintStyle: widget.hintStyle ?? theme.textTheme.titleMedium,
    prefixIcon: widget.prefix,
    prefixIconConstraints: widget.prefixConstraints,
    suffixIcon: widget.suffix,
    suffixIconConstraints: widget.suffixConstraints,
    isDense: true,
    contentPadding: widget.contentPadding ?? const EdgeInsets.all(14),
    fillColor: widget.fillColor ?? Colors.purple.withOpacity(0.1),
    filled: widget.filled ?? true,
    border: widget.borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: appTheme.black900.withOpacity(0.2),
            width: 1,
          ),
        ),
    enabledBorder: widget.borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: appTheme.black900.withOpacity(0.2),
            width: 1,
          ),
        ),
    focusedBorder: widget.borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: appTheme.black900.withOpacity(0.2),
            width: 1,
          ),
        ),
  );
}

/// Extension on [CustomTextFormField] to facilitate inclusion of all types of border style etc
extension TextFormFieldStyleHelper on CustomTextFormField {
  static UnderlineInputBorder get underLineBlack => UnderlineInputBorder(
    borderSide: BorderSide(
      color: appTheme.black900.withOpacity(0.1),
    ),
  );
  static OutlineInputBorder get outlineBlackTL5 => OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(
      color: appTheme.black900.withOpacity(0.2),
      width: 1,
    ),
  );
  static OutlineInputBorder get fillGray => OutlineInputBorder(
    borderRadius: BorderRadius.circular(3),
    borderSide: BorderSide.none,
  );
}
