import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_alert/bloc/add_alert_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_alert/bloc/add_alert_event.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_alert/bloc/add_alert_state.dart';

class AddAlertScreen extends StatelessWidget {
  const AddAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddAlertBloc>()..add(const AddAlertStarted()),
      child: const _AddAlertView(),
    );
  }
}

class _AddAlertView extends StatefulWidget {
  const _AddAlertView();

  @override
  State<_AddAlertView> createState() => _AddAlertViewState();
}

class _AddAlertViewState extends State<_AddAlertView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startsOnController = TextEditingController();
  final TextEditingController _endsOnController = TextEditingController();
  String? _categoryId;
  String? _districtId;
  String? _severity;
  DateTime? _startsOn;
  DateTime? _endsOn;
  late final AddAlertBloc _addAlertBloc;

  @override
  void initState() {
    super.initState();
    _addAlertBloc = context.read<AddAlertBloc>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startsOnController.dispose();
    _endsOnController.dispose();
    super.dispose();
  }

  Future<void> _pickStartsOn() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsOn ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 50),
      helpText: l10n.fieldSelect(l10n.adminCommunicationAddAlertStartsOn),
    );
    if (picked == null) return;
    _startsOn = picked;
    _startsOnController.text = DateFormat('dd MMM yyyy').format(picked);
    if (_addAlertBloc.state.startsOnError != null) {
      _addAlertBloc.add(const AddAlertFieldErrorCleared('starts_on'));
    }
  }

  Future<void> _pickEndsOn() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsOn ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 50),
      helpText: l10n.fieldSelect(l10n.adminCommunicationAddAlertEndsOn),
    );
    if (picked == null) return;
    _endsOn = picked;
    _endsOnController.text = DateFormat('dd MMM yyyy').format(picked);
    if (_addAlertBloc.state.endsOnError != null) {
      _addAlertBloc.add(const AddAlertFieldErrorCleared('ends_on'));
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _addAlertBloc.add(
      AddAlertSubmitted(
        categoryId: _categoryId!,
        districtId: _districtId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        severity: _severity!,
        startsOn: _startsOn!,
        endsOn: _endsOn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<AddAlertBloc, AddAlertState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case AddAlertStatus.success:
            Utils.flutterToast(l10n.adminCommunicationAddAlertDone);
            context.pop(true);
          case AddAlertStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case AddAlertStatus.initial || AddAlertStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.adminCommunicationAddAlertTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BlocBuilder<AddAlertBloc, AddAlertState>(
                      buildWhen: (prev, curr) =>
                          prev.categoryOptions != curr.categoryOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.categoryIdError != curr.categoryIdError,
                      builder: (context, state) => DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        forceErrorText: state.categoryIdError,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.adminCommunicationAddAlertCategoryId} *',
                          hintText: state.loadingOptions
                              ? l10n.loading
                              : l10n.fieldSelect(
                                  l10n.adminCommunicationAddAlertCategoryId,
                                ),
                        ),
                        items: [
                          for (final option in state.categoryOptions)
                            DropdownMenuItem(
                              value: option.id,
                              child: Text(option.name ?? ''),
                            ),
                        ],
                        onChanged: state.loadingOptions
                            ? null
                            : (value) {
                                _categoryId = value;
                                if (state.categoryIdError != null) {
                                  _addAlertBloc.add(
                                    const AddAlertFieldErrorCleared(
                                      'category_id',
                                    ),
                                  );
                                }
                              },
                        validator: (value) => value == null
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationAddAlertCategoryId,
                              )
                            : null,
                      ),
                    ),
                    12.height,
                    BlocBuilder<AddAlertBloc, AddAlertState>(
                      buildWhen: (prev, curr) =>
                          prev.districtOptions != curr.districtOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.districtIdError != curr.districtIdError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _districtId,
                            forceErrorText: state.districtIdError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText:
                                  l10n.adminCommunicationAddAlertDistrictId,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.adminCommunicationAddAlertDistrictId,
                                    ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                child: Text(l10n.adminAlertStatewide),
                              ),
                              for (final option in state.districtOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _districtId = value;
                                    if (state.districtIdError != null) {
                                      _addAlertBloc.add(
                                        const AddAlertFieldErrorCleared(
                                          'district_id',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<AddAlertBloc, AddAlertState, String?>(
                      selector: (state) => state.titleError,
                      builder: (context, titleError) => TextFormField(
                        controller: _titleController,
                        forceErrorText: titleError,
                        onChanged: titleError == null
                            ? null
                            : (_) => _addAlertBloc.add(
                                const AddAlertFieldErrorCleared('title'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '${l10n.adminTitle} *',
                          hintText: l10n.fieldEnter(l10n.adminTitle),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(l10n.adminTitle)
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<AddAlertBloc, AddAlertState, String?>(
                      selector: (state) => state.descriptionError,
                      builder: (context, descriptionError) => TextFormField(
                        controller: _descriptionController,
                        forceErrorText: descriptionError,
                        onChanged: descriptionError == null
                            ? null
                            : (_) => _addAlertBloc.add(
                                const AddAlertFieldErrorCleared('description'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.adminCommunicationAddAlertDescription} *',
                          hintText: l10n.fieldEnter(
                            l10n.adminCommunicationAddAlertDescription,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationAddAlertDescription,
                              )
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<AddAlertBloc, AddAlertState>(
                      buildWhen: (prev, curr) =>
                          prev.severityOptions != curr.severityOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.severityError != curr.severityError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _severity,
                            forceErrorText: state.severityError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText:
                                  '${l10n.adminCommunicationAddAlertSeverity} *',
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.adminCommunicationAddAlertSeverity,
                                    ),
                            ),
                            items: [
                              for (final option in state.severityOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _severity = value;
                                    if (state.severityError != null) {
                                      _addAlertBloc.add(
                                        const AddAlertFieldErrorCleared(
                                          'severity',
                                        ),
                                      );
                                    }
                                  },
                            validator: (value) => value == null
                                ? l10n.fieldRequired(
                                    l10n.adminCommunicationAddAlertSeverity,
                                  )
                                : null,
                          ),
                    ),
                    12.height,
                    BlocSelector<AddAlertBloc, AddAlertState, String?>(
                      selector: (state) => state.startsOnError,
                      builder: (context, startsOnError) => TextFormField(
                        controller: _startsOnController,
                        forceErrorText: startsOnError,
                        readOnly: true,
                        onTap: _pickStartsOn,
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.adminCommunicationAddAlertStartsOn} *',
                          hintText: l10n.fieldSelect(
                            l10n.adminCommunicationAddAlertStartsOn,
                          ),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        validator: (_) => _startsOn == null
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationAddAlertStartsOn,
                              )
                            : null,
                      ),
                    ),
                    12.height,
                    BlocSelector<AddAlertBloc, AddAlertState, String?>(
                      selector: (state) => state.endsOnError,
                      builder: (context, endsOnError) => TextFormField(
                        controller: _endsOnController,
                        forceErrorText: endsOnError,
                        readOnly: true,
                        onTap: _pickEndsOn,
                        decoration: InputDecoration(
                          labelText: l10n.adminCommunicationAddAlertEndsOn,
                          hintText: l10n.fieldSelect(
                            l10n.adminCommunicationAddAlertEndsOn,
                          ),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                    12.height,
                    BlocSelector<AddAlertBloc, AddAlertState, bool>(
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
