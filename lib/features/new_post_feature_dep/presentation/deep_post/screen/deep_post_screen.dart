import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/new_post_feature_dep/presentation/deep_post/bloc/deep_post_bloc.dart';
import 'package:super_flutter/features/new_post_feature_dep/presentation/deep_post/bloc/deep_post_event.dart';
import 'package:super_flutter/features/new_post_feature_dep/presentation/deep_post/bloc/deep_post_state.dart';

class DeepPostScreen extends StatelessWidget {
  const DeepPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeepPostBloc>()..add(const DeepPostStarted()),
      child: const _DeepPostView(),
    );
  }
}

class _DeepPostView extends StatefulWidget {
  const _DeepPostView();

  @override
  State<_DeepPostView> createState() => _DeepPostViewState();
}

class _DeepPostViewState extends State<_DeepPostView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _districtId;
  late final DeepPostBloc _deepPostBloc;

  @override
  void initState() {
    super.initState();
    _deepPostBloc = context.read<DeepPostBloc>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Empty text is sent as null, so an optional field left blank is not sent.
  String? _orNull(String text) => text.isEmpty ? null : text;

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _deepPostBloc.add(
      DeepPostSubmitted(
        name: _orNull(_nameController.text.trim()),
        districtId: _districtId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeepPostBloc, DeepPostState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case DeepPostStatus.success:
            Utils.flutterToast('Deep Post created.');
            Navigator.pop(context, true);
          case DeepPostStatus.failure:
            final message = state.errorMessage;
            if (state.fieldErrors.isEmpty && message != null) {
              context.showSnackBar(message, isError: true);
            }
          case DeepPostStatus.initial || DeepPostStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('DeepTitle')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  BlocSelector<DeepPostBloc, DeepPostState, String?>(
                    selector: (state) => state.nameError,
                    builder: (context, nameError) => TextFormField(
                      controller: _nameController,
                      forceErrorText: nameError,
                      onChanged: nameError == null
                          ? null
                          : (_) => _deepPostBloc.add(
                              const DeepPostFieldErrorCleared('name'),
                            ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter Name',
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                  12.height,
                  BlocBuilder<DeepPostBloc, DeepPostState>(
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
                            labelText: 'District',
                            hintText: state.loadingOptions
                                ? 'Loading...'
                                : 'Select District',
                          ),
                          items: [
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
                                    _deepPostBloc.add(
                                      const DeepPostFieldErrorCleared(
                                        'district_id',
                                      ),
                                    );
                                  }
                                },
                        ),
                  ),
                  12.height,
                  BlocSelector<DeepPostBloc, DeepPostState, bool>(
                    selector: (state) => state.isSubmitting,
                    builder: (context, isSubmitting) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        child: isSubmitting
                            ? DesignProgress(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const Text('Submit'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
