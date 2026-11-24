import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/meetings/presentation/meetings/bloc/meetings_bloc.dart';
import 'package:super_flutter/features/meetings/presentation/meetings/bloc/meetings_event.dart';
import 'package:super_flutter/features/meetings/presentation/meetings/bloc/meetings_state.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final access = context.read<AuthCubit>().state.access;
        return getIt<MeetingsBloc>()..add(
          MeetingsStarted(
            farmer: access.role == Roles.farmer && access.profileActive,
          ),
        );
      },
      child: const _MeetingsView(),
    );
  }
}

class _MeetingsView extends StatelessWidget {
  const _MeetingsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.meetingsTitle),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: AppSpacing.sm),
              child: BlocBuilder<MeetingsBloc, MeetingsState>(
                buildWhen: (prev, curr) =>
                    prev.districts != curr.districts ||
                    prev.district != curr.district,
                builder: (context, state) => DropdownButtonFormField<String>(
                  key: ValueKey((state.districts.length, state.district)),
                  initialValue: state.district,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.district,
                    prefixIcon: const Icon(PhosphorIconsRegular.mapPin),
                  ),
                  items: [
                    for (final district in state.districts)
                      DropdownMenuItem(
                        value: district.id,
                        child: Text(district.name ?? '--'),
                      ),
                  ],
                  onChanged: (district) => context.read<MeetingsBloc>().add(
                    MeetingsStarted(district: district),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<MeetingsBloc, MeetingsState>(
                listenWhen: (prev, curr) =>
                    prev.status != curr.status &&
                    curr.status == MeetingsStatus.failure &&
                    curr.meetings != null,
                listener: (context, state) => context.showSnackBar(
                  state.errorMessage ?? l10n.errorUnknown,
                  isError: true,
                ),
                builder: (context, state) {
                  final meetings = state.meetings;
                  if (meetings == null) {
                    if (state.status == MeetingsStatus.success) {
                      return AppEmptyView(
                        title: l10n.meetingsChoose,
                        icon: PhosphorIconsRegular.mapPin,
                      );
                    }
                    if (state.status == MeetingsStatus.failure) {
                      return AppErrorView(
                        message: state.errorMessage ?? l10n.errorUnknown,
                        retryLabel: l10n.tryAgain,
                        onRetry: () => context.read<MeetingsBloc>().add(
                          const MeetingsStarted(),
                        ),
                      );
                    }
                    return const Center(child: DesignProgress());
                  }
                  // The next page, unless one is loading or the last one failed.
                  // The bloc's own state is read: several asks can come in a frame.
                  void loadMore() {
                    final bloc = context.read<MeetingsBloc>();
                    final now = bloc.state;
                    if ((now.meetings?.hasMore ?? false) &&
                        !now.loadingMore &&
                        now.status == MeetingsStatus.success) {
                      bloc.add(const MeetingsMoreRequested());
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<MeetingsBloc>()
                        ..add(const MeetingsStarted());
                      await bloc.stream.firstWhere(
                        (state) => state.status != MeetingsStatus.loading,
                      );
                    },
                    child: meetings.items.isEmpty
                        ? CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: AppEmptyView(
                                  title: l10n.meetingsEmpty,
                                  icon: PhosphorIconsRegular.tray,
                                ),
                              ),
                            ],
                          )
                        : NotificationListener<ScrollUpdateNotification>(
                            // Past 80% of the list, the next page is asked for.
                            onNotification: (notification) {
                              final metrics = notification.metrics;
                              if (metrics.axis == Axis.vertical &&
                                  metrics.pixels >=
                                      metrics.maxScrollExtent * 0.8) {
                                loadMore();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: AppSpacing.pagePadding.copyWith(
                                bottom: 0,
                              ),
                              itemCount:
                                  meetings.items.length +
                                  (meetings.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == meetings.items.length) {
                                  final failed =
                                      state.status == MeetingsStatus.failure &&
                                      !state.loadingMore;
                                  if (!failed) {
                                    // A list too short to scroll asks once its end is in view.
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (context.mounted) loadMore();
                                        });
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Center(
                                      child: failed
                                          ? TextButton(
                                              onPressed: () => context
                                                  .read<MeetingsBloc>()
                                                  .add(
                                                    const MeetingsMoreRequested(),
                                                  ),
                                              child: Text(l10n.tryAgain),
                                            )
                                          : const DesignProgress(),
                                    ),
                                  );
                                }
                                final meeting = meetings.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: DesignCard(
                                    paddingChild: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      14,
                                      16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TitleDetailsCard(
                                          title: l10n.meetingsAgenda,
                                          text: meeting.agenda ?? '--',
                                          isFirstItem: true,
                                          iconData:
                                              PhosphorIconsRegular.notepad,
                                          accentColor: DesignColor.accentName,
                                          isReadMore: true,
                                        ),
                                        TitleDetailsCard(
                                          title: l10n.meetingsStartsAt,
                                          text: switch (meeting.startsAt) {
                                            final at? =>
                                              DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(at.toLocal()),
                                            null => '--',
                                          },
                                          iconData: PhosphorIconsRegular
                                              .calendarBlank,
                                          accentColor: DesignColor.accentType,
                                        ),
                                        TitleDetailsCard(
                                          title: l10n.meetingsStatus,
                                          text: [
                                            meeting.status?.label ?? '--',
                                            if (meeting.rescheduledFrom
                                                case final from?)
                                              l10n.meetingsRescheduled(
                                                DateFormat.yMMMd()
                                                    .add_jm()
                                                    .format(from.toLocal()),
                                              ),
                                          ].join(' · '),
                                          iconData: PhosphorIconsRegular.flag,
                                          accentColor: DesignColor.accentEnergy,
                                        ),
                                        if (meeting.link case final link?)
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () =>
                                                  Utils.launchUrl2(url: link),
                                              icon: const Icon(
                                                PhosphorIconsRegular
                                                    .videoCamera,
                                              ),
                                              label: Text(l10n.meetingsJoin),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
