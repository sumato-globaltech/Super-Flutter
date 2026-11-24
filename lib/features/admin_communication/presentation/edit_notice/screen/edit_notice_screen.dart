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
import 'package:super_flutter/data/admin_communication/model/admin_notice_model.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_notice/bloc/edit_notice_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_notice/bloc/edit_notice_event.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_notice/bloc/edit_notice_state.dart';
import 'package:super_flutter/features/admin_communication/presentation/notice_body.dart';

class EditNoticeScreen extends StatelessWidget {
  const EditNoticeScreen({super.key, required this.notice});

  final AdminNoticeModel notice;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditNoticeBloc>()..add(const EditNoticeStarted()),
      child: _EditNoticeView(notice: notice),
    );
  }
}

class _EditNoticeView extends StatefulWidget {
  const _EditNoticeView({required this.notice});

  final AdminNoticeModel notice;

  @override
  State<_EditNoticeView> createState() => _EditNoticeViewState();
}

class _EditNoticeViewState extends State<_EditNoticeView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _expiresOnController = TextEditingController();
  String? _categoryId;
  String? _priority;
  DateTime? _expiresOn;
  late final EditNoticeBloc _editNoticeBloc;

  @override
  void initState() {
    super.initState();
    _editNoticeBloc = context.read<EditNoticeBloc>();
    final notice = widget.notice;
    _categoryId = notice.category?.id;
    _priority = notice.priority?.value;
    _titleController.text = notice.title ?? '';
    _bodyController.text = noticeBodyToText(notice.body);
    if (notice.expiresAt?.toLocal() case final expires?) {
      _expiresOn = expires;
      _expiresOnController.text = DateFormat('dd MMM yyyy').format(expires);
    }
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
      helpText: l10n.fieldSelect(l10n.adminCommunicationEditNoticeExpiresOn),
    );
    if (picked == null) return;
    _expiresOn = picked;
    _expiresOnController.text = DateFormat('dd MMM yyyy').format(picked);
    if (_editNoticeBloc.state.expiresOnError != null) {
      _editNoticeBloc.add(const EditNoticeFieldErrorCleared('expires_on'));
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _editNoticeBloc.add(
      EditNoticeSubmitted(
        notice: widget.notice.id!,
        categoryId: _categoryId!,
        title: _titleController.text.trim(),
        // Unchanged text keeps the formatting it was written with.
        body:
            _bodyController.text.trim() == noticeBodyToText(widget.notice.body)
            ? widget.notice.body
            : noticeBodyToHtml(_bodyController.text),
        priority: _priority!,
        expiresOn: _expiresOn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<EditNoticeBloc, EditNoticeState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case EditNoticeStatus.success:
            Utils.flutterToast(l10n.adminCommunicationEditNoticeDone);
            context.pop(true);
          case EditNoticeStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case EditNoticeStatus.initial || EditNoticeStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.adminCommunicationEditNoticeTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BlocBuilder<EditNoticeBloc, EditNoticeState>(
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
                              '${l10n.adminCommunicationEditNoticeCategoryId} *',
                          hintText: state.loadingOptions
                              ? l10n.loading
                              : l10n.fieldSelect(
                                  l10n.adminCommunicationEditNoticeCategoryId,
                                ),
                        ),
                        items: [
                          if ((
                                widget.notice.category?.id,
                                widget.notice.category?.name,
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
                                  _editNoticeBloc.add(
                                    const EditNoticeFieldErrorCleared(
                                      'category_id',
                                    ),
                                  );
                                }
                              },
                        validator: (value) => value == null
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationEditNoticeCategoryId,
                              )
                            : null,
                      ),
                    ),
                    12.height,
                    BlocSelector<EditNoticeBloc, EditNoticeState, String?>(
                      selector: (state) => state.titleError,
                      builder: (context, titleError) => TextFormField(
                        controller: _titleController,
                        forceErrorText: titleError,
                        onChanged: titleError == null
                            ? null
                            : (_) => _editNoticeBloc.add(
                                const EditNoticeFieldErrorCleared('title'),
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
                    BlocSelector<EditNoticeBloc, EditNoticeState, String?>(
                      selector: (state) => state.bodyError,
                      builder: (context, bodyError) => TextFormField(
                        controller: _bodyController,
                        forceErrorText: bodyError,
                        onChanged: bodyError == null
                            ? null
                            : (_) => _editNoticeBloc.add(
                                const EditNoticeFieldErrorCleared('body'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          helperText:
                              noticeBodyHasFormatting(widget.notice.body)
                              ? l10n.adminNoticeFormattingLost
                              : null,
                          helperMaxLines: 3,
                          labelText: l10n.adminCommunicationEditNoticeBody,
                          hintText: l10n.fieldEnter(
                            l10n.adminCommunicationEditNoticeBody,
                          ),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<EditNoticeBloc, EditNoticeState>(
                      buildWhen: (prev, curr) =>
                          prev.priorityOptions != curr.priorityOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.priorityError != curr.priorityError,
                      builder: (context, state) => DropdownButtonFormField<String>(
                        initialValue: _priority,
                        forceErrorText: state.priorityError,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.adminCommunicationEditNoticePriority} *',
                          hintText: state.loadingOptions
                              ? l10n.loading
                              : l10n.fieldSelect(
                                  l10n.adminCommunicationEditNoticePriority,
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
                                  _editNoticeBloc.add(
                                    const EditNoticeFieldErrorCleared(
                                      'priority',
                                    ),
                                  );
                                }
                              },
                        validator: (value) => value == null
                            ? l10n.fieldRequired(
                                l10n.adminCommunicationEditNoticePriority,
                              )
                            : null,
                      ),
                    ),
                    12.height,
                    BlocSelector<EditNoticeBloc, EditNoticeState, String?>(
                      selector: (state) => state.expiresOnError,
                      builder: (context, expiresOnError) => TextFormField(
                        controller: _expiresOnController,
                        forceErrorText: expiresOnError,
                        readOnly: true,
                        onTap: _pickExpiresOn,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .deleteButtonTooltip,
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _expiresOn = null;
                              _expiresOnController.clear();
                              if (_editNoticeBloc.state.expiresOnError !=
                                  null) {
                                _editNoticeBloc.add(
                                  const EditNoticeFieldErrorCleared(
                                    'expires_on',
                                  ),
                                );
                              }
                            },
                          ),
                          labelText: l10n.adminCommunicationEditNoticeExpiresOn,
                          hintText: l10n.fieldSelect(
                            l10n.adminCommunicationEditNoticeExpiresOn,
                          ),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditNoticeBloc, EditNoticeState, bool>(
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
