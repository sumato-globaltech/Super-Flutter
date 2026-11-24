import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/widgets/ai_chat.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/features/vistaar/presentation/vistaar/bloc/vistaar_bloc.dart';
import 'package:super_flutter/features/vistaar/presentation/vistaar/bloc/vistaar_event.dart';
import 'package:super_flutter/features/vistaar/presentation/vistaar/bloc/vistaar_state.dart';

class VistaarScreen extends StatelessWidget {
  const VistaarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VistaarBloc>()..add(const VistaarStarted()),
      child: const _VistaarView(),
    );
  }
}

class _VistaarView extends StatelessWidget {
  const _VistaarView();

  Future<void> _pickPhoto(BuildContext context, AppLocalizations l10n) async {
    final bloc = context.read<VistaarBloc>();
    final source = await ConfirmSheet.choose<ImageSource>(
      context,
      title: l10n.vistaarAddPhoto,
      actions: [
        SheetAction(
          value: ImageSource.camera,
          label: l10n.cropDetectorCamera,
          icon: PhosphorIconsRegular.camera,
        ),
        SheetAction(
          value: ImageSource.gallery,
          label: l10n.cropDetectorGallery,
          icon: PhosphorIconsRegular.images,
        ),
      ],
    );
    if (source == null) return;
    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (photo != null && !bloc.isClosed) {
        bloc.add(VistaarPhotoChosen(photo.path));
      }
    } on PlatformException {
      if (!context.mounted) return;
      context.showSnackBar(l10n.cropDetectorNoAccess, isError: true);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    AppLocalizations l10n,
    VistaarState state,
  ) async {
    final bloc = context.read<VistaarBloc>();
    final language = await ConfirmSheet.choose<String>(
      context,
      title: l10n.vistaarLanguage,
      actions: [
        for (final language in state.languages)
          if (language.value case final value?)
            SheetAction(
              value: value,
              label: language.label ?? value,
              selected: value == state.language,
            ),
      ],
    );
    if (language != null && !bloc.isClosed) {
      bloc.add(VistaarLanguageChosen(language));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bloc = context.read<VistaarBloc>();
    return BlocBuilder<VistaarBloc, VistaarState>(
      builder: (context, state) => AiChat(
        title: l10n.vistaarTitle,
        greeting: l10n.vistaarHello,
        intro: l10n.vistaarIntro,
        prompts: [l10n.vistaarPromptPest, l10n.vistaarPromptPrice],
        hint: l10n.vistaarHint,
        messages: state.messages,
        thinking: state.isThinking,
        failed: state.status == VistaarStatus.failure,
        errorMessage: state.errorMessage,
        emptyQuestion: state.photo == null ? null : l10n.vistaarPhotoQuestion,
        onAsk: (question) => bloc.add(VistaarAsked(question)),
        onRetry: () => bloc.add(const VistaarRetried()),
        onClear: () => bloc.add(const VistaarCleared()),
        leading: IconButton(
          tooltip: l10n.vistaarAddPhoto,
          onPressed: state.isThinking ? null : () => _pickPhoto(context, l10n),
          icon: const Icon(PhosphorIconsRegular.camera),
        ),
        tools: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (state.photo case final photo?)
                  InputChip(
                    avatar: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(photo),
                        width: 24,
                        height: 24,
                        cacheWidth: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(PhosphorIconsRegular.image, size: 18),
                      ),
                    ),
                    label: Text(l10n.vistaarPhoto),
                    deleteButtonTooltipMessage: l10n.vistaarRemovePhoto,
                    onDeleted: () => bloc.add(const VistaarPhotoChosen(null)),
                  ),
                if (state.languages.length > 1)
                  ActionChip(
                    avatar: const Icon(
                      PhosphorIconsRegular.translate,
                      size: 18,
                    ),
                    tooltip: l10n.vistaarLanguage,
                    label: Text(
                      state.languages
                              .where((item) => item.value == state.language)
                              .firstOrNull
                              ?.label ??
                          state.language,
                    ),
                    onPressed: () => _pickLanguage(context, l10n, state),
                  ),
                FilterChip(
                  avatar: Icon(
                    PhosphorIconsRegular.mapPin,
                    size: 18,
                    color: state.useLocation
                        ? scheme.onPrimary
                        : scheme.onSurface,
                  ),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    color: state.useLocation
                        ? scheme.onPrimary
                        : scheme.onSurface,
                  ),
                  selectedColor: scheme.primary,
                  showCheckmark: false,
                  tooltip: l10n.vistaarNearMeHelp,
                  label: Text(l10n.vistaarNearMe),
                  selected: state.useLocation,
                  onSelected: (selected) =>
                      bloc.add(VistaarLocationToggled(useLocation: selected)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
