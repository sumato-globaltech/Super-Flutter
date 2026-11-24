import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/bloc/crop_detector_bloc.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/bloc/crop_detector_event.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/bloc/crop_detector_state.dart';

class CropDetectorScreen extends StatelessWidget {
  const CropDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CropDetectorBloc>(),
      child: const _CropDetectorView(),
    );
  }
}

class _CropDetectorView extends StatelessWidget {
  const _CropDetectorView();

  Future<void> _pick(
    BuildContext context,
    AppLocalizations l10n,
    ImageSource source,
  ) async {
    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (photo == null || !context.mounted) return;
      context.read<CropDetectorBloc>().add(
        CropPhotoChosen(
          path: photo.path,
          fromGallery: source == ImageSource.gallery,
        ),
      );
    } on PlatformException {
      if (!context.mounted) return;
      context.showSnackBar(l10n.cropDetectorNoAccess, isError: true);
    }
  }

  /// `too_far` reads as `Too far`.
  String _words(String? value) {
    final text = (value ?? '').replaceAll('_', ' ').trim();
    if (text.isEmpty) return '--';
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<CropDetectorBloc, CropDetectorState>(
      builder: (context, state) {
        final analysis = state.analysis;
        final diagnoses = analysis?.diagnoses ?? const [];
        return Scaffold(
          appBar: AppTopBar(title: l10n.cropDetectorTitle),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isAnalysing
                          ? null
                          : () => _pick(context, l10n, ImageSource.gallery),
                      icon: const Icon(PhosphorIconsRegular.images),
                      label: Text(l10n.cropDetectorGallery),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.isAnalysing
                          ? null
                          : () => _pick(context, l10n, ImageSource.camera),
                      icon: const Icon(PhosphorIconsRegular.camera),
                      label: Text(
                        state.photo == null
                            ? l10n.cropDetectorCamera
                            : l10n.cropDetectorAgain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            padding: AppSpacing.pagePadding,
            children: [
              if (state.photo case final photo?) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(photo),
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 8),
              ] else
                DesignCard(
                  title: l10n.cropDetectorGuide,
                  paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (index, (title, text, icon)) in [
                        (
                          l10n.cropDetectorGuideLight,
                          l10n.cropDetectorGuideLightText,
                          PhosphorIconsRegular.sun,
                        ),
                        (
                          l10n.cropDetectorGuideFocus,
                          l10n.cropDetectorGuideFocusText,
                          PhosphorIconsRegular.crosshair,
                        ),
                        (
                          l10n.cropDetectorGuidePrivacy,
                          l10n.cropDetectorGuidePrivacyText,
                          PhosphorIconsRegular.shieldCheck,
                        ),
                      ].indexed)
                        TitleDetailsCard(
                          title: title,
                          text: text,
                          isFirstItem: index == 0,
                          iconData: icon,
                          accentColor: DesignColor.accentPoints,
                        ),
                    ],
                  ),
                ),
              if (state.isAnalysing)
                DesignCard(
                  child: Row(
                    children: [
                      const DesignProgress(),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(l10n.cropDetectorAnalysing)),
                    ],
                  ),
                ),
              if (state.status == CropDetectorStatus.failure)
                DesignCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        state.errorMessage ?? l10n.errorUnknown,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton(
                        onPressed: () => context.read<CropDetectorBloc>().add(
                          CropPhotoChosen(
                            path: state.photo!,
                            fromGallery: state.fromGallery,
                          ),
                        ),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                ),
              if (analysis != null) ...[
                DesignCard(
                  title: l10n.cropDetectorResult,
                  paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TitleDetailsCard(
                        title: l10n.cropDetectorHealth,
                        text: _words(analysis.cropHealth),
                        isFirstItem: true,
                        iconData: PhosphorIconsRegular.heartbeat,
                        accentColor: DesignColor.accentPoints,
                      ),
                      if ((analysis.crops ?? const []).isNotEmpty)
                        TitleDetailsCard(
                          title: l10n.cropDetectorCrop,
                          text: analysis.crops!.map(_words).join(', '),
                          iconData: PhosphorIconsRegular.plant,
                          accentColor: DesignColor.accentName,
                        ),
                      if (analysis.focus != null || analysis.distance != null)
                        TitleDetailsCard(
                          title: l10n.cropDetectorPhoto,
                          text: [
                            if (analysis.focus case final focus?)
                              '${l10n.cropDetectorFocus}: ${_words(focus)}',
                            if (analysis.distance case final distance?)
                              '${l10n.cropDetectorDistance}: ${_words(distance)}',
                          ].join(' · '),
                          iconData: PhosphorIconsRegular.crosshair,
                          accentColor: DesignColor.accentType,
                        ),
                      if (analysis.notice case final notice?)
                        TitleDetailsCard(
                          title: l10n.cropDetectorNotice,
                          text: notice,
                          iconData: PhosphorIconsRegular.warning,
                          accentColor: DesignColor.accentEnergy,
                        ),
                    ],
                  ),
                ),
                if (diagnoses.isEmpty) ...[
                  const SizedBox(height: 8),
                  DesignCard(child: Text(l10n.cropDetectorNoDiagnosis)),
                ],
                for (final diagnosis in diagnoses) ...[
                  const SizedBox(height: 8),
                  DesignCard(
                    title: diagnosis.name ?? l10n.cropDetectorUnknown,
                    paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TitleDetailsCard(
                          title: l10n.cropDetectorLikelihood,
                          text: [
                            _words(diagnosis.likelihood),
                            ?diagnosis.scientificName,
                          ].join(' · '),
                          isFirstItem: true,
                          iconData: PhosphorIconsRegular.bug,
                          accentColor: DesignColor.accentEnergy,
                        ),
                        if ((diagnosis.images ?? const []).isNotEmpty)
                          TitleDetailsCard(
                            title: l10n.cropDetectorSimilar,
                            imagePreviewUrls: diagnosis.images,
                          ),
                        for (final (title, text, icon) in [
                          (
                            l10n.cropDetectorSigns,
                            (diagnosis.signs ?? const []).join('\n'),
                            PhosphorIconsRegular.eye,
                          ),
                          (
                            l10n.cropDetectorDescription,
                            diagnosis.description ?? '',
                            PhosphorIconsRegular.textAlignLeft,
                          ),
                          (
                            l10n.cropDetectorPrevention,
                            [
                              for (final step
                                  in diagnosis.prevention ?? const <String>[])
                                '• $step',
                            ].join('\n'),
                            PhosphorIconsRegular.shieldCheck,
                          ),
                          (
                            l10n.cropDetectorOrganic,
                            diagnosis.organicTreatment ?? '',
                            PhosphorIconsRegular.leaf,
                          ),
                          (
                            l10n.cropDetectorChemical,
                            diagnosis.chemicalTreatment ?? '',
                            PhosphorIconsRegular.flask,
                          ),
                        ])
                          if (text.isNotEmpty)
                            TitleDetailsCard(
                              title: title,
                              text: text,
                              isReadMore: true,
                              iconData: icon,
                              accentColor: DesignColor.accentType,
                            ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.cropDetectorDisclaimer,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
