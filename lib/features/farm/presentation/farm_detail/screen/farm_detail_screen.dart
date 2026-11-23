import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_photo_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/soil_sensor_account_model.dart';
import 'package:super_flutter/features/farm/routes/farm_route_names.dart';
import 'package:super_flutter/features/iot/routes/iot_route_names.dart';

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
          prev.errorMessage != curr.errorMessage ||
          prev.actionSuccessMessage != curr.actionSuccessMessage,
      listener: (context, state) {
        if (state.isDeleted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.farmDeleted)));
          context.pop();
        } else if (state.actionSuccessMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionSuccessMessage!)));
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
                      FarmRouteNames.editFarmFor(farm.id!),
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
            FarmDetailStatus.initial ||
            FarmDetailStatus.loading => const Center(
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
                length: 4,
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
                          unselectedLabelColor: theme
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                          indicatorColor: theme.colorScheme.primary,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: [
                            Tab(text: '${l10n.crops} (${state.crops.length})'),
                            Tab(
                              text:
                                  '${l10n.transactions} (${state.transactions.length})',
                            ),
                            Tab(
                              text: '${l10n.photos} (${state.photos.length})',
                            ),
                            Tab(
                              text: '${l10n.devices} (${state.devices.length})',
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
                        onDelete: (cropId) => bloc.add(FarmCropDeleted(cropId)),
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
                      _FarmDevicesTab(
                        devices: state.devices,
                        soilSensorAccount: state.soilSensorAccount,
                        isSyncing: state.isSyncingDevices,
                        onSync: () =>
                            bloc.add(const FarmDevicesSyncRequested()),
                        onLink: () =>
                            _showLinkSoilSensDialog(context, bloc, l10n),
                        onUnlink: () =>
                            _showUnlinkSoilSensDialog(context, bloc, l10n),
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

  void _showLinkSoilSensDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    final formKey = GlobalKey<FormState>();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: l10n.linkAccount,
        description: '',
        confirmText: l10n.linkAccount,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${l10n.soilSensUsername} *',
                  prefixIcon: const Icon(PhosphorIconsRegular.user),
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? l10n.fieldRequired(l10n.soilSensUsername)
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '${l10n.soilSensPassword} *',
                  prefixIcon: const Icon(PhosphorIconsRegular.lock),
                ),
                validator: (value) => (value ?? '').isEmpty
                    ? l10n.fieldRequired(l10n.soilSensPassword)
                    : null,
              ),
            ],
          ),
        ),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          final completer = Completer<void>();
          bloc.add(
            FarmSoilSensorAccountLinked(
              username: usernameCtrl.text.trim(),
              password: passwordCtrl.text,
              completer: completer,
            ),
          );
          await completer.future;
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showUnlinkSoilSensDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    ConfirmSheet.confirm(
      context,
      title: l10n.unlinkConfirmTitle,
      description: l10n.unlinkConfirmMessage,
      confirmText: l10n.unlinkAccount,
      confirmColor: Theme.of(context).colorScheme.error,
      onConfirm: () async => bloc.add(const FarmSoilSensorAccountUnlinked()),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    ConfirmSheet.confirm(
      context,
      title: l10n.deleteFarmConfirmTitle,
      description: l10n.deleteFarmConfirmMessage,
      confirmText: l10n.delete,
      confirmColor: Theme.of(context).colorScheme.error,
      onConfirm: () async => bloc.add(const FarmDeleted()),
    );
  }

  void _showAddCropDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    final formKey = GlobalKey<FormState>();
    final areaCtrl = TextEditingController();
    final sownOnCtrl = TextEditingController();
    final state = bloc.state;
    final farmArea = state.farm?.areaHa;
    final localizations = MaterialLocalizations.of(context);
    String? cropId;
    String? season;
    String? status;
    DateTime? sownOn;

    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: l10n.addCrop,
        description: '',
        confirmText: l10n.add,
        child: StatefulBuilder(
          builder: (ctx, setState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: cropId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.farmCropCrop} *',
                    hintText: l10n.fieldSelect(l10n.farmCropCrop),
                    prefixIcon: const Icon(PhosphorIconsRegular.plant),
                  ),
                  items: [
                    for (final crop in state.cropOptions)
                      DropdownMenuItem(
                        value: crop.id,
                        child: Text(crop.name ?? ''),
                      ),
                  ],
                  onChanged: (value) => setState(() => cropId = value),
                  validator: (value) => value == null
                      ? l10n.fieldRequired(l10n.farmCropCrop)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: season,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.season} *',
                    hintText: l10n.fieldSelect(l10n.season),
                    prefixIcon: const Icon(PhosphorIconsRegular.sun),
                  ),
                  items: [
                    for (final option in state.seasons)
                      DropdownMenuItem(
                        value: option.id,
                        child: Text(option.name ?? ''),
                      ),
                  ],
                  onChanged: (value) => setState(() => season = value),
                  validator: (value) =>
                      value == null ? l10n.fieldRequired(l10n.season) : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.farmCropStatus} *',
                    hintText: l10n.fieldSelect(l10n.farmCropStatus),
                    prefixIcon: const Icon(PhosphorIconsRegular.flag),
                  ),
                  items: [
                    for (final option in state.cropStatuses)
                      DropdownMenuItem(
                        value: option.id,
                        child: Text(option.name ?? ''),
                      ),
                  ],
                  onChanged: (value) => setState(() => status = value),
                  validator: (value) => value == null
                      ? l10n.fieldRequired(l10n.farmCropStatus)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: areaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.areaHectares,
                    suffixText: 'ha',
                    prefixIcon: const Icon(PhosphorIconsRegular.compass),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return null;
                    final area = double.tryParse(text);
                    if (area == null ||
                        area <= 0 ||
                        (farmArea != null && area > farmArea)) {
                      return l10n.invalidArea;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: sownOnCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: status != null && status != 'planned'
                        ? '${l10n.farmCropSownOn} *'
                        : l10n.farmCropSownOn,
                    hintText: l10n.fieldSelect(l10n.farmCropSownOn),
                    prefixIcon: const Icon(PhosphorIconsRegular.calendarBlank),
                  ),
                  validator: (_) =>
                      status != null && status != 'planned' && sownOn == null
                      ? l10n.fieldRequired(l10n.farmCropSownOn)
                      : null,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: sownOn ?? now,
                      firstDate: DateTime(2000, 1, 2),
                      lastDate: status == null || status == 'planned'
                          ? DateTime(now.year + 2)
                          : now,
                      helpText: l10n.fieldSelect(l10n.farmCropSownOn),
                    );
                    if (picked == null) return;
                    setState(() {
                      sownOn = picked;
                      sownOnCtrl.text = localizations.formatMediumDate(picked);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          final completer = Completer<void>();
          final area = double.tryParse(areaCtrl.text.trim());
          bloc.add(
            FarmCropAdded({
              'crop_id': cropId,
              'season': season,
              'status': status,
              'financial_year_id': ?state.currentFinancialYear?.id,
              'area_ha': ?area,
              if (sownOn != null)
                'sown_on': sownOn!.toIso8601String().substring(0, 10),
            }, completer: completer),
          );
          await completer.future;
          if (context.mounted) {
            Navigator.of(context).pop();
            context.showSnackBar(l10n.farmCropAdded);
          }
        },
      ),
    );
  }

  void _showAddTransactionDialog(
    BuildContext context,
    FarmDetailBloc bloc,
    AppLocalizations l10n,
  ) {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    String type = 'expense';
    String? categoryId;
    DateTime occurredOn = DateTime.now();
    final categories = bloc.state.transactionCategories;
    final localizations = MaterialLocalizations.of(context);
    dateCtrl.text = localizations.formatMediumDate(occurredOn);

    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: l10n.addTransaction,
        description: '',
        confirmText: l10n.add,
        child: StatefulBuilder(
          builder: (ctx, setState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'income', label: Text(l10n.income)),
                    ButtonSegment(value: 'expense', label: Text(l10n.expense)),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setState(() => type = s.first),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '${l10n.transactionAmount} *',
                    prefixIcon: const Icon(PhosphorIconsRegular.currencyInr),
                  ),
                  validator: (value) {
                    final amount = double.tryParse((value ?? '').trim());
                    return amount == null || amount <= 0
                        ? l10n.transactionInvalidAmount
                        : null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: categoryId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.transactionCategory} *',
                    hintText: l10n.fieldSelect(l10n.transactionCategory),
                    prefixIcon: const Icon(PhosphorIconsRegular.tag),
                  ),
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name ?? ''),
                      ),
                  ],
                  onChanged: (value) => setState(() => categoryId = value),
                  validator: (value) => value == null
                      ? l10n.fieldRequired(l10n.transactionCategory)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: dateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.transactionDate} *',
                    prefixIcon: const Icon(PhosphorIconsRegular.calendarBlank),
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: occurredOn,
                      firstDate: DateTime(2000, 1, 2),
                      lastDate: now,
                      helpText: l10n.fieldSelect(l10n.transactionDate),
                    );
                    if (picked == null) return;
                    setState(() {
                      occurredOn = picked;
                      dateCtrl.text = localizations.formatMediumDate(picked);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: descCtrl,
                  maxLength: 255,
                  decoration: InputDecoration(
                    labelText: l10n.transactionDescription,
                    prefixIcon: const Icon(PhosphorIconsRegular.notePencil),
                  ),
                ),
              ],
            ),
          ),
        ),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          final completer = Completer<void>();
          final description = descCtrl.text.trim();
          bloc.add(
            FarmTransactionAdded({
              'type': type,
              'amount': double.parse(amountCtrl.text.trim()),
              'category_id': categoryId,
              'occurred_on': occurredOn.toIso8601String().substring(0, 10),
              if (description.isNotEmpty) 'description': description,
            }, completer: completer),
          );
          await completer.future;
          if (context.mounted) {
            Navigator.of(context).pop();
            context.showSnackBar(l10n.transactionAdded);
          }
        },
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
    return Container(color: backgroundColor, child: tabBar);
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
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
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
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TitleDetailsCard(
                  title: l10n.location,
                  text:
                      [
                        if (farm.village != null) farm.village,
                        if (farm.address != null) farm.address,
                      ].isNotEmpty
                      ? [
                          if (farm.village != null) farm.village,
                          if (farm.address != null) farm.address,
                        ].join(', ')
                      : '--',
                  isFirstItem: true,
                  iconData: PhosphorIconsRegular.mapTrifold,
                  accentColor: DesignColor.accentLocation,
                ),
              ),
            ],
          ),
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
                        avatar: const Icon(
                          PhosphorIconsRegular.calendar,
                          size: 12,
                        ),
                      ),
                    if (crop.status?.label != null)
                      Chip(
                        label: Text(crop.status!.label!),
                        avatar: const Icon(PhosphorIconsRegular.tag, size: 12),
                      ),
                    if (crop.areaHa != null)
                      Chip(
                        label: Text('${crop.areaHa} ha'),
                        avatar: const Icon(
                          PhosphorIconsRegular.compass,
                          size: 12,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TitleDetailsCard(
                        title: l10n.sownOn,
                        text: crop.sownOn ?? '--',
                        isFirstItem: true,
                        iconData: PhosphorIconsRegular.plant,
                        accentColor: DesignColor.accentPoints,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TitleDetailsCard(
                        title: l10n.expectedHarvest,
                        text: crop.expectedHarvestOn ?? '--',
                        iconData: PhosphorIconsRegular.scissors,
                        accentColor: DesignColor.golden,
                      ),
                    ),
                  ],
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
    final theme = Theme.of(context);
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
            DesignCard(
              title: l10n.financeSummary,
              paddingChild: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (label, amount, icon, color) in [
                      (
                        l10n.income,
                        totals.income,
                        PhosphorIconsRegular.arrowDownLeft,
                        theme.colorScheme.success,
                      ),
                      (
                        l10n.expense,
                        totals.expense,
                        PhosphorIconsRegular.arrowUpRight,
                        theme.colorScheme.error,
                      ),
                      (
                        l10n.netProfit,
                        totals.net,
                        PhosphorIconsRegular.wallet,
                        totals.net >= 0
                            ? theme.appColors.accent
                            : theme.colorScheme.error,
                      ),
                    ])
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Icon(icon, size: 16, color: color),
                            ),
                            6.height,
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₹${amount.toStringAsFixed(0)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                            2.height,
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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

  const _FarmPhotosTab({required this.photos, required this.onDelete});

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

class _FarmDevicesTab extends StatelessWidget {
  final List<DeviceModel> devices;
  final SoilSensorAccountModel? soilSensorAccount;
  final bool isSyncing;
  final VoidCallback onSync;
  final VoidCallback onLink;
  final VoidCallback onUnlink;

  const _FarmDevicesTab({
    required this.devices,
    required this.soilSensorAccount,
    required this.isSyncing,
    required this.onSync,
    required this.onLink,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLinked = soilSensorAccount != null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        DesignCard(
          title: l10n.soilSensorAccount,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TitleDetailsCard(
                      title: 'SoilSens',
                      text: isLinked
                          ? (soilSensorAccount!.username ??
                                l10n.soilSensorAccountLinked)
                          : l10n.soilSensorAccountNotLinked,
                      iconData: isLinked
                          ? PhosphorIconsRegular.checkCircle
                          : PhosphorIconsRegular.xCircle,
                      accentColor: isLinked
                          ? DesignColor.colorPrimary
                          : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isLinked) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onUnlink,
                        child: Text(l10n.unlinkAccount),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isSyncing ? null : onSync,
                        icon: isSyncing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                PhosphorIconsRegular.arrowsClockwise,
                                size: 16,
                              ),
                        label: Text(
                          isSyncing ? l10n.syncing : l10n.syncDevices,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onLink,
                        icon: const Icon(
                          PhosphorIconsRegular.plugsConnected,
                          size: 16,
                        ),
                        label: Text(l10n.linkAccount),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (devices.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: AppEmptyView(
                title: l10n.noDevicesFound,
                message: l10n.noDevicesFoundDesc,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final device = devices[index];
              final deviceTitle = device.name?.isNotEmpty == true
                  ? device.name!
                  : (device.code ?? '--');
              return InkWell(
                onTap: () {
                  if (device.id != null) {
                    context.push(IotRouteNames.deviceDetail(device.id!));
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: DesignCard(
                  title: deviceTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TitleDetailsCard(
                              title: l10n.serialNumber,
                              text: device.code ?? '--',
                              iconData: PhosphorIconsRegular.barcode,
                              accentColor: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TitleDetailsCard(
                              title: l10n.hardwareModel,
                              text: device.typeLabel ?? device.type ?? '--',
                              iconData: PhosphorIconsRegular.cpu,
                              accentColor: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TitleDetailsCard(
                              title: l10n.status,
                              text: (device.isOnline ?? false)
                                  ? l10n.deviceOnline
                                  : l10n.deviceOffline,
                              iconData: (device.isOnline ?? false)
                                  ? PhosphorIconsRegular.wifiHigh
                                  : PhosphorIconsRegular.wifiSlash,
                              accentColor: (device.isOnline ?? false)
                                  ? DesignColor.colorPrimary
                                  : theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TitleDetailsCard(
                              title: l10n.lastReading,
                              text: device.lastReadingAt ?? '--',
                              iconData: PhosphorIconsRegular.clock,
                              accentColor: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
