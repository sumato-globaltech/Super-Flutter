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
import 'package:super_flutter/data/admin_communication/model/admin_alert_model.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_alert/bloc/edit_alert_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_alert/bloc/edit_alert_event.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_alert/bloc/edit_alert_state.dart';

class EditAlertScreen extends StatelessWidget {
  const EditAlertScreen({super.key, required this.alert});

  final AdminAlertModel alert;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditAlertBloc>()..add(const EditAlertStarted()),
      child: _EditAlertView(alert: alert),
    );
  }
}

class _EditAlertView extends StatefulWidget {
  const _EditAlertView({required this.alert});

  final AdminAlertModel alert;

  @override
  State<_EditAlertView> createState() => _EditAlertViewState();
}

class _EditAlertViewState extends State<_EditAlertView> {
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
  late final EditAlertBloc _editAlertBloc;

  @override
  void initState() {
    super.initState();
    _editAlertBloc = context.read<EditAlertBloc>();
    final alert = widget.alert;
    _categoryId = alert.category?.id;
    _districtId = alert.district?.id;
    _severity = alert.severity?.value;
    _titleController.text = alert.title ?? '';
    _descriptionController.text = alert.description ?? '';
    final format = DateFormat('dd MMM yyyy');
    if (DateTime.tryParse(alert.startsOn ?? '') case final starts?) {
      _startsOn = starts;
      _startsOnController.text = format.format(starts);
    }
    if (DateTime.tryParse(alert.endsOn ?? '') case final ends?) {
      _endsOn = ends;
      _endsOnController.text = format.format(ends);
    }
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
      helpText: l10n.fieldSelect(l10n.adminCommunicationEditAlertStartsOn),
    );
    if (picked == null) return;
    _startsOn = picked;
    _startsOnController.text = DateFormat('dd MMM yyyy').format(picked);
    if (_editAlertBloc.state.startsOnError != null) {
      _editAlertBloc.add(const EditAlertFieldErrorCleared('starts_on'));
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
      helpText: l10n.fieldSelect(l10n.adminCommunicationEditAlertEndsOn),
    );
    if (picked == null) return;
    _endsOn = picked;
    _endsOnController.text = DateFormat('dd MMM yyyy').format(picked);
    if (_editAlertBloc.state.endsOnError != null) {
      _editAlertBloc.add(const EditAlertFieldErrorCleared('ends_on'));
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _editAlertBloc.add(
      EditAlertSubmitted(
        alert: widget.alert.id!,
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
    return BlocListener<EditAlertBloc, EditAlertState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case EditAlertStatus.success:
            Utils.flutterToast(l10n.adminCommunicationEditAlertDone);
            context.pop(true);
          case EditAlertStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case EditAlertStatus.initial || EditAlertStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.adminCommunicationEditAlertTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BlocBuilder<EditAlertBloc, EditAlertState>(
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
                              '${l10n.adminCommunicationEditAlertCategoryId} *',
                          hintText: state.loadingOptions
                              ? l10n.loading
                              : l10n.fieldSelect(
                                  l10n.adminCommunicationEditAlertCategoryId,
                                ),
                        ),
                        items: [
                          if ((
                                widget.alert.category?.id,
                                widget.alert.category?.name,
                              )
                              case (final id?, final name)
                              when !state.categoryOptions.any(
                                (option) => option.id == id,
                              ))
                            DropdownMenuItem(
                              value: id,
                              child: Text(name ?? id),
                            ),
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
                                  _editAlertBloc.add(
                                    const EditAlertFieldErrorCleared(
                                      'category_id',
                                    ),
                                  );
                                }
                              },
                        validator: (value) => value == null
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationEditAlertCategoryId,
                              )
                            : null,
                      ),
                    ),
                    12.height,
                    BlocBuilder<EditAlertBloc, EditAlertState>(
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
                                  l10n.adminCommunicationEditAlertDistrictId,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.adminCommunicationEditAlertDistrictId,
                                    ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                child: Text(l10n.adminAlertStatewide),
                              ),
                              if ((
                                    widget.alert.district?.id,
                                    widget.alert.district?.name,
                                  )
                                  case (final id?, final name)
                                  when !state.districtOptions.any(
                                    (option) => option.id == id,
                                  ))
                                DropdownMenuItem(
                                  value: id,
                                  child: Text(name ?? id),
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
                                      _editAlertBloc.add(
                                        const EditAlertFieldErrorCleared(
                                          'district_id',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<EditAlertBloc, EditAlertState, String?>(
                      selector: (state) => state.titleError,
                      builder: (context, titleError) => TextFormField(
                        controller: _titleController,
                        forceErrorText: titleError,
                        onChanged: titleError == null
                            ? null
                            : (_) => _editAlertBloc.add(
                                const EditAlertFieldErrorCleared('title'),
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
                    BlocSelector<EditAlertBloc, EditAlertState, String?>(
                      selector: (state) => state.descriptionError,
                      builder: (context, descriptionError) => TextFormField(
                        controller: _descriptionController,
                        forceErrorText: descriptionError,
                        onChanged: descriptionError == null
                            ? null
                            : (_) => _editAlertBloc.add(
                                const EditAlertFieldErrorCleared('description'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.adminCommunicationEditAlertDescription} *',
                          hintText: l10n.fieldEnter(
                            l10n.adminCommunicationEditAlertDescription,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationEditAlertDescription,
                              )
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<EditAlertBloc, EditAlertState>(
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
                                  '${l10n.adminCommunicationEditAlertSeverity} *',
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.adminCommunicationEditAlertSeverity,
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
                                      _editAlertBloc.add(
                                        const EditAlertFieldErrorCleared(
                                          'severity',
                                        ),
                                      );
                                    }
                                  },
                            validator: (value) => value == null
                                ? l10n.fieldRequired(
                                    l10n.adminCommunicationEditAlertSeverity,
                                  )
                                : null,
                          ),
                    ),
                    12.height,
                    BlocSelector<EditAlertBloc, EditAlertState, String?>(
                      selector: (state) => state.startsOnError,
                      builder: (context, startsOnError) => TextFormField(
                        controller: _startsOnController,
                        forceErrorText: startsOnError,
                        readOnly: true,
                        onTap: _pickStartsOn,
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.adminCommunicationEditAlertStartsOn} *',
                          hintText: l10n.fieldSelect(
                            l10n.adminCommunicationEditAlertStartsOn,
                          ),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        validator: (_) => _startsOn == null
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationEditAlertStartsOn,
                              )
                            : null,
                      ),
                    ),
                    12.height,
                    BlocSelector<EditAlertBloc, EditAlertState, String?>(
                      selector: (state) => state.endsOnError,
                      builder: (context, endsOnError) => TextFormField(
                        controller: _endsOnController,
                        forceErrorText: endsOnError,
                        readOnly: true,
                        onTap: _pickEndsOn,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .deleteButtonTooltip,
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _endsOn = null;
                              _endsOnController.clear();
                              if (_editAlertBloc.state.endsOnError != null) {
                                _editAlertBloc.add(
                                  const EditAlertFieldErrorCleared('ends_on'),
                                );
                              }
                            },
                          ),
                          labelText: l10n.adminCommunicationEditAlertEndsOn,
                          hintText: l10n.fieldSelect(
                            l10n.adminCommunicationEditAlertEndsOn,
                          ),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditAlertBloc, EditAlertState, bool>(
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
