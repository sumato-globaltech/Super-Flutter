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
import 'package:super_flutter/features/farm/presentation/edit_farm/bloc/edit_farm_bloc.dart';
import 'package:super_flutter/features/farm/presentation/edit_farm/bloc/edit_farm_event.dart';
import 'package:super_flutter/features/farm/presentation/edit_farm/bloc/edit_farm_state.dart';

class EditFarmScreen extends StatelessWidget {
  const EditFarmScreen({super.key, required this.farm});

  final String farm;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditFarmBloc>()..add(const EditFarmStarted()),
      child: _EditFarmView(farm: farm),
    );
  }
}

class _EditFarmView extends StatefulWidget {
  const _EditFarmView({required this.farm});

  final String farm;

  @override
  State<_EditFarmView> createState() => _EditFarmViewState();
}

class _EditFarmViewState extends State<_EditFarmView> {
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
  late final EditFarmBloc _editFarmBloc;

  @override
  void initState() {
    super.initState();
    _editFarmBloc = context.read<EditFarmBloc>();
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
    _editFarmBloc.add(
      EditFarmSubmitted(
        farm: widget.farm,
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
    return BlocListener<EditFarmBloc, EditFarmState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case EditFarmStatus.success:
            Utils.flutterToast(l10n.farmEditFarmDone);
            context.pop(true);
          case EditFarmStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case EditFarmStatus.initial || EditFarmStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.farmEditFarmTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BlocSelector<EditFarmBloc, EditFarmState, String?>(
                      selector: (state) => state.nameError,
                      builder: (context, nameError) => TextFormField(
                        controller: _nameController,
                        forceErrorText: nameError,
                        onChanged: nameError == null
                            ? null
                            : (_) => _editFarmBloc.add(
                                const EditFarmFieldErrorCleared('name'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '${l10n.farmEditFarmName} *',
                          hintText: l10n.fieldEnter(l10n.farmEditFarmName),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(l10n.farmEditFarmName)
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditFarmBloc, EditFarmState, String?>(
                      selector: (state) => state.areaHaError,
                      builder: (context, areaHaError) => TextFormField(
                        controller: _areaHaController,
                        forceErrorText: areaHaError,
                        onChanged: areaHaError == null
                            ? null
                            : (_) => _editFarmBloc.add(
                                const EditFarmFieldErrorCleared('area_ha'),
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
                          labelText: '${l10n.farmEditFarmAreaHa} *',
                          hintText: l10n.fieldEnter(l10n.farmEditFarmAreaHa),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(l10n.farmEditFarmAreaHa)
                            : double.tryParse(v.trim()) == null
                            ? l10n.fieldInvalidNumber
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<EditFarmBloc, EditFarmState>(
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
                              labelText: l10n.farmEditFarmBlockId,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(l10n.farmEditFarmBlockId),
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
                                      _editFarmBloc.add(
                                        const EditFarmFieldErrorCleared(
                                          'block_id',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<EditFarmBloc, EditFarmState, String?>(
                      selector: (state) => state.villageError,
                      builder: (context, villageError) => TextFormField(
                        controller: _villageController,
                        forceErrorText: villageError,
                        onChanged: villageError == null
                            ? null
                            : (_) => _editFarmBloc.add(
                                const EditFarmFieldErrorCleared('village'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.farmEditFarmVillage,
                          hintText: l10n.fieldEnter(l10n.farmEditFarmVillage),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditFarmBloc, EditFarmState, String?>(
                      selector: (state) => state.addressError,
                      builder: (context, addressError) => TextFormField(
                        controller: _addressController,
                        forceErrorText: addressError,
                        onChanged: addressError == null
                            ? null
                            : (_) => _editFarmBloc.add(
                                const EditFarmFieldErrorCleared('address'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: l10n.farmEditFarmAddress,
                          hintText: l10n.fieldEnter(l10n.farmEditFarmAddress),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<EditFarmBloc, EditFarmState>(
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
                              labelText: l10n.farmEditFarmSoilType,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(l10n.farmEditFarmSoilType),
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
                                      _editFarmBloc.add(
                                        const EditFarmFieldErrorCleared(
                                          'soil_type',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocBuilder<EditFarmBloc, EditFarmState>(
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
                              labelText: l10n.farmEditFarmIrrigationType,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.farmEditFarmIrrigationType,
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
                                      _editFarmBloc.add(
                                        const EditFarmFieldErrorCleared(
                                          'irrigation_type',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocBuilder<EditFarmBloc, EditFarmState>(
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
                              labelText: l10n.farmEditFarmOwnership,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.farmEditFarmOwnership,
                                    ),
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
                                      _editFarmBloc.add(
                                        const EditFarmFieldErrorCleared(
                                          'ownership',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<EditFarmBloc, EditFarmState, String?>(
                      selector: (state) => state.latitudeError,
                      builder: (context, latitudeError) => TextFormField(
                        controller: _latitudeController,
                        forceErrorText: latitudeError,
                        onChanged: latitudeError == null
                            ? null
                            : (_) => _editFarmBloc.add(
                                const EditFarmFieldErrorCleared('latitude'),
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
                          labelText: l10n.farmEditFarmLatitude,
                          hintText: l10n.fieldEnter(l10n.farmEditFarmLatitude),
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
                    BlocSelector<EditFarmBloc, EditFarmState, String?>(
                      selector: (state) => state.longitudeError,
                      builder: (context, longitudeError) => TextFormField(
                        controller: _longitudeController,
                        forceErrorText: longitudeError,
                        onChanged: longitudeError == null
                            ? null
                            : (_) => _editFarmBloc.add(
                                const EditFarmFieldErrorCleared('longitude'),
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
                          labelText: l10n.farmEditFarmLongitude,
                          hintText: l10n.fieldEnter(l10n.farmEditFarmLongitude),
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
                    BlocSelector<EditFarmBloc, EditFarmState, bool>(
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
