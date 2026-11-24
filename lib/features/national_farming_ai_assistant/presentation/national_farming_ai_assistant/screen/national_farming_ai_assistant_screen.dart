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
import 'package:super_flutter/features/national_farming_ai_assistant/presentation/national_farming_ai_assistant/bloc/national_farming_ai_assistant_bloc.dart';
import 'package:super_flutter/features/national_farming_ai_assistant/presentation/national_farming_ai_assistant/bloc/national_farming_ai_assistant_event.dart';
import 'package:super_flutter/features/national_farming_ai_assistant/presentation/national_farming_ai_assistant/bloc/national_farming_ai_assistant_state.dart';

class NationalFarmingAiAssistantScreen extends StatelessWidget {
  const NationalFarmingAiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<NationalFarmingAiAssistantBloc>()
            ..add(const NationalFarmingAiAssistantStarted()),
      child: const _NationalFarmingAiAssistantView(),
    );
  }
}

class _NationalFarmingAiAssistantView extends StatelessWidget {
  const _NationalFarmingAiAssistantView();

  Future<void> _pickPhoto(BuildContext context, AppLocalizations l10n) async {
    final bloc = context.read<NationalFarmingAiAssistantBloc>();
    final source = await ConfirmSheet.choose<ImageSource>(
      context,
      title: l10n.nationalFarmingAiAssistantAddPhoto,
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
        bloc.add(NationalFarmingAiAssistantPhotoChosen(photo.path));
      }
    } on PlatformException {
      if (!context.mounted) return;
      context.showSnackBar(l10n.cropDetectorNoAccess, isError: true);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    AppLocalizations l10n,
    NationalFarmingAiAssistantState state,
  ) async {
    final bloc = context.read<NationalFarmingAiAssistantBloc>();
    final language = await ConfirmSheet.choose<String>(
      context,
      title: l10n.nationalFarmingAiAssistantLanguage,
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
      bloc.add(NationalFarmingAiAssistantLanguageChosen(language));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bloc = context.read<NationalFarmingAiAssistantBloc>();
    return BlocBuilder<
      NationalFarmingAiAssistantBloc,
      NationalFarmingAiAssistantState
    >(
      builder: (context, state) => AiChat(
        title: l10n.nationalFarmingAiAssistantTitle,
        greeting: l10n.nationalFarmingAiAssistantHello,
        intro: l10n.nationalFarmingAiAssistantIntro,
        prompts: [
          l10n.nationalFarmingAiAssistantPromptPest,
          l10n.nationalFarmingAiAssistantPromptPrice,
        ],
        hint: l10n.nationalFarmingAiAssistantHint,
        messages: state.messages,
        thinking: state.isThinking,
        failed: state.status == NationalFarmingAiAssistantStatus.failure,
        errorMessage: state.errorMessage,
        emptyQuestion: state.photo == null
            ? null
            : l10n.nationalFarmingAiAssistantPhotoQuestion,
        onAsk: (question) =>
            bloc.add(NationalFarmingAiAssistantAsked(question)),
        onRetry: () => bloc.add(const NationalFarmingAiAssistantRetried()),
        onClear: () => bloc.add(const NationalFarmingAiAssistantCleared()),
        leading: IconButton(
          tooltip: l10n.nationalFarmingAiAssistantAddPhoto,
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
                    label: Text(l10n.nationalFarmingAiAssistantPhoto),
                    deleteButtonTooltipMessage:
                        l10n.nationalFarmingAiAssistantRemovePhoto,
                    onDeleted: () => bloc.add(
                      const NationalFarmingAiAssistantPhotoChosen(null),
                    ),
                  ),
                if (state.languages.length > 1)
                  ActionChip(
                    avatar: const Icon(
                      PhosphorIconsRegular.translate,
                      size: 14,
                    ),
                    labelStyle: theme.textTheme.labelMedium,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    labelPadding: const EdgeInsets.only(left: 4, right: 2),
                    avatarBoxConstraints: const BoxConstraints.tightFor(
                      width: 14,
                      height: 14,
                    ),
                    tooltip: l10n.nationalFarmingAiAssistantLanguage,
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
                    size: 14,
                    color: state.useLocation
                        ? scheme.onPrimary
                        : scheme.onSurface,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  labelPadding: const EdgeInsets.only(left: 4, right: 2),
                  avatarBoxConstraints: const BoxConstraints.tightFor(
                    width: 14,
                    height: 14,
                  ),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: state.useLocation
                        ? scheme.onPrimary
                        : scheme.onSurface,
                  ),
                  selectedColor: scheme.primary,
                  showCheckmark: false,
                  tooltip: l10n.nationalFarmingAiAssistantNearMeHelp,
                  label: Text(l10n.nationalFarmingAiAssistantNearMe),
                  selected: state.useLocation,
                  onSelected: (selected) => bloc.add(
                    NationalFarmingAiAssistantLocationToggled(
                      useLocation: selected,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
