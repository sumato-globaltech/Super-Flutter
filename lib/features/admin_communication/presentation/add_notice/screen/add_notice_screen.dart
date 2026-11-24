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
import 'package:super_flutter/features/admin_communication/presentation/notice_body.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_notice/bloc/add_notice_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_notice/bloc/add_notice_event.dart';
import 'package:super_flutter/features/admin_communication/presentation/add_notice/bloc/add_notice_state.dart';

class AddNoticeScreen extends StatelessWidget {
  const AddNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddNoticeBloc>()..add(const AddNoticeStarted()),
      child: const _AddNoticeView(),
    );
  }
}

class _AddNoticeView extends StatefulWidget {
  const _AddNoticeView();

  @override
  State<_AddNoticeView> createState() => _AddNoticeViewState();
}

class _AddNoticeViewState extends State<_AddNoticeView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _expiresOnController = TextEditingController();
  String? _categoryId;
  String? _priority;
  DateTime? _expiresOn;
  late final AddNoticeBloc _addNoticeBloc;

  @override
  void initState() {
    super.initState();
    _addNoticeBloc = context.read<AddNoticeBloc>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _expiresOnController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiresOn() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresOn ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 50),
      helpText: l10n.fieldSelect(l10n.adminCommunicationAddNoticeExpiresOn),
    );
    if (picked == null) return;
    _expiresOn = picked;
    _expiresOnController.text = DateFormat('dd MMM yyyy').format(picked);
    if (_addNoticeBloc.state.expiresOnError != null) {
      _addNoticeBloc.add(const AddNoticeFieldErrorCleared('expires_on'));
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _addNoticeBloc.add(
      AddNoticeSubmitted(
        categoryId: _categoryId!,
        title: _titleController.text.trim(),
        body: noticeBodyToHtml(_bodyController.text),
        priority: _priority!,
        expiresOn: _expiresOn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<AddNoticeBloc, AddNoticeState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case AddNoticeStatus.success:
            Utils.flutterToast(l10n.adminCommunicationAddNoticeDone);
            context.pop(true);
          case AddNoticeStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case AddNoticeStatus.initial || AddNoticeStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.adminCommunicationAddNoticeTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BlocBuilder<AddNoticeBloc, AddNoticeState>(
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
                              '${l10n.adminCommunicationAddNoticeCategoryId} *',
                          hintText: state.loadingOptions
                              ? l10n.loading
                              : l10n.fieldSelect(
                                  l10n.adminCommunicationAddNoticeCategoryId,
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
                                  _addNoticeBloc.add(
                                    const AddNoticeFieldErrorCleared(
                                      'category_id',
                                    ),
                                  );
                                }
                              },
                        validator: (value) => value == null
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationAddNoticeCategoryId,
                              )
                            : null,
                      ),
                    ),
                    12.height,
                    BlocSelector<AddNoticeBloc, AddNoticeState, String?>(
                      selector: (state) => state.titleError,
                      builder: (context, titleError) => TextFormField(
                        controller: _titleController,
                        forceErrorText: titleError,
                        onChanged: titleError == null
                            ? null
                            : (_) => _addNoticeBloc.add(
                                const AddNoticeFieldErrorCleared('title'),
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
                    BlocSelector<AddNoticeBloc, AddNoticeState, String?>(
                      selector: (state) => state.bodyError,
                      builder: (context, bodyError) => TextFormField(
                        controller: _bodyController,
                        forceErrorText: bodyError,
                        onChanged: bodyError == null
                            ? null
                            : (_) => _addNoticeBloc.add(
                                const AddNoticeFieldErrorCleared('body'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: l10n.adminCommunicationAddNoticeBody,
                          hintText: l10n.fieldEnter(
                            l10n.adminCommunicationAddNoticeBody,
                          ),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<AddNoticeBloc, AddNoticeState>(
                      buildWhen: (prev, curr) =>
                          prev.priorityOptions != curr.priorityOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.priorityError != curr.priorityError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            forceErrorText: state.priorityError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText:
                                  '${l10n.adminCommunicationAddNoticePriority} *',
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.adminCommunicationAddNoticePriority,
                                    ),
                            ),
                            items: [
                              for (final option in state.priorityOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _priority = value;
                                    if (state.priorityError != null) {
                                      _addNoticeBloc.add(
                                        const AddNoticeFieldErrorCleared(
                                          'priority',
                                        ),
                                      );
                                    }
                                  },
                            validator: (value) => value == null
                                ? l10n.fieldRequired(
                                    l10n.adminCommunicationAddNoticePriority,
                                  )
                                : null,
                          ),
                    ),
                    12.height,
                    BlocSelector<AddNoticeBloc, AddNoticeState, String?>(
                      selector: (state) => state.expiresOnError,
                      builder: (context, expiresOnError) => TextFormField(
                        controller: _expiresOnController,
                        forceErrorText: expiresOnError,
                        readOnly: true,
                        onTap: _pickExpiresOn,
                        decoration: InputDecoration(
                          labelText: l10n.adminCommunicationAddNoticeExpiresOn,
                          hintText: l10n.fieldSelect(
                            l10n.adminCommunicationAddNoticeExpiresOn,
                          ),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                    12.height,
                    BlocSelector<AddNoticeBloc, AddNoticeState, bool>(
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
