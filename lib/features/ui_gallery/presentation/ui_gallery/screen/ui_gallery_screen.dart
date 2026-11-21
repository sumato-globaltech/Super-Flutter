import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/core/ui/widgets/app_bottom_bar.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.pagePadding.copyWith(bottom: 0),
            child: Column(
              crossAxisAlignment: .stretch,
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
                Text('ConfirmSheet', style: heading),
                Gap.md,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await ConfirmSheet.confirm(
                          context,
                          title: 'Sign out?',
                          description:
                              'You will need to sign in again on this device.',
                          icon: Icon(
                            PhosphorIconsRegular.signOut,
                            size: 35,
                            color: appColors.accent,
                          ),
                          confirmText: 'Sign out',
                        );
                        show('confirm → $ok');
                      },
                      child: const Text('Confirm'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await ConfirmSheet.confirm(
                          context,
                          title: 'Delete farm?',
                          description:
                              'Its crops, photos and transactions go with it.',
                          icon: Icon(
                            PhosphorIconsRegular.trash,
                            size: 35,
                            color: theme.colorScheme.error,
                          ),
                          confirmText: 'Delete',
                          confirmColor: theme.colorScheme.error,
                        );
                        show('destructive → $ok');
                      },
                      child: const Text('Destructive'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await ConfirmSheet.confirm(
                          context,
                          title: 'Sync devices?',
                          description:
                              'Reads the latest sensors from the provider.',
                          onConfirm: () =>
                              Future<void>.delayed(const Duration(seconds: 2)),
                        );
                        show('async (app logo) → $ok');
                      },
                      child: const Text('Async + logo'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        var attempts = 0;
                        final ok = await ConfirmSheet.confirm(
                          context,
                          title: 'Cancel shipment?',
                          icon: Icon(
                            PhosphorIconsRegular.warningCircle,
                            size: 35,
                            color: theme.colorScheme.error,
                          ),
                          confirmColor: theme.colorScheme.error,
                          onConfirm: () async {
                            await Future<void>.delayed(
                              const Duration(seconds: 1),
                            );
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
                        final picked = await ConfirmSheet.choose<String>(
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
                Text('DesignCard + TitleDetailsCard', style: heading),
                Gap.md,
                DesignCard(
                  title: 'Farm Details',
                  paddingChild: const .fromLTRB(14, 14, 14, 16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const TitleDetailsCard(
                        title: 'Farm',
                        text: 'East field',
                        isFirstItem: true,
                        iconData: PhosphorIconsRegular.plant,
                        accentColor: DesignColor.accentName,
                        isColumn: true,
                      ),
                      const TitleDetailsCard(
                        title: 'Area',
                        text: '2.5 ha',
                        iconData: PhosphorIconsRegular.mapPinArea,
                        accentColor: DesignColor.accentEnergy,
                      ),
                      const TitleDetailsCard(
                        title: 'Balance',
                        text: '',
                        iconData: PhosphorIconsRegular.hash,
                        accentColor: DesignColor.accentPoints,
                        isTextLoading: true,
                      ),
                      const Row(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Flexible(
                            child: TitleDetailsCard(
                              title: 'Crop',
                              text: 'Paddy',
                              iconData: PhosphorIconsRegular.shapes,
                              accentColor: DesignColor.accentType,
                            ),
                          ),
                          Flexible(
                            child: TitleDetailsCard(
                              title: 'UIN',
                              text: 'NL-0042',
                              isCrossAxisAlignmentStart: false,
                              iconData: PhosphorIconsRegular.identificationCard,
                              accentColor: DesignColor.accentUin,
                            ),
                          ),
                        ],
                      ),
                      const TitleDetailsCard(
                        title: 'Farmer ID',
                        text: 'FRM-2026-0042',
                        iconData: PhosphorIconsRegular.identificationCard,
                        accentColor: DesignColor.accentUin,
                        isCopyable: true,
                      ),
                      TitleDetailsCard(
                        title: 'Location',
                        text: '25.6751, 94.1086',
                        iconData: PhosphorIconsRegular.mapPin,
                        accentColor: DesignColor.accentLocation,
                        onTap: () =>
                            Utils.navigateToMapLocation('25.6751', '94.1086'),
                      ),
                      const TitleDetailsCard(
                        title: 'Advisory',
                        text: _advisory,
                        iconData: PhosphorIconsRegular.textAlignLeft,
                        accentColor: DesignColor.accentEnergy,
                        isReadMore: true,
                      ),
                      const TitleDetailsCard(
                        title: 'Farmer note',
                        text: 'Water logging after heavy rain near the east field.',
                        isBlockquote: true,
                      ),
                      const TitleDetailsCard(
                        title: 'Photos',
                        imagePreviewUrls: [
                          'https://picsum.photos/id/1084/400',
                          'https://picsum.photos/id/292/400',
                        ],
                      ),
                    ],
                  ),
                ),
                20.height,
                DesignCard(
                  title: 'Contact Person Details',
                  paddingChild: const .fromLTRB(14, 14, 14, 0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          const Flexible(
                            child: TitleDetailsCard(
                              title: 'Name',
                              isFirstItem: true,
                              text: 'Vizo Kense',
                              iconData: PhosphorIconsRegular.identificationCard,
                              accentColor: DesignColor.accentType,
                            ),
                          ),
                          Flexible(
                            child: TitleDetailsCard(
                              title: 'Phone',
                              text: '9876543210',
                              isFirstItem: true,
                              isCrossAxisAlignmentStart: false,
                              iconData: PhosphorIconsRegular.phone,
                              accentColor: DesignColor.accentUin,
                              onTap: () => Utils.launchUrl2(
                                url: '',
                                uri: Uri(scheme: 'tel', path: '9876543210'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      16.height,
                    ],
                  ),
                ),
                20.height,
                for (final (title, text, icon, accent) in const [
                  (
                    'Farm Devices',
                    'Soil sensors and devices on this farm',
                    PhosphorIconsRegular.wifiHigh,
                    DesignColor.tealDeep,
                  ),
                  (
                    'Direction',
                    'Direction to the farm location',
                    PhosphorIconsRegular.mapPin,
                    DesignColor.accentEnergy,
                  ),
                  (
                    'Transactions',
                    'Income and expenses of this farm',
                    PhosphorIconsRegular.listBullets,
                    DesignColor.accentName,
                  ),
                  (
                    'Crop Calendar',
                    'Sowing to harvest schedule',
                    PhosphorIconsRegular.calendar,
                    DesignColor.accentUin,
                  ),
                ]) ...[
                  DesignCard(
                    paddingChild: const .fromLTRB(14, 14, 14, 16),
                    onTap: () => show('$title tapped'),
                    child: Row(
                      children: [
                        Flexible(
                          child: TitleDetailsCard(
                            title: title,
                            text: text,
                            isFirstItem: true,
                            iconData: icon,
                            accentColor: accent,
                            showNavigateIcon: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.height,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
