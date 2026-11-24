import 'package:flutter/services.dart';
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
import 'package:super_flutter/data/profile/model/farmer_profile_model.dart'
    hide GenderModel, LandOwnershipModel, BlockModel;
import 'package:super_flutter/features/profile/presentation/edit_profile/bloc/edit_profile_bloc.dart';
import 'package:super_flutter/features/profile/presentation/edit_profile/bloc/edit_profile_event.dart';
import 'package:super_flutter/features/profile/presentation/edit_profile/bloc/edit_profile_state.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key, required this.profile});

  final FarmerProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditProfileBloc>()..add(const EditProfileStarted()),
      child: _EditProfileView(profile: profile),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView({required this.profile});

  final FarmerProfileModel profile;

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landAreaHaController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _gender;
  DateTime? _dateOfBirth;
  String? _landOwnership;
  final Map<String, String> _blocks = {};
  final Set<String> _blockIds = {};
  late final EditProfileBloc _editProfileBloc;

  @override
  void initState() {
    super.initState();
    _editProfileBloc = context.read<EditProfileBloc>();
    final profile = widget.profile;
    _nameController.text = profile.name ?? '';
    _emailController.text = profile.email ?? '';
    _villageController.text = profile.village ?? '';
    _addressController.text = profile.address ?? '';
    _landAreaHaController.text = (profile.landAreaHa?.toString() ?? '')
        .replaceFirst(RegExp(r'\.0$'), '');
    _gender = profile.gender?.value;
    _landOwnership = profile.landOwnership?.value;
    if (DateTime.tryParse(profile.dateOfBirth ?? '') case final born?) {
      _dateOfBirth = born;
      _dateOfBirthController.text = DateFormat('dd MMM yyyy').format(born);
    }
    for (final block in profile.blocks ?? const <BlockModel2Model>[]) {
      if (block.id case final id?) _blocks[id] = block.name ?? id;
    }
    _blockIds.addAll(_blocks.keys);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _landAreaHaController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: l10n.fieldSelect(l10n.profileEditProfileDateOfBirth),
    );
    if (picked == null) return;
    _dateOfBirth = picked;
    _dateOfBirthController.text = DateFormat('dd MMM yyyy').format(picked);
    if (_editProfileBloc.state.dateOfBirthError != null) {
      _editProfileBloc.add(const EditProfileFieldErrorCleared('date_of_birth'));
    }
  }

  String? _orNull(String text) => text.isEmpty ? null : text;

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _editProfileBloc.add(
      EditProfileSubmitted(
        name: _nameController.text.trim(),
        email: _orNull(_emailController.text.trim()),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        village: _orNull(_villageController.text.trim()),
        address: _orNull(_addressController.text.trim()),
        landAreaHa: double.tryParse(_landAreaHaController.text.trim()),
        landOwnership: _landOwnership,
        blockIds: _blockIds.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<EditProfileBloc, EditProfileState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case EditProfileStatus.success:
            Utils.flutterToast(l10n.profileEditProfileDone);
            context.pop(true);
          case EditProfileStatus.failure:
            if (state.fieldErrors.isEmpty) {
              context.showSnackBar(
                state.errorMessage ?? l10n.errorUnknown,
                isError: true,
              );
            }
          case EditProfileStatus.initial || EditProfileStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        appBar: AppTopBar(title: l10n.profileEditProfileTitle),
        body: SingleChildScrollView(
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (widget.profile.isVerified ?? false) ...[
                      Text(
                        l10n.profileVerifyAgain,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      12.height,
                    ],
                    BlocSelector<EditProfileBloc, EditProfileState, String?>(
                      selector: (state) => state.nameError,
                      builder: (context, nameError) => TextFormField(
                        controller: _nameController,
                        forceErrorText: nameError,
                        onChanged: nameError == null
                            ? null
                            : (_) => _editProfileBloc.add(
                                const EditProfileFieldErrorCleared('name'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '${l10n.profileEditProfileName} *',
                          hintText: l10n.fieldEnter(
                            l10n.profileEditProfileName,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.fieldRequired(l10n.profileEditProfileName)
                            : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditProfileBloc, EditProfileState, String?>(
                      selector: (state) => state.emailError,
                      builder: (context, emailError) => TextFormField(
                        controller: _emailController,
                        forceErrorText: emailError,
                        onChanged: emailError == null
                            ? null
                            : (_) => _editProfileBloc.add(
                                const EditProfileFieldErrorCleared('email'),
                              ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: l10n.profileEditProfileEmail,
                          hintText: l10n.fieldEnter(
                            l10n.profileEditProfileEmail,
                          ),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? null
                            : Utils.validateEmail(v.trim()),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocBuilder<EditProfileBloc, EditProfileState>(
                      buildWhen: (prev, curr) =>
                          prev.genderOptions != curr.genderOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.genderError != curr.genderError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _gender,
                            forceErrorText: state.genderError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.profileEditProfileGender,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.profileEditProfileGender,
                                    ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                child: Text(l10n.profileNotSet),
                              ),
                              if ((
                                    widget.profile.gender?.value,
                                    widget.profile.gender?.label,
                                  )
                                  case (final id?, final name)
                                  when !state.genderOptions.any(
                                    (option) => option.id == id,
                                  ))
                                DropdownMenuItem(
                                  value: id,
                                  child: Text(name ?? id),
                                ),
                              for (final option in state.genderOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _gender = value;
                                    if (state.genderError != null) {
                                      _editProfileBloc.add(
                                        const EditProfileFieldErrorCleared(
                                          'gender',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocSelector<EditProfileBloc, EditProfileState, String?>(
                      selector: (state) => state.dateOfBirthError,
                      builder: (context, dateOfBirthError) => TextFormField(
                        controller: _dateOfBirthController,
                        forceErrorText: dateOfBirthError,
                        readOnly: true,
                        onTap: _pickDateOfBirth,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .deleteButtonTooltip,
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _dateOfBirth = null;
                              _dateOfBirthController.clear();
                            },
                          ),
                          labelText: l10n.profileEditProfileDateOfBirth,
                          hintText: l10n.fieldSelect(
                            l10n.profileEditProfileDateOfBirth,
                          ),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditProfileBloc, EditProfileState, String?>(
                      selector: (state) => state.villageError,
                      builder: (context, villageError) => TextFormField(
                        controller: _villageController,
                        forceErrorText: villageError,
                        onChanged: villageError == null
                            ? null
                            : (_) => _editProfileBloc.add(
                                const EditProfileFieldErrorCleared('village'),
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.profileEditProfileVillage,
                          hintText: l10n.fieldEnter(
                            l10n.profileEditProfileVillage,
                          ),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditProfileBloc, EditProfileState, String?>(
                      selector: (state) => state.addressError,
                      builder: (context, addressError) => TextFormField(
                        controller: _addressController,
                        forceErrorText: addressError,
                        onChanged: addressError == null
                            ? null
                            : (_) => _editProfileBloc.add(
                                const EditProfileFieldErrorCleared('address'),
                              ),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: l10n.profileEditProfileAddress,
                          hintText: l10n.fieldEnter(
                            l10n.profileEditProfileAddress,
                          ),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    12.height,
                    BlocSelector<EditProfileBloc, EditProfileState, String?>(
                      selector: (state) => state.landAreaHaError,
                      builder: (context, landAreaHaError) => TextFormField(
                        controller: _landAreaHaController,
                        forceErrorText: landAreaHaError,
                        onChanged: landAreaHaError == null
                            ? null
                            : (_) => _editProfileBloc.add(
                                const EditProfileFieldErrorCleared(
                                  'land_area_ha',
                                ),
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
                          labelText: l10n.profileEditProfileLandAreaHa,
                          hintText: l10n.fieldEnter(
                            l10n.profileEditProfileLandAreaHa,
                          ),
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
                    BlocBuilder<EditProfileBloc, EditProfileState>(
                      buildWhen: (prev, curr) =>
                          prev.landOwnershipOptions !=
                              curr.landOwnershipOptions ||
                          prev.loadingOptions != curr.loadingOptions ||
                          prev.landOwnershipError != curr.landOwnershipError,
                      builder: (context, state) =>
                          DropdownButtonFormField<String>(
                            initialValue: _landOwnership,
                            forceErrorText: state.landOwnershipError,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.profileEditProfileLandOwnership,
                              hintText: state.loadingOptions
                                  ? l10n.loading
                                  : l10n.fieldSelect(
                                      l10n.profileEditProfileLandOwnership,
                                    ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                child: Text(l10n.profileNotSet),
                              ),
                              if ((
                                    widget.profile.landOwnership?.value,
                                    widget.profile.landOwnership?.label,
                                  )
                                  case (final id?, final name)
                                  when !state.landOwnershipOptions.any(
                                    (option) => option.id == id,
                                  ))
                                DropdownMenuItem(
                                  value: id,
                                  child: Text(name ?? id),
                                ),
                              for (final option in state.landOwnershipOptions)
                                DropdownMenuItem(
                                  value: option.id,
                                  child: Text(option.name ?? ''),
                                ),
                            ],
                            onChanged: state.loadingOptions
                                ? null
                                : (value) {
                                    _landOwnership = value;
                                    if (state.landOwnershipError != null) {
                                      _editProfileBloc.add(
                                        const EditProfileFieldErrorCleared(
                                          'land_ownership',
                                        ),
                                      );
                                    }
                                  },
                          ),
                    ),
                    12.height,
                    BlocBuilder<EditProfileBloc, EditProfileState>(
                      buildWhen: (prev, curr) =>
                          prev.blockOptions != curr.blockOptions ||
                          prev.blockIdsError != curr.blockIdsError,
                      builder: (context, state) {
                        for (final block in state.blockOptions) {
                          if (block.id case final id?) {
                            _blocks[id] = block.name ?? id;
                          }
                        }
                        if (_blocks.isEmpty) return const SizedBox.shrink();
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.profileBlocks,
                            errorText: state.blockIdsError?.value,
                          ),
                          child: StatefulBuilder(
                            builder: (context, setChips) => Wrap(
                              spacing: 8,
                              children: [
                                for (final block in _blocks.entries)
                                  FilterChip(
                                    label: Text(block.value),
                                    selected: _blockIds.contains(block.key),
                                    onSelected: (selected) {
                                      setChips(
                                        () => selected
                                            ? _blockIds.add(block.key)
                                            : _blockIds.remove(block.key),
                                      );
                                      if (_editProfileBloc.state.blockIdsError
                                          case final error?) {
                                        _editProfileBloc.add(
                                          EditProfileFieldErrorCleared(
                                            error.key,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    12.height,
                    BlocSelector<EditProfileBloc, EditProfileState, bool>(
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
