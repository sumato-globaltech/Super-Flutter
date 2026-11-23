import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';

import '../bloc/farm_form_bloc.dart';
import '../bloc/farm_form_event.dart';
import '../bloc/farm_form_state.dart';

class FarmFormScreen extends StatelessWidget {
  final FarmModel? initialFarm;

  const FarmFormScreen({super.key, this.initialFarm});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<FarmFormBloc>()
            ..add(FarmFormInitialized(initialFarm: initialFarm)),
      child: _FarmFormView(initialFarm: initialFarm),
    );
  }
}

class _FarmFormView extends StatefulWidget {
  final FarmModel? initialFarm;

  const _FarmFormView({this.initialFarm});

  @override
  State<_FarmFormView> createState() => _FarmFormViewState();
}

class _FarmFormViewState extends State<_FarmFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _villageController;
  late final TextEditingController _addressController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  String? _selectedDistrictId;
  String? _selectedSoilType;
  String? _selectedIrrigationType;
  String? _selectedOwnership;

  static const List<Map<String, String>> _districts = [
    {'id': '01m6de2pq2ewspmabq763tymyn', 'name': 'Longleng'},
    {'id': '01m6de2pq2ewspmabq763tymya', 'name': 'Kohima'},
    {'id': '01m6de2pq2ewspmabq763tymy1', 'name': 'Dimapur'},
    {'id': '01m6de2pq2ewspmabq763tymy2', 'name': 'Mokokchung'},
    {'id': '01m6de2pq2ewspmabq763tymy3', 'name': 'Mon'},
    {'id': '01m6de2pq2ewspmabq763tymy4', 'name': 'Phek'},
    {'id': '01m6de2pq2ewspmabq763tymy5', 'name': 'Tuensang'},
    {'id': '01m6de2pq2ewspmabq763tymy6', 'name': 'Wokha'},
    {'id': '01m6de2pq2ewspmabq763tymy7', 'name': 'Zunheboto'},
  ];

  static const List<Map<String, String>> _soilTypes = [
    {'value': 'alluvial', 'label': 'Alluvial'},
    {'value': 'red', 'label': 'Red'},
    {'value': 'black', 'label': 'Black'},
    {'value': 'laterite', 'label': 'Laterite'},
    {'value': 'loamy', 'label': 'Loamy'},
    {'value': 'sandy', 'label': 'Sandy'},
  ];

  static const List<Map<String, String>> _irrigationTypes = [
    {'value': 'rainfed', 'label': 'Rainfed'},
    {'value': 'drip', 'label': 'Drip irrigation'},
    {'value': 'sprinkler', 'label': 'Sprinkler'},
    {'value': 'canal', 'label': 'Canal'},
    {'value': 'borewell', 'label': 'Borewell'},
  ];

  static const List<Map<String, String>> _ownerships = [
    {'value': 'owned', 'label': 'Owned'},
    {'value': 'leased', 'label': 'Leased'},
    {'value': 'shared', 'label': 'Shared'},
  ];

  @override
  void initState() {
    super.initState();
    final farm = widget.initialFarm;

    _nameController = TextEditingController(text: farm?.name ?? '');
    _areaController = TextEditingController(
      text: farm?.areaHa != null ? '${farm!.areaHa}' : '',
    );
    _villageController = TextEditingController(text: farm?.village ?? '');
    _addressController = TextEditingController(text: farm?.address ?? '');
    _latController = TextEditingController(
      text: farm?.latitude != null ? '${farm!.latitude}' : '',
    );
    _lngController = TextEditingController(
      text: farm?.longitude != null ? '${farm!.longitude}' : '',
    );

    _selectedDistrictId = farm?.district?.id ?? _districts.first['id'];
    _selectedSoilType = farm?.soilType?.value;
    _selectedIrrigationType = farm?.irrigationType?.value;
    _selectedOwnership = farm?.ownership?.value;
  }

  List<Map<String, String>> get _availableDistricts {
    final dist = widget.initialFarm?.district;
    if (dist?.id != null && !_districts.any((d) => d['id'] == dist!.id)) {
      return [
        {'id': dist!.id!, 'name': dist.name ?? dist.id!},
        ..._districts,
      ];
    }
    return _districts;
  }

  List<Map<String, String>> get _availableSoilTypes {
    final s = widget.initialFarm?.soilType;
    if (s?.value != null &&
        !_soilTypes.any((item) => item['value'] == s!.value)) {
      return [
        {'value': s!.value!, 'label': s.label ?? s.value!},
        ..._soilTypes,
      ];
    }
    return _soilTypes;
  }

  List<Map<String, String>> get _availableIrrigationTypes {
    final i = widget.initialFarm?.irrigationType;
    if (i?.value != null &&
        !_irrigationTypes.any((item) => item['value'] == i!.value)) {
      return [
        {'value': i!.value!, 'label': i.label ?? i.value!},
        ..._irrigationTypes,
      ];
    }
    return _irrigationTypes;
  }

  List<Map<String, String>> get _availableOwnerships {
    final o = widget.initialFarm?.ownership;
    if (o?.value != null &&
        !_ownerships.any((item) => item['value'] == o!.value)) {
      return [
        {'value': o!.value!, 'label': o.label ?? o.value!},
        ..._ownerships,
      ];
    }
    return _ownerships;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'area_ha': double.parse(_areaController.text.trim()),
      if (_selectedDistrictId != null) 'district_id': _selectedDistrictId,
      if (_villageController.text.trim().isNotEmpty)
        'village': _villageController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'address': _addressController.text.trim(),
      if (_selectedSoilType != null) 'soil_type': _selectedSoilType,
      if (_selectedIrrigationType != null)
        'irrigation_type': _selectedIrrigationType,
      if (_selectedOwnership != null) 'ownership': _selectedOwnership,
      if (_latController.text.trim().isNotEmpty)
        'latitude': double.tryParse(_latController.text.trim()),
      if (_lngController.text.trim().isNotEmpty)
        'longitude': double.tryParse(_lngController.text.trim()),
    };

    context.read<FarmFormBloc>().add(FarmFormSubmitted(data));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing =
        widget.initialFarm != null && widget.initialFarm!.id != null;

    return BlocListener<FarmFormBloc, FarmFormState>(
      listener: (context, state) {
        if (state.status == FarmFormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? l10n.farmUpdated : l10n.farmCreated),
            ),
          );
          context.pop(true);
        } else if (state.status == FarmFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.errorUnknown),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: isEditing ? l10n.editFarm : l10n.addFarm),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: BlocBuilder<FarmFormBloc, FarmFormState>(
              builder: (context, state) {
                final isLoading = state.status == FarmFormStatus.loading;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: DesignProgress(),
                          )
                        : Text(isEditing ? l10n.updateFarm : l10n.createFarm),
                  ),
                );
              },
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${l10n.farmName} *',
                  prefixIcon: const Icon(PhosphorIconsRegular.plant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fieldRequired(l10n.farmName);
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _areaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: '${l10n.areaHectares} *',
                  prefixIcon: const Icon(PhosphorIconsRegular.compass),
                  suffixText: 'ha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fieldRequired(l10n.areaHectares);
                  }
                  final num = double.tryParse(val.trim());
                  if (num == null || num <= 0) {
                    return l10n.invalidArea;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedDistrictId,
                decoration: InputDecoration(
                  labelText: l10n.district,
                  prefixIcon: const Icon(PhosphorIconsRegular.mapPin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _availableDistricts
                    .map(
                      (d) => DropdownMenuItem(
                        value: d['id'],
                        child: Text(d['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedDistrictId = val),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _villageController,
                decoration: InputDecoration(
                  labelText: l10n.village,
                  prefixIcon: const Icon(PhosphorIconsRegular.houseLine),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  prefixIcon: const Icon(PhosphorIconsRegular.mapTrifold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedSoilType,
                decoration: InputDecoration(
                  labelText: l10n.soilType,
                  prefixIcon: const Icon(PhosphorIconsRegular.mountains),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _availableSoilTypes
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['value'],
                        child: Text(s['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedSoilType = val),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedIrrigationType,
                decoration: InputDecoration(
                  labelText: l10n.irrigationMethod,
                  prefixIcon: const Icon(PhosphorIconsRegular.drop),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _availableIrrigationTypes
                    .map(
                      (i) => DropdownMenuItem(
                        value: i['value'],
                        child: Text(i['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedIrrigationType = val),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedOwnership,
                decoration: InputDecoration(
                  labelText: l10n.landOwnership,
                  prefixIcon: const Icon(PhosphorIconsRegular.certificate),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _availableOwnerships
                    .map(
                      (o) => DropdownMenuItem(
                        value: o['value'],
                        child: Text(o['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedOwnership = val),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.latitude,
                  prefixIcon: const Icon(PhosphorIconsRegular.navigationArrow),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _lngController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.longitude,
                  prefixIcon: const Icon(PhosphorIconsRegular.navigationArrow),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
