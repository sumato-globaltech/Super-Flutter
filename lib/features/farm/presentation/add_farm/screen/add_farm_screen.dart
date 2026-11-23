import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/farm/presentation/add_farm/bloc/add_farm_bloc.dart';
import 'package:super_flutter/features/farm/presentation/add_farm/bloc/add_farm_event.dart';
import 'package:super_flutter/features/farm/presentation/add_farm/bloc/add_farm_state.dart';

class AddFarmScreen extends StatelessWidget {
  const AddFarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddFarmBloc>()..add(const AddFarmStarted()),
      child: const _AddFarmView(),
    );
  }
}

class _AddFarmView extends StatefulWidget {
  const _AddFarmView();

  @override
  State<_AddFarmView> createState() => _AddFarmViewState();
}

class _AddFarmViewState extends State<_AddFarmView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaHaController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  String? _blockId;
  String? _soilType;
  String? _irrigationType;
  String? _ownership;
  late final AddFarmBloc _addFarmBloc;

  @override
  void initState() {
    super.initState();
    _addFarmBloc = context.read<AddFarmBloc>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaHaController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  /// Empty text is sent as null, so an optional field left blank is not sent.
  String? _orNull(String text) => text.isEmpty ? null : text;

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _addFarmBloc.add(
      AddFarmSubmitted(
        name: _nameController.text.trim(),
        areaHa: double.parse(_areaHaController.text.trim()),
        blockId: _blockId,
        village: _orNull(_villageController.text.trim()),
        address: _orNull(_addressController.text.trim()),
        soilType: _soilType,
        irrigationType: _irrigationType,
        ownership: _ownership,
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<AddFarmBloc, AddFarmState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case AddFarmStatus.success:
            Utils.flutterToast(l10n.farmAddFarmDone);
            context.pop(true);
          case AddFarmStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case AddFarmStatus.initial || AddFarmStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.farmAddFarmTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BlocSelector<AddFarmBloc, AddFarmState, String?>(
                      selector: (state) => state.nameError,
                      builder: (context, nameError) => TextFormField(
                        controller: _nameController,
                        forceErrorText: nameError,
                        onChanged: nameError == null
                            ? null
                            : (_) => _addFarmBloc.add(
                                const AddFarmFieldErrorCleared('name'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '${l10n.farmAddFarmName} *',
                          hintText: l10n.fieldEnter(l10n.farmAddFarmName),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(l10n.farmAddFarmName)
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<AddFarmBloc, AddFarmState, String?>(
                      selector: (state) => state.areaHaError,
                      builder: (context, areaHaError) => TextFormField(
                        controller: _areaHaController,
                        forceErrorText: areaHaError,
                        onChanged: areaHaError == null
                            ? null
                            : (_) => _addFarmBloc.add(
                                const AddFarmFieldErrorCleared('area_ha'),
                              ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: '${l10n.farmAddFarmAreaHa} *',
                          hintText: l10n.fieldEnter(l10n.farmAddFarmAreaHa),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(l10n.farmAddFarmAreaHa)
                            : double.tryParse(v.trim()) == null
                            ? l10n.fieldInvalidNumber
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<AddFarmBloc, AddFarmState>(
                      buildWhen: (prev, curr) =>
                          prev.blockOptions != curr.blockOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.blockIdError != curr.blockIdError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _blockId,
                            forceErrorText: state.blockIdError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.farmAddFarmBlockId,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(l10n.farmAddFarmBlockId),
                            ),
                            items: [
                              for (final option in state.blockOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _blockId = value;
                                    if (state.blockIdError != null) {
                                      _addFarmBloc.add(
                                        const AddFarmFieldErrorCleared(
                                          'block_id',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<AddFarmBloc, AddFarmState, String?>(
                      selector: (state) => state.villageError,
                      builder: (context, villageError) => TextFormField(
                        controller: _villageController,
                        forceErrorText: villageError,
                        onChanged: villageError == null
                            ? null
                            : (_) => _addFarmBloc.add(
                                const AddFarmFieldErrorCleared('village'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.farmAddFarmVillage,
                          hintText: l10n.fieldEnter(l10n.farmAddFarmVillage),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<AddFarmBloc, AddFarmState, String?>(
                      selector: (state) => state.addressError,
                      builder: (context, addressError) => TextFormField(
                        controller: _addressController,
                        forceErrorText: addressError,
                        onChanged: addressError == null
                            ? null
                            : (_) => _addFarmBloc.add(
                                const AddFarmFieldErrorCleared('address'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: l10n.farmAddFarmAddress,
                          hintText: l10n.fieldEnter(l10n.farmAddFarmAddress),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<AddFarmBloc, AddFarmState>(
                      buildWhen: (prev, curr) =>
                          prev.soilTypeOptions != curr.soilTypeOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.soilTypeError != curr.soilTypeError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _soilType,
                            forceErrorText: state.soilTypeError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.farmAddFarmSoilType,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(l10n.farmAddFarmSoilType),
                            ),
                            items: [
                              for (final option in state.soilTypeOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _soilType = value;
                                    if (state.soilTypeError != null) {
                                      _addFarmBloc.add(
                                        const AddFarmFieldErrorCleared(
                                          'soil_type',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocBuilder<AddFarmBloc, AddFarmState>(
                      buildWhen: (prev, curr) =>
                          prev.irrigationTypeOptions !=
                              curr.irrigationTypeOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.irrigationTypeError != curr.irrigationTypeError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _irrigationType,
                            forceErrorText: state.irrigationTypeError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.farmAddFarmIrrigationType,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.farmAddFarmIrrigationType,
                                    ),
                            ),
                            items: [
                              for (final option in state.irrigationTypeOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _irrigationType = value;
                                    if (state.irrigationTypeError != null) {
                                      _addFarmBloc.add(
                                        const AddFarmFieldErrorCleared(
                                          'irrigation_type',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocBuilder<AddFarmBloc, AddFarmState>(
                      buildWhen: (prev, curr) =>
                          prev.ownershipOptions != curr.ownershipOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.ownershipError != curr.ownershipError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _ownership,
                            forceErrorText: state.ownershipError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.farmAddFarmOwnership,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(l10n.farmAddFarmOwnership),
                            ),
                            items: [
                              for (final option in state.ownershipOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _ownership = value;
                                    if (state.ownershipError != null) {
                                      _addFarmBloc.add(
                                        const AddFarmFieldErrorCleared(
                                          'ownership',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<AddFarmBloc, AddFarmState, String?>(
                      selector: (state) => state.latitudeError,
                      builder: (context, latitudeError) => TextFormField(
                        controller: _latitudeController,
                        forceErrorText: latitudeError,
                        onChanged: latitudeError == null
                            ? null
                            : (_) => _addFarmBloc.add(
                                const AddFarmFieldErrorCleared('latitude'),
                              ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.farmAddFarmLatitude,
                          hintText: l10n.fieldEnter(l10n.farmAddFarmLatitude),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? null
                            : double.tryParse(v.trim()) == null
                            ? l10n.fieldInvalidNumber
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<AddFarmBloc, AddFarmState, String?>(
                      selector: (state) => state.longitudeError,
                      builder: (context, longitudeError) => TextFormField(
                        controller: _longitudeController,
                        forceErrorText: longitudeError,
                        onChanged: longitudeError == null
                            ? null
                            : (_) => _addFarmBloc.add(
                                const AddFarmFieldErrorCleared('longitude'),
                              ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.farmAddFarmLongitude,
                          hintText: l10n.fieldEnter(l10n.farmAddFarmLongitude),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? null
                            : double.tryParse(v.trim()) == null
                            ? l10n.fieldInvalidNumber
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<AddFarmBloc, AddFarmState, bool>(
                      selector: (state) => state.isSubmitting,
                      builder: (context, isSubmitting) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submit,
                          child: isSubmitting
                              ? DesignProgress(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : Text(l10n.formSubmit),
                        ),
                      ),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
