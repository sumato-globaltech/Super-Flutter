import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_photo_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';
import 'package:super_flutter/features/farm/routes/farms_route_names.dart';

import '../bloc/farm_detail_bloc.dart';
import '../bloc/farm_detail_event.dart';
import '../bloc/farm_detail_state.dart';

class FarmDetailScreen extends StatelessWidget {
  final String farmId;

  const FarmDetailScreen({super.key, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FarmDetailBloc>()..add(FarmDetailStarted(farmId)),
      child: const _FarmDetailView(),
    );
  }
}

class _FarmDetailView extends StatelessWidget {
  const _FarmDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<FarmDetailBloc, FarmDetailState>(
      listenWhen: (prev, curr) =>
          prev.isDeleted != curr.isDeleted ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.farmDeleted)),
          );
          context.pop();
        } else if (state.errorMessage != null &&
            state.status == FarmDetailStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final farm = state.farm;
        final bloc = context.read<FarmDetailBloc>();

        return Scaffold(
          appBar: AppTopBar(
            title: farm?.name ?? l10n.farmDetails,
            actions: [
              if (farm != null) ...[
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
                  onPressed: () async {
                    final updated = await context.push<bool>(
                      FarmsRouteNames.editFarmFor(farm.id!),
                      extra: farm,
                    );
                    if (updated == true && context.mounted) {
                      bloc.add(const FarmDetailRefreshed());
                    }
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'archive') {
                      bloc.add(const FarmArchiveToggled());
                    } else if (val == 'delete') {
                      _showDeleteDialog(context, bloc, l10n);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(
                            farm.isActive
                                ? PhosphorIconsRegular.archive
                                : PhosphorIconsRegular.arrowCounterClockwise,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(farm.isActive ? l10n.archive : l10n.unarchive),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.trash,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.delete,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          body: switch (state.status) {
            FarmDetailStatus.initial || FarmDetailStatus.loading =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: DesignProgress(),
                ),
              ),
            FarmDetailStatus.failure => AppErrorView(
                message: state.errorMessage ?? l10n.errorUnknown,
                retryLabel: l10n.tryAgain,
                onRetry: () => bloc.add(FarmDetailStarted(state.farmId)),
              ),
            FarmDetailStatus.success => RefreshIndicator(
                onRefresh: () async {
                  bloc.add(const FarmDetailRefreshed());
                },
                child: DefaultTabController(
                  length: 3,
                  initialIndex: state.selectedTab,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: _FarmOverviewCard(farm: farm!),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _FarmTabBarDelegate(
                          TabBar(
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            indicatorColor: theme.colorScheme.primary,
                            tabs: [
                              Tab(
                                text: '${l10n.crops} (${state.crops.length})',
                              ),
                              Tab(
                                text:
                                    '${l10n.transactions} (${state.transactions.length})',
                              ),
                              Tab(
                                text:
                                    '${l10n.photos} (${state.photos.length})',
                              ),
                            ],
                            onTap: (index) {
                              bloc.add(FarmDetailTabChanged(index));
                            },
                          ),
                          theme.colorScheme.surface,
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        _FarmCropsTab(
                          crops: state.crops,
                          onAdd: () => _showAddCropDialog(context, bloc, l10n),
                          onDelete: (cropId) =>
                              bloc.add(FarmCropDeleted(cropId)),
                        ),
                        _FarmTransactionsTab(
                          transactions: state.transactions,
                          summary: state.summary,
                          onAdd: () =>
                              _showAddTransactionDialog(context, bloc, l10n),
                        ),
                        _FarmPhotosTab(
                          photos: state.photos,
                          onDelete: (photoId) =>
                              bloc.add(FarmPhotoDeleted(photoId)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          },
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFarmConfirmTitle),
        content: Text(l10n.deleteFarmConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(const FarmDeleted());
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showAddCropDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    final nameCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    String season = 'kharif';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.addCrop),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.cropName,
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: areaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.areaHectares,
                  suffixText: 'ha',
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: season,
                decoration: InputDecoration(
                  labelText: l10n.season,
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'kharif', child: Text('Kharif')),
                  DropdownMenuItem(value: 'rabi', child: Text('Rabi')),
                  DropdownMenuItem(value: 'zaid', child: Text('Zaid')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => season = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                bloc.add(
                  FarmCropAdded({
                    'crop_id': nameCtrl.text.trim(),
                    'season': season,
                    'area_ha': double.tryParse(areaCtrl.text.trim()) ?? 1.0,
                    'status': 'planned',
                  }),
                );
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'expense';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.addTransaction),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Income')),
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() => type = s.first),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixText: '₹ ',
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text.trim());
                if (amount == null || amount <= 0) return;
                Navigator.pop(ctx);
                bloc.add(
                  FarmTransactionAdded({
                    'type': type,
                    'amount': amount,
                    'occurred_on': DateTime.now().toIso8601String().substring(0, 10),
                    'description': descCtrl.text.trim(),
                  }),
                );
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _FarmTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_FarmTabBarDelegate oldDelegate) => false;
}

class _FarmOverviewCard extends StatelessWidget {
  final FarmModel farm;

  const _FarmOverviewCard({required this.farm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: DesignColor.accentPoints.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  PhosphorIconsRegular.plant,
                  color: DesignColor.accentPoints,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.name ?? '-',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (farm.code != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        farm.code!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: farm.isActive
                      ? DesignColor.accentPoints.withValues(alpha: 0.15)
                      : DesignColor.golden.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  farm.isActive ? l10n.active : l10n.archived,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: farm.isActive
                        ? DesignColor.accentPoints
                        : DesignColor.golden,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (farm.areaHa != null)
                Chip(
                  label: Text('${farm.areaHa} ha'),
                  avatar: const Icon(PhosphorIconsRegular.compass, size: 14),
                ),
              if (farm.district?.name != null)
                Chip(
                  label: Text(farm.district!.name!),
                  avatar: const Icon(PhosphorIconsRegular.mapPin, size: 14),
                ),
              if (farm.soilType?.label != null)
                Chip(
                  label: Text(farm.soilType!.label!),
                  avatar: const Icon(PhosphorIconsRegular.mountains, size: 14),
                ),
              if (farm.irrigationType?.label != null)
                Chip(
                  label: Text(farm.irrigationType!.label!),
                  avatar: const Icon(PhosphorIconsRegular.drop, size: 14),
                ),
            ],
          ),
          if (farm.address != null || farm.village != null) ...[
            const SizedBox(height: AppSpacing.xs),
            TitleDetailsCard(
              title: l10n.location,
              text: [
                if (farm.village != null) farm.village,
                if (farm.address != null) farm.address,
              ].join(', '),
              isFirstItem: true,
              iconData: PhosphorIconsRegular.mapTrifold,
              accentColor: DesignColor.accentLocation,
            ),
          ],
        ],
      ),
    );
  }
}

class _FarmCropsTab extends StatelessWidget {
  final List<FarmCropModel> crops;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  const _FarmCropsTab({
    required this.crops,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (crops.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppEmptyView(
              title: l10n.noCropsOnFarm,
              message: l10n.addCropPrompt,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              icon: const Icon(PhosphorIconsRegular.plus),
              label: Text(l10n.addCrop),
              onPressed: onAdd,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: onAdd,
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: crops.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final crop = crops[index];
          final cropName = crop.crop?.name ?? '-';

          return DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cropName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (crop.id != null)
                      IconButton(
                        icon: const Icon(
                          PhosphorIconsRegular.trash,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () => onDelete(crop.id!),
                      ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (crop.season?.label != null)
                      Chip(
                        label: Text(crop.season!.label!),
                        avatar: const Icon(PhosphorIconsRegular.calendar, size: 12),
                      ),
                    if (crop.status?.label != null)
                      Chip(
                        label: Text(crop.status!.label!),
                        avatar: const Icon(PhosphorIconsRegular.tag, size: 12),
                      ),
                    if (crop.areaHa != null)
                      Chip(
                        label: Text('${crop.areaHa} ha'),
                        avatar: const Icon(PhosphorIconsRegular.compass, size: 12),
                      ),
                  ],
                ),
                if (crop.sownOn != null)
                  TitleDetailsCard(
                    title: l10n.sownOn,
                    text: crop.sownOn!,
                    isFirstItem: true,
                    iconData: PhosphorIconsRegular.plant,
                    accentColor: DesignColor.accentPoints,
                  ),
                if (crop.expectedHarvestOn != null)
                  TitleDetailsCard(
                    title: l10n.expectedHarvest,
                    text: crop.expectedHarvestOn!,
                    iconData: PhosphorIconsRegular.scissors,
                    accentColor: DesignColor.golden,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FarmTransactionsTab extends StatelessWidget {
  final List<FarmTransactionModel> transactions;
  final FarmTransactionSummaryModel? summary;
  final VoidCallback onAdd;

  const _FarmTransactionsTab({
    required this.transactions,
    required this.summary,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = summary?.totals;

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: onAdd,
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (totals != null) ...[
            Row(
              children: [
                Expanded(
                  child: DesignCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.income,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totals.income.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: DesignCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.expense,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totals.expense.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: DesignCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.netProfit,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totals.net.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: totals.net >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: AppEmptyView(
                title: l10n.noTransactionsFound,
                message: l10n.addTransactionPrompt,
              ),
            )
          else
            ...transactions.map(
              (tx) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: DesignCard(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (tx.isIncome ? Colors.green : Colors.red)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          tx.isIncome
                              ? PhosphorIconsRegular.arrowDownLeft
                              : PhosphorIconsRegular.arrowUpRight,
                          color: tx.isIncome ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.category?.name ??
                                  (tx.isIncome ? 'Income' : 'Expense'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (tx.occurredOn != null)
                              Text(
                                tx.occurredOn!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (tx.description != null &&
                                tx.description!.isNotEmpty)
                              Text(
                                tx.description!,
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${tx.isIncome ? '+' : '-'} ₹${tx.amount?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tx.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FarmPhotosTab extends StatelessWidget {
  final List<FarmPhotoModel> photos;
  final ValueChanged<String> onDelete;

  const _FarmPhotosTab({
    required this.photos,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (photos.isEmpty) {
      return Center(
        child: AppEmptyView(
          title: l10n.noPhotosFound,
          message: l10n.noPhotosSubtitle,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: photo.url != null
                  ? Image.network(
                      photo.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(PhosphorIconsRegular.imageBroken),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(PhosphorIconsRegular.image),
                    ),
            ),
            if (photo.id != null)
              Positioned(
                top: 6,
                right: 6,
                child: IconButton.filled(
                  icon: const Icon(PhosphorIconsRegular.trash, size: 14),
                  onPressed: () => onDelete(photo.id!),
                ),
              ),
          ],
        );
      },
    );
  }
}
