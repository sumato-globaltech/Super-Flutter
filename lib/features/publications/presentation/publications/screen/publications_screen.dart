import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_network_image.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/publications/presentation/publications/bloc/publications_bloc.dart';
import 'package:super_flutter/features/publications/presentation/publications/bloc/publications_event.dart';
import 'package:super_flutter/features/publications/presentation/publications/bloc/publications_state.dart';

class PublicationsScreen extends StatelessWidget {
  const PublicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PublicationsBloc>()..add(const PublicationsStarted()),
      child: const _PublicationsView(),
    );
  }
}

class _PublicationsView extends StatelessWidget {
  const _PublicationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.publicationsTitle),
      body: SafeArea(
        child: BlocConsumer<PublicationsBloc, PublicationsState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == PublicationsStatus.failure &&
              curr.publications != null,
          listener: (context, state) => context.showSnackBar(
            state.errorMessage ?? l10n.errorUnknown,
            isError: true,
          ),
          builder: (context, state) {
            final publications = state.publications;
            if (publications == null) {
              if (state.status == PublicationsStatus.failure) {
                return AppErrorView(
                  message: state.errorMessage ?? l10n.errorUnknown,
                  retryLabel: l10n.tryAgain,
                  onRetry: () => context.read<PublicationsBloc>().add(
                    const PublicationsStarted(),
                  ),
                );
              }
              return const Center(child: DesignProgress());
            }
            // The next page, unless one is loading or the last one failed.
            // The bloc's own state is read: several asks can come in a frame.
            void loadMore() {
              final bloc = context.read<PublicationsBloc>();
              final now = bloc.state;
              if ((now.publications?.hasMore ?? false) &&
                  !now.loadingMore &&
                  now.status == PublicationsStatus.success) {
                bloc.add(const PublicationsMoreRequested());
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<PublicationsBloc>()
                  ..add(const PublicationsStarted());
                await bloc.stream.firstWhere(
                  (state) => state.status != PublicationsStatus.loading,
                );
              },
              child: publications.items.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyView(
                            title: l10n.publicationsEmpty,
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
                            metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                          loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                        itemCount:
                            publications.items.length +
                            (publications.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == publications.items.length) {
                            final failed =
                                state.status == PublicationsStatus.failure &&
                                !state.loadingMore;
                            if (!failed) {
                              // A list too short to scroll asks once its end is in view.
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) loadMore();
                              });
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Center(
                                child: failed
                                    ? TextButton(
                                        onPressed: () => context
                                            .read<PublicationsBloc>()
                                            .add(
                                              const PublicationsMoreRequested(),
                                            ),
                                        child: Text(l10n.tryAgain),
                                      )
                                    : const DesignProgress(),
                              ),
                            );
                          }
                          final publication = publications.items[index];
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (publication.coverUrl
                                      case final cover?) ...[
                                    AppNetworkImage(
                                      url: cover,
                                      height: 140,
                                      width: double.infinity,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                  ],
                                  Text(
                                    publication.title ?? '--',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  for (final text in [
                                    ?publication.summary,
                                    ?publication.leftText,
                                    ?publication.rightText,
                                  ])
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        text,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  if (publication.pdfUrl case final pdf?)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            Utils.launchUrl2(url: pdf),
                                        icon: const Icon(
                                          PhosphorIconsRegular.filePdf,
                                        ),
                                        label: Text(l10n.publicationsOpen),
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
    );
  }
}
