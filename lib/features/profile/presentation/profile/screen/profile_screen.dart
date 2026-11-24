import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_network_image.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/auth/routes/auth_route_names.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:super_flutter/features/profile/presentation/profile/bloc/profile_event.dart';
import 'package:super_flutter/features/profile/presentation/profile/bloc/profile_state.dart';
import 'package:super_flutter/features/profile/routes/profile_route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final access = context.read<AuthCubit>().state.access;
    final farmer = access.role == Roles.farmer && access.profileActive;
    return BlocProvider(
      create: (_) {
        final bloc = getIt<ProfileBloc>();
        if (farmer) bloc.add(const ProfileStarted());
        return bloc;
      },
      child: _ProfileView(farmer: farmer),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.farmer});

  final bool farmer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        return Scaffold(
          appBar: AppTopBar(
            title: l10n.profileTitle,
            actions: [
              if (profile != null)
                IconButton(
                  tooltip: l10n.profileEditProfileTitle,
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
                  onPressed: () async {
                    final auth = context.read<AuthCubit>();
                    final saved = await context.push<bool>(
                      ProfileRouteNames.editProfile,
                      extra: profile,
                    );
                    if (saved != true) return;
                    if (context.mounted) {
                      context.read<ProfileBloc>().add(const ProfileStarted());
                    }
                    await auth.syncUser();
                  },
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthCubit>();
              if (farmer) {
                final bloc = context.read<ProfileBloc>()
                  ..add(const ProfileStarted());
                await bloc.stream.firstWhere(
                  (state) => state.status != ProfileStatus.loading,
                );
              }
              await auth.syncUser();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.pagePadding,
              children: [
                DesignCard(
                  title: l10n.profileAccount,
                  paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (user?.photoUrl case final photo?) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppNetworkImage(
                            url: photo,
                            width: 72,
                            height: 72,
                            borderRadius: BorderRadius.circular(36),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      for (final (index, (title, text, icon)) in [
                        (
                          l10n.profileEditProfileName,
                          user?.name,
                          PhosphorIconsRegular.user,
                        ),
                        (
                          l10n.profileRole,
                          [?user?.role?.label, ?user?.designation].join(' · '),
                          PhosphorIconsRegular.identificationBadge,
                        ),
                        (
                          l10n.profilePhone,
                          user?.phone,
                          PhosphorIconsRegular.phone,
                        ),
                        (
                          l10n.profileEditProfileEmail,
                          user?.email,
                          PhosphorIconsRegular.envelope,
                        ),
                      ].indexed)
                        TitleDetailsCard(
                          title: title,
                          text: text == null || text.isEmpty ? '--' : text,
                          isFirstItem: index == 0,
                          iconData: icon,
                          accentColor: DesignColor.accentName,
                        ),
                    ],
                  ),
                ),
                if (farmer) ...[
                  const SizedBox(height: 8),
                  DesignCard(
                    title: l10n.profileFarmer,
                    paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    child:
                        state.status == ProfileStatus.failure && profile == null
                        ? Column(
                            children: [
                              Text(state.errorMessage ?? l10n.errorUnknown),
                              TextButton(
                                onPressed: () => context
                                    .read<ProfileBloc>()
                                    .add(const ProfileStarted()),
                                child: Text(l10n.tryAgain),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final (index, (title, text, icon)) in [
                                (
                                  l10n.profileCode,
                                  profile?.code,
                                  PhosphorIconsRegular.barcode,
                                ),
                                (
                                  l10n.profileVerified,
                                  profile?.isVerified ?? false
                                      ? l10n.valueYes
                                      : l10n.valueNo,
                                  PhosphorIconsRegular.sealCheck,
                                ),
                                (
                                  l10n.profileEditProfileGender,
                                  profile?.gender?.label,
                                  PhosphorIconsRegular.genderIntersex,
                                ),
                                (
                                  l10n.profileEditProfileDateOfBirth,
                                  switch (DateTime.tryParse(
                                    profile?.dateOfBirth ?? '',
                                  )) {
                                    final born? => DateFormat.yMMMd().format(
                                      born,
                                    ),
                                    null => null,
                                  },
                                  PhosphorIconsRegular.cake,
                                ),
                                (
                                  l10n.profileDistricts,
                                  [
                                    for (final district
                                        in profile?.districts ?? const [])
                                      district.name ?? '--',
                                  ].join(', '),
                                  PhosphorIconsRegular.mapPin,
                                ),
                                (
                                  l10n.profileBlocks,
                                  [
                                    for (final block
                                        in profile?.blocks ?? const [])
                                      block.name ?? '--',
                                  ].join(', '),
                                  PhosphorIconsRegular.mapTrifold,
                                ),
                                (
                                  l10n.profileEditProfileVillage,
                                  profile?.village,
                                  PhosphorIconsRegular.houseLine,
                                ),
                                (
                                  l10n.profileEditProfileAddress,
                                  profile?.address,
                                  PhosphorIconsRegular.house,
                                ),
                                (
                                  l10n.profileEditProfileLandAreaHa,
                                  switch (profile?.landAreaHa) {
                                    final area? => NumberFormat(
                                      '#,##0.###',
                                    ).format(area),
                                    null => null,
                                  },
                                  PhosphorIconsRegular.ruler,
                                ),
                                (
                                  l10n.profileEditProfileLandOwnership,
                                  profile?.landOwnership?.label,
                                  PhosphorIconsRegular.certificate,
                                ),
                              ].indexed)
                                TitleDetailsCard(
                                  title: title,
                                  text: profile == null
                                      ? ''
                                      : text == null || text.isEmpty
                                      ? '--'
                                      : text,
                                  isTextLoading: profile == null,
                                  isFirstItem: index == 0,
                                  isReadMore: true,
                                  iconData: icon,
                                  accentColor: DesignColor.accentType,
                                ),
                            ],
                          ),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push(AuthRouteNames.changePassword),
                  icon: const Icon(PhosphorIconsRegular.lock),
                  label: Text(l10n.profileChangePassword),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
