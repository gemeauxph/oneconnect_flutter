part of '../register_screen.dart';

final class RegisterTextFormFieldWidget extends TextFormField {
  final String hintText;
  final IconData prefixIcon;
  final bool? obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;

  RegisterTextFormFieldWidget({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscure = false,
    required super.controller,
    this.autofillHints,
    this.inputFormatters,
    super.validator,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.keyboardType,
  }) : super(
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
        );

  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure!,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: primaryColor.withOpacity(.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Theme.of(context).hintColor.withOpacity(.2))),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        hintStyle: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).hintColor.withOpacity(.4)),
      ),
    );
  }
}
