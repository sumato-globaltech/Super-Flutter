import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/data/shipments/model/shipment_options_model.dart';
import 'package:super_flutter/features/shipments/presentation/request_shipment/bloc/request_shipment_bloc.dart';
import 'package:super_flutter/features/shipments/presentation/request_shipment/bloc/request_shipment_event.dart';
import 'package:super_flutter/features/shipments/presentation/request_shipment/bloc/request_shipment_state.dart';

class RequestShipmentScreen extends StatelessWidget {
  const RequestShipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<RequestShipmentBloc>()..add(const RequestShipmentStarted()),
      child: const _RequestShipmentView(),
    );
  }
}

class _ItemDraft {
  String? cropId;
  String? unitId;
  final TextEditingController quantity = TextEditingController();
}

class _RequestShipmentView extends StatefulWidget {
  const _RequestShipmentView();

  @override
  State<_RequestShipmentView> createState() => _RequestShipmentViewState();
}

class _RequestShipmentViewState extends State<_RequestShipmentView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  final List<_ItemDraft> _items = [_ItemDraft()];
  String? _vendorId;
  String? _districtId;
  DateTime? _pickupOn;
  bool _prefilled = false;
  late final RequestShipmentBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<RequestShipmentBloc>();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    for (final item in _items) {
      item.quantity.dispose();
    }
    super.dispose();
  }

  void _prefill(ShipmentOptionsModel options) {
    _prefilled = true;
    final defaults = options.defaults;
    _addressController.text = defaults?.pickupAddress ?? '';
    _districtId = defaults?.pickupDistrictId;
    final date = DateTime.tryParse(defaults?.preferredPickupOn ?? '');
    if (date != null) _setDate(date);
    final units = options.units ?? const [];
    if (units.length == 1) _items.first.unitId = units.first.id;
  }

  void _setDate(DateTime date) {
    _pickupOn = date;
    _dateController.text = MaterialLocalizations.of(context)
        .formatMediumDate(date);
  }

  void _clearError(String field) {
    if (_bloc.state.fieldErrors.containsKey(field)) {
      _bloc.add(RequestShipmentFieldErrorCleared(field));
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notes = _notesController.text.trim();
    _bloc.add(
      RequestShipmentSubmitted(
        vendorId: _vendorId!,
        pickupDistrictId: _districtId!,
        pickupAddress: _addressController.text.trim(),
        preferredPickupOn: _pickupOn!,
        notes: notes.isEmpty ? null : notes,
        items: [
          for (final item in _items)
            {
              'crop_id': item.cropId,
              'quantity': double.parse(item.quantity.text.trim()),
              'unit_id': item.unitId,
            },
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<RequestShipmentBloc, RequestShipmentState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.options != curr.options,
      listener: (context, state) {
        final options = state.options;
        if (!_prefilled && options != null) setState(() => _prefill(options));
        switch (state.status) {
          case RequestShipmentStatus.success:
            Utils.flutterToast(l10n.shipmentsRequested);
            context.pop(true);
          case RequestShipmentStatus.failure
              when state.options != null && state.fieldErrors.isEmpty:
            context.showSnackBar(
              state.errorMessage ?? l10n.errorUnknown,
              isError: true,
            );
          default:
            break;
        }
      },
      builder: (context, state) {
        final options = state.options;
        return Scaffold(
          appBar: AppTopBar(title: l10n.shipmentsRequestShipmentTitle),
          bottomNavigationBar: options == null
              ? null
              : SafeArea(
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: state.isSubmitting ? null : _submit,
                        child: state.isSubmitting
                            ? const DesignProgress()
                            : Text(l10n.shipmentsSend),
                      ),
                    ),
                  ),
                ),
          body: options == null
              ? state.status == RequestShipmentStatus.failure
                    ? AppErrorView(
                        message: state.errorMessage ?? l10n.errorUnknown,
                        retryLabel: l10n.tryAgain,
                        onRetry: () =>
                            _bloc.add(const RequestShipmentStarted()),
                      )
                    : const Center(child: DesignProgress())
              : SingleChildScrollView(
                  padding: AppSpacing.pagePadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _vendorId,
                          isExpanded: true,
                          forceErrorText: state.fieldErrors['vendor_id'],
                          decoration: InputDecoration(
                            labelText: '${l10n.shipmentsVendor} *',
                            hintText: l10n.fieldSelect(l10n.shipmentsVendor),
                            prefixIcon: const Icon(
                              PhosphorIconsRegular.storefront,
                            ),
                          ),
                          items: [
                            for (final vendor in options.vendors ?? const [])
                              DropdownMenuItem(
                                value: vendor.id,
                                child: Text(
                                  [
                                    vendor.name ?? '--',
                                    if ((vendor.districts ?? const [])
                                        .isNotEmpty)
                                      vendor.districts!.join(', '),
                                  ].join(' · '),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            _vendorId = value;
                            _clearError('vendor_id');
                          },
                          validator: (value) => value == null
                              ? l10n.fieldRequired(l10n.shipmentsVendor)
                              : null,
                        ),
                        12.height,
                        DropdownButtonFormField<String>(
                          key: ValueKey('district-$_prefilled'),
                          initialValue: _districtId,
                          isExpanded: true,
                          forceErrorText:
                              state.fieldErrors['pickup_district_id'],
                          decoration: InputDecoration(
                            labelText: '${l10n.shipmentsPickupDistrict} *',
                            hintText: l10n.fieldSelect(
                              l10n.shipmentsPickupDistrict,
                            ),
                            prefixIcon: const Icon(PhosphorIconsRegular.mapPin),
                          ),
                          items: [
                            for (final district
                                in options.pickupDistricts ?? const [])
                              DropdownMenuItem(
                                value: district.id,
                                child: Text(district.name ?? '--'),
                              ),
                          ],
                          onChanged: (value) {
                            _districtId = value;
                            _clearError('pickup_district_id');
                          },
                          validator: (value) => value == null
                              ? l10n.fieldRequired(l10n.shipmentsPickupDistrict)
                              : null,
                        ),
                        12.height,
                        TextFormField(
                          controller: _addressController,
                          forceErrorText: state.fieldErrors['pickup_address'],
                          onChanged: (_) => _clearError('pickup_address'),
                          minLines: 2,
                          maxLines: 4,
                          maxLength: 255,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: '${l10n.shipmentsPickupAddress} *',
                            prefixIcon: const Icon(PhosphorIconsRegular.house),
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? l10n.fieldRequired(l10n.shipmentsPickupAddress)
                              : null,
                        ),
                        12.height,
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          forceErrorText:
                              state.fieldErrors['preferred_pickup_on'],
                          decoration: InputDecoration(
                            labelText: '${l10n.shipmentsPickupOn} *',
                            hintText: l10n.fieldSelect(l10n.shipmentsPickupOn),
                            prefixIcon: const Icon(
                              PhosphorIconsRegular.calendarBlank,
                            ),
                          ),
                          validator: (_) => _pickupOn == null
                              ? l10n.fieldRequired(l10n.shipmentsPickupOn)
                              : null,
                          onTap: () async {
                            final today = DateUtils.dateOnly(DateTime.now());
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _pickupOn ?? today,
                              firstDate: today,
                              lastDate: today.add(const Duration(days: 364)),
                              helpText: l10n.fieldSelect(
                                l10n.shipmentsPickupOn,
                              ),
                            );
                            if (picked == null) return;
                            setState(() => _setDate(picked));
                            _clearError('preferred_pickup_on');
                          },
                        ),
                        20.height,
                        Text(
                          l10n.shipmentsItems,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (state.fieldErrors['items'] case final error?) ...[
                          4.height,
                          Text(
                            error,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        8.height,
                        for (final (index, item) in _items.indexed) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${l10n.shipmentsItem} ${index + 1}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              if (_items.length > 1)
                                IconButton(
                                  tooltip: l10n.shipmentsRemoveItem,
                                  icon: const Icon(PhosphorIconsRegular.trash),
                                  onPressed: () => setState(() {
                                    _items.removeAt(index).quantity.dispose();
                                  }),
                                ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            key: ObjectKey(item),
                            initialValue: item.cropId,
                            isExpanded: true,
                            forceErrorText:
                                state.fieldErrors['items.$index.crop_id'],
                            decoration: InputDecoration(
                              labelText: '${l10n.shipmentsCrop} *',
                              hintText: l10n.fieldSelect(l10n.shipmentsCrop),
                              prefixIcon: const Icon(
                                PhosphorIconsRegular.plant,
                              ),
                            ),
                            items: [
                              for (final crop in options.crops ?? const [])
                                DropdownMenuItem(
                                  value: crop.id,
                                  child: Text(crop.name ?? '--'),
                                ),
                            ],
                            onChanged: (value) {
                              item.cropId = value;
                              _clearError('items.$index.crop_id');
                            },
                            validator: (value) => value == null
                                ? l10n.fieldRequired(l10n.shipmentsCrop)
                                : null,
                          ),
                          12.height,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.quantity,
                                  forceErrorText: state
                                      .fieldErrors['items.$index.quantity'],
                                  onChanged: (_) =>
                                      _clearError('items.$index.quantity'),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,3}'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: '${l10n.shipmentsQuantity} *',
                                  ),
                                  validator: (value) {
                                    final quantity = double.tryParse(
                                      (value ?? '').trim(),
                                    );
                                    return quantity == null || quantity <= 0
                                        ? l10n.shipmentsInvalidQuantity
                                        : null;
                                  },
                                ),
                              ),
                              12.width,
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  key: ObjectKey((item, 'unit', _prefilled)),
                                  initialValue: item.unitId,
                                  isExpanded: true,
                                  forceErrorText:
                                      state.fieldErrors['items.$index.unit_id'],
                                  decoration: InputDecoration(
                                    labelText: '${l10n.shipmentsUnit} *',
                                  ),
                                  items: [
                                    for (final unit
                                        in options.units ?? const [])
                                      DropdownMenuItem(
                                        value: unit.id,
                                        child: Text(
                                          unit.name ?? '--',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    item.unitId = value;
                                    _clearError('items.$index.unit_id');
                                  },
                                  validator: (value) => value == null
                                      ? l10n.fieldRequired(l10n.shipmentsUnit)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          16.height,
                        ],
                        if (_items.length < (options.limits?.maxItems ?? 50))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () =>
                                  setState(() => _items.add(_ItemDraft())),
                              icon: const Icon(PhosphorIconsRegular.plus),
                              label: Text(l10n.shipmentsAddItem),
                            ),
                          ),
                        12.height,
                        TextFormField(
                          controller: _notesController,
                          forceErrorText: state.fieldErrors['notes'],
                          onChanged: (_) => _clearError('notes'),
                          minLines: 2,
                          maxLines: 5,
                          maxLength: 2000,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: l10n.shipmentsNotes,
                            prefixIcon: const Icon(
                              PhosphorIconsRegular.notePencil,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
