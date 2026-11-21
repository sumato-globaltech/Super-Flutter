import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_bottom_bar.dart';
import 'package:super_flutter/core/ui/widgets/app_confirm_sheet.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';

// Developer gallery of the shared widgets. Sample data is illustrative and
// deliberately not localised.
class UiGalleryScreen extends StatefulWidget {
  const UiGalleryScreen({super.key});

  @override
  State<UiGalleryScreen> createState() => _UiGalleryScreenState();
}

class _UiGalleryScreenState extends State<UiGalleryScreen> {
  int _tab = 0;
  int _tabCount = 5;

  static const _tabs = [
    AppBottomBarItem(
      icon: PhosphorIconsRegular.house,
      activeIcon: PhosphorIconsFill.house,
      label: 'Home',
    ),
    AppBottomBarItem(
      icon: PhosphorIconsRegular.storefront,
      activeIcon: PhosphorIconsFill.storefront,
      label: 'Market',
    ),
    AppBottomBarItem(
      icon: PhosphorIconsRegular.plant,
      activeIcon: PhosphorIconsFill.plant,
      label: 'Farms',
      badgeCount: 3,
    ),
    AppBottomBarItem(
      icon: PhosphorIconsRegular.scroll,
      activeIcon: PhosphorIconsFill.scroll,
      label: 'Schemes',
      showDot: true,
    ),
    AppBottomBarItem(
      icon: PhosphorIconsRegular.user,
      activeIcon: PhosphorIconsFill.user,
      label: 'Profile',
    ),
  ];

  static const _advisory =
      'Apply 20 kg of urea per hectare after the first weeding, then irrigate '
      'lightly. Avoid applying before heavy rain, and keep a gap of three '
      'weeks before the second dose so the crop can take up the nitrogen '
      'evenly across the field.';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    final heading = theme.textTheme.titleMedium;

    void show(String message) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

    final tabs = switch (_tabCount) {
      2 => [_tabs.first, _tabs.last],
      3 => [_tabs[0], _tabs[1], _tabs[4]],
      _ => _tabs,
    };

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.uiGallery,
        subtitle: 'Shared widgets',
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Badge(
              smallSize: 8,
              child: const Icon(PhosphorIconsRegular.bell),
            ),
            onPressed: () => show('notifications'),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomBar(
        items: tabs,
        selectedIndex: _tab.clamp(0, tabs.length - 1),
        onSelected: (index) {
          if (index == _tab) show('${tabs[index].label} tapped again');
          setState(() => _tab = index);
        },
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          Text('AppBottomBar', style: heading),
          Gap.md,
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 2, label: Text('2 tabs')),
              ButtonSegment(value: 3, label: Text('3 tabs')),
              ButtonSegment(value: 5, label: Text('5 tabs')),
            ],
            selected: {_tabCount},
            onSelectionChanged: (value) => setState(() {
              _tabCount = value.first;
              _tab = 0;
            }),
          ),
          Gap.xl,
          Text('AppTopBar', style: heading),
          Gap.md,
          Card(
            child: Column(
              children: [
                AppTopBar(
                  title: 'Farms',
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      tooltip: 'Add',
                      icon: const Icon(PhosphorIconsRegular.plus),
                      onPressed: () => show('add'),
                    ),
                  ],
                ),
                const Divider(height: 1),
                AppTopBar(
                  title: 'East field',
                  subtitle: 'Kohima · 2.5 ha',
                  leading: const BackButton(),
                  actions: [
                    IconButton(
                      tooltip: 'More',
                      icon: const Icon(PhosphorIconsRegular.info),
                      onPressed: () => show('info'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap.xl,
          Text('AppConfirmSheet', style: heading),
          Gap.md,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton(
                onPressed: () async {
                  final ok = await AppConfirmSheet.confirm(
                    context,
                    title: 'Sign out?',
                    message: 'You will need to sign in again on this device.',
                    icon: PhosphorIconsRegular.signOut,
                  );
                  show('confirm → $ok');
                },
                child: const Text('Confirm'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final ok = await AppConfirmSheet.confirm(
                    context,
                    title: 'Delete farm?',
                    message: 'Its crops, photos and transactions go with it.',
                    icon: PhosphorIconsRegular.trash,
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                  show('destructive → $ok');
                },
                child: const Text('Destructive'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final ok = await AppConfirmSheet.confirm(
                    context,
                    title: 'Sync devices?',
                    message: 'Reads the latest sensors from the provider.',
                    icon: PhosphorIconsRegular.info,
                    onConfirm: () =>
                        Future<void>.delayed(const Duration(seconds: 2)),
                  );
                  show('async → $ok');
                },
                child: const Text('Async action'),
              ),
              OutlinedButton(
                onPressed: () async {
                  var attempts = 0;
                  final ok = await AppConfirmSheet.confirm(
                    context,
                    title: 'Cancel shipment?',
                    icon: PhosphorIconsRegular.warningCircle,
                    isDestructive: true,
                    onConfirm: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (++attempts == 1) {
                        throw const BadRequestException(
                          'The driver has already picked this up.',
                        );
                      }
                    },
                  );
                  show('failure then retry → $ok');
                },
                child: const Text('Failure'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final picked = await AppConfirmSheet.choose<String>(
                    context,
                    title: 'Sort markets by',
                    actions: const [
                      SheetAction(
                        value: 'name',
                        label: 'Name',
                        icon: PhosphorIconsRegular.textAlignLeft,
                        selected: true,
                      ),
                      SheetAction(
                        value: 'distance',
                        label: 'Distance',
                        icon: PhosphorIconsRegular.info,
                      ),
                      SheetAction(
                        value: 'clear',
                        label: 'Clear favourites',
                        icon: PhosphorIconsRegular.trash,
                        isDestructive: true,
                      ),
                    ],
                  );
                  show('choose → $picked');
                },
                child: const Text('Choose'),
              ),
            ],
          ),
          Gap.xl,
          Text('TitleDetailsCard', style: heading),
          Gap.md,
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleDetailsCard(title: 'Farm area', text: '2.5 ha'),
                  Gap.lg,
                  TitleDetailsCard(
                    title: 'District',
                    text: 'Kohima',
                    icon: PhosphorIconsRegular.info,
                    onTap: () => show('district tapped'),
                  ),
                  Gap.lg,
                  TitleDetailsCard(
                    title: 'Status',
                    icon: PhosphorIconsRegular.check,
                    accentColor: appColors.success,
                    text: 'Verified',
                  ),
                  Gap.lg,
                  const TitleDetailsCard(
                    title: 'Farmer ID',
                    text: 'FRM-2026-0042',
                    isCopyable: true,
                  ),
                  Gap.lg,
                  const TitleDetailsCard(
                    title: 'Advisory',
                    text: _advisory,
                    icon: PhosphorIconsRegular.textAlignLeft,
                    readMoreLines: 2,
                  ),
                  Gap.lg,
                  const TitleDetailsCard(
                    title: 'Farmer note',
                    text: 'Water logging after heavy rain near the east field.',
                    isBlockquote: true,
                  ),
                  Gap.lg,
                  const TitleDetailsCard(
                    title: 'Balance',
                    text: '',
                    isLoading: true,
                  ),
                  Gap.lg,
                  TitleDetailsCard(
                    title: 'Photos',
                    imageUrls: const [
                      'https://picsum.photos/id/1084/200',
                      'https://picsum.photos/id/292/200',
                      '',
                    ],
                    onImageTap: (index) => show('photo $index tapped'),
                  ),
                ],
              ),
            ),
          ),
          Gap.md,
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  const Expanded(
                    child: TitleDetailsCard(title: 'Sown', text: '12 Jun 2026'),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TitleDetailsCard(
                        title: 'Expected yield',
                        text: '4.2 t',
                        alignEnd: true,
                        icon: PhosphorIconsRegular.info,
                        accentColor: appColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
