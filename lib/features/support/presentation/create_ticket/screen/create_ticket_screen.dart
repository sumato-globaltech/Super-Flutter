import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/support/presentation/create_ticket/bloc/create_ticket_bloc.dart';
import 'package:super_flutter/features/support/presentation/create_ticket/bloc/create_ticket_event.dart';
import 'package:super_flutter/features/support/presentation/create_ticket/bloc/create_ticket_state.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CreateTicketBloc>()..add(const CreateTicketStarted()),
      child: const _CreateTicketView(),
    );
  }
}

class _CreateTicketView extends StatefulWidget {
  const _CreateTicketView();

  @override
  State<_CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<_CreateTicketView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  String? _categoryId;
  String? _cropId;
  String? _photo;
  late final CreateTicketBloc _createTicketBloc;

  @override
  void initState() {
    super.initState();
    _createTicketBloc = context.read<CreateTicketBloc>();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _questionController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    _photo = picked.path;
    _photoController.text = picked.name;
    if (_createTicketBloc.state.photoError != null) {
      _createTicketBloc.add(const CreateTicketFieldErrorCleared('photo'));
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _createTicketBloc.add(
      CreateTicketSubmitted(
        categoryId: _categoryId!,
        subject: _subjectController.text.trim(),
        question: _questionController.text.trim(),
        cropId: _cropId,
        photo: _photo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<CreateTicketBloc, CreateTicketState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case CreateTicketStatus.success:
            Utils.flutterToast(l10n.supportCreateTicketDone);
            context.pop(true);
          case CreateTicketStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case CreateTicketStatus.initial || CreateTicketStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.supportCreateTicketTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BlocBuilder<CreateTicketBloc, CreateTicketState>(
                      buildWhen: (prev, curr) =>
                          prev.categoryOptions != curr.categoryOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.categoryIdError != curr.categoryIdError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _categoryId,
                            forceErrorText: state.categoryIdError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText:
                                  '${l10n.supportCreateTicketCategoryId} *',
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.supportCreateTicketCategoryId,
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
                                      _createTicketBloc.add(
                                        const CreateTicketFieldErrorCleared(
                                          'category_id',
                                        ),
                                      );
                                    }
                                  },
                            validator: (value) => value == null
                                ? l10n.fieldRequired(
                                    l10n.supportCreateTicketCategoryId,
                                  )
                                : null,
                          ),
                    ),
                    12.height,
                    BlocSelector<CreateTicketBloc, CreateTicketState, String?>(
                      selector: (state) => state.subjectError,
                      builder: (context, subjectError) => TextFormField(
                        controller: _subjectController,
                        forceErrorText: subjectError,
                        onChanged: subjectError == null
                            ? null
                            : (_) => _createTicketBloc.add(
                                const CreateTicketFieldErrorCleared('subject'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '${l10n.supportCreateTicketSubject} *',
                          hintText: l10n.fieldEnter(
                            l10n.supportCreateTicketSubject,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(
                                l10n.supportCreateTicketSubject,
                              )
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<CreateTicketBloc, CreateTicketState, String?>(
                      selector: (state) => state.questionError,
                      builder: (context, questionError) => TextFormField(
                        controller: _questionController,
                        forceErrorText: questionError,
                        onChanged: questionError == null
                            ? null
                            : (_) => _createTicketBloc.add(
                                const CreateTicketFieldErrorCleared('question'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: '${l10n.supportCreateTicketQuestion} *',
                          hintText: l10n.fieldEnter(
                            l10n.supportCreateTicketQuestion,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(
                                l10n.supportCreateTicketQuestion,
                              )
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<CreateTicketBloc, CreateTicketState>(
                      buildWhen: (prev, curr) =>
                          prev.cropOptions != curr.cropOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.cropIdError != curr.cropIdError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _cropId,
                            forceErrorText: state.cropIdError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.supportCreateTicketCropId,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.supportCreateTicketCropId,
                                    ),
                            ),
                            items: [
                              for (final option in state.cropOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _cropId = value;
                                    if (state.cropIdError != null) {
                                      _createTicketBloc.add(
                                        const CreateTicketFieldErrorCleared(
                                          'crop_id',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<CreateTicketBloc, CreateTicketState, String?>(
                      selector: (state) => state.photoError,
                      builder: (context, photoError) => TextFormField(
                        controller: _photoController,
                        forceErrorText: photoError,
                        readOnly: true,
                        onTap: _pickPhoto,
                        decoration: InputDecoration(
                          labelText: l10n.supportCreateTicketPhoto,
                          hintText: l10n.fieldChoose(
                            l10n.supportCreateTicketPhoto,
                          ),
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                    ),
                    12.height,
                    BlocSelector<CreateTicketBloc, CreateTicketState, bool>(
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
