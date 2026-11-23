import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/sensor_history_model.dart';
import 'package:super_flutter/features/iot/presentation/device_detail/bloc/device_detail_bloc.dart';
import 'package:super_flutter/features/iot/presentation/device_detail/bloc/device_detail_event.dart';
import 'package:super_flutter/features/iot/presentation/device_detail/bloc/device_detail_state.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;

  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeviceDetailBloc>()..add(DeviceDetailStarted(deviceId)),
      child: const _DeviceDetailView(),
    );
  }
}

class _DeviceDetailView extends StatelessWidget {
  const _DeviceDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<DeviceDetailBloc, DeviceDetailState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.status == DeviceDetailStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final device = state.device;
        final isOnline = device?.isOnline ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              device?.name?.isNotEmpty == true ? device!.name! : l10n.deviceDetail,
            ),
            actions: [
              if (device != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? DesignColor.lightWhite
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOnline
                              ? DesignColor.colorPrimary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        isOnline ? l10n.deviceOnline : l10n.deviceOffline,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOnline
                              ? DesignColor.colorPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: switch (state.status) {
            DeviceDetailStatus.initial || DeviceDetailStatus.loading =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: DesignProgress(),
                ),
              ),
            DeviceDetailStatus.failure => AppErrorView(
                message: state.errorMessage ?? l10n.errorUnknown,
                retryLabel: l10n.tryAgain,
                onRetry: () => context
                    .read<DeviceDetailBloc>()
                    .add(DeviceDetailStarted(state.deviceId)),
              ),
            DeviceDetailStatus.success => RefreshIndicator(
                onRefresh: () async {
                  context.read<DeviceDetailBloc>().add(const DeviceDetailRefreshed());
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _buildOverviewCard(context, device!, l10n),
                    const SizedBox(height: AppSpacing.md),
                    _buildSensorsCard(context, state, l10n),
                    const SizedBox(height: AppSpacing.md),
                    _buildReadingsSection(context, state, l10n, theme),
                  ],
                ),
              ),
          },
        );
      },
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    DeviceModel device,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return DesignCard(
      title: l10n.farmDetails,
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
                  title: 'Provider',
                  text: device.provider ?? '--',
                  iconData: PhosphorIconsRegular.cloud,
                  accentColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TitleDetailsCard(
                  title: l10n.lastSync,
                  text: device.lastReadingAt ?? '--',
                  iconData: PhosphorIconsRegular.clock,
                  accentColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorsCard(
    BuildContext context,
    DeviceDetailState state,
    AppLocalizations l10n,
  ) {
    final sensors = state.device?.sensors ?? const [];
    if (sensors.isEmpty) {
      return const SizedBox.shrink();
    }

    final bloc = context.read<DeviceDetailBloc>();

    return DesignCard(
      title: l10n.sensors,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: sensors.map((sensor) {
          final sensorKey = sensor.id ?? sensor.metric ?? '';
          final isSelected = sensorKey == state.selectedSensorKey;
          return ChoiceChip(
            label: Text(sensor.name ?? sensor.metric ?? '--'),
            selected: isSelected,
            onSelected: (_) => bloc.add(DeviceDetailSensorSelected(sensorKey)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReadingsSection(
    BuildContext context,
    DeviceDetailState state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final bloc = context.read<DeviceDetailBloc>();
    final sensor = state.selectedSensor;
    final unit = sensor?.unit ?? '';
    final points = state.readings?.points ?? const [];
    final sensorTitle = sensor != null ? '${sensor.name ?? ''} ($unit)' : '';

    return DesignCard(
      title: sensorTitle.isNotEmpty ? '${l10n.readings} - $sensorTitle' : l10n.readings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildRangeChip(bloc, 7, l10n.days7, state.selectedDays),
              const SizedBox(width: AppSpacing.xs),
              _buildRangeChip(bloc, 14, l10n.days14, state.selectedDays),
              const SizedBox(width: AppSpacing.xs),
              _buildRangeChip(bloc, 30, l10n.days30, state.selectedDays),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.isLoadingReadings)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: DesignProgress()),
            )
          else if (points.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  l10n.noReadingsFound,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: points.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final point = points[index];
                return _buildReadingTile(point, unit, theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(
    DeviceDetailBloc bloc,
    int days,
    String label,
    int currentDays,
  ) {
    final isSelected = days == currentDays;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => bloc.add(DeviceDetailRangeChanged(days)),
    );
  }

  Widget _buildReadingTile(
    ReadingPointModel point,
    String unit,
    ThemeData theme,
  ) {
    final atRaw = point.at;
    final timeStr = atRaw != null
        ? (DateTime.tryParse(atRaw) != null
            ? DateFormat.yMMMd().add_jm().format(DateTime.parse(atRaw))
            : atRaw)
        : '--';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.chartLine,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                timeStr,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          Text(
            point.value != null ? '${point.value} $unit'.trim() : '--',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
