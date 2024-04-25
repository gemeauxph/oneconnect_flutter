part of '../redeem_screen.dart';

mixin _RedeemMixin on State<RedeemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  String code = '';

  String? isCodeValid(String? value) {
    if (value?.isEmpty == true) {
      return 'Please enter code';
    } else if ((value?.length ?? 0) < 3) {
      return 'Name must be at least 3 characters long';
    } else {
      return null;
    }
  }

  bool validate() {
    _formKey.currentState?.save();
    if (_formKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void btnRedeemStatus() {
    if (Config.perks == "") {
      showToast("no_redeem_code_msg".tr());
    } else {
      showRedeemDialog(
          title: 'redeem_status'.tr(),
          perks: Config.perks,
          exp: Config.expiration,
          btn: 'close'.tr(),
          isFinish: false,
          context: context);
    }
  }
}
