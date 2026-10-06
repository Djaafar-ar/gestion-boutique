import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_snack.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  static const _footerMaxLength = 60;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _footerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<ShopBloc>().state;
    if (state is ShopLoaded) {
      _updateControllers(state.shop);
    } else {
      context.read<ShopBloc>().add(LoadShopEvent());
    }
  }

  void _updateControllers(Shop shop) {
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
      _address1Controller.text = shop.addressLine1;
      _address2Controller.text = shop.addressLine2;
      _phoneController.text = shop.phoneNumber;
      _footerController.text = shop.footerText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        name: _nameController.text.trim(),
        addressLine1: _address1Controller.text.trim(),
        addressLine2: _address2Controller.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        footerText: _footerController.text.trim(),
      );

      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(title: Text(l10n.shopDetails)),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopLoaded) {
              _updateControllers(state.shop);
            } else if (state is ShopOperationSuccess) {
              showAppSnack(context, l10n.shopSaved, kind: SnackKind.success);
              context.pop();
            } else if (state is ShopError) {
              showAppSnack(context, l10n.errorWithDetail(state.message),
                  kind: SnackKind.error);
            }
          },
          buildWhen: (previous, current) =>
              current is ShopLoading || current is ShopLoaded,
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.shopInfoTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: scheme.primary,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      l10n.shopInfoHint,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    InputLabel(text: l10n.shopNameLabel),
                    _buildTextField(
                      controller: _nameController,
                      hint: l10n.shopNameHint,
                      validator: AppValidators.required(l10n.commonRequired),
                    ),
                    const SizedBox(height: 16),
                    InputLabel(text: l10n.address1Label),
                    _buildTextField(
                      controller: _address1Controller,
                      hint: l10n.address1Hint,
                    ),
                    const SizedBox(height: 16),
                    InputLabel(text: l10n.address2Label),
                    _buildTextField(
                      controller: _address2Controller,
                      hint: l10n.address2Hint,
                    ),
                    const SizedBox(height: 16),
                    InputLabel(text: l10n.phoneLabel),
                    _buildTextField(
                      controller: _phoneController,
                      hint: l10n.phoneHint,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: InputLabel(text: l10n.footerLabel)),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(l10n.maxChars(_footerMaxLength),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurfaceVariant)),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: _footerController,
                      hint: l10n.footerHint,
                      maxLines: 2,
                      maxLength: _footerMaxLength,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _saveShop,
          icon: Icons.save,
          label: l10n.commonSave,
        ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}
