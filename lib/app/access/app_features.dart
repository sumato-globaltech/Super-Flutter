import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/domain/auth/entities/access_rule.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';

import 'feature_registry.dart';

final appFeatures = FeatureRegistry([
  const AppFeature(
    id: 'home',
    path: DashboardRouteNames.dashboard,
    rule: AccessRule.signedIn(),
    title: _home,
    icon: PhosphorIconsRegular.house,
    tab: AppTab(
      icon: PhosphorIconsRegular.house,
      activeIcon: PhosphorIconsFill.house,
      priority: 0,
    ),
  ),
  const AppFeature(
    id: 'farms',
    path: '/farms',
    rule: _farmer,
    title: _farms,
    icon: PhosphorIconsRegular.plant,
    tab: AppTab(
      icon: PhosphorIconsRegular.plant,
      activeIcon: PhosphorIconsFill.plant,
      priority: 10,
    ),
  ),
  const AppFeature(
    id: 'farmer_shipments',
    path: '/shipments',
    rule: AccessRule.all([
      AccessRule.role(Roles.farmer),
      AccessRule.profile(),
      AccessRule.permission(Permissions.shipmentsRequest),
    ]),
    title: _shipments,
    icon: PhosphorIconsRegular.truck,
    tab: _shipmentsTab,
  ),
  const AppFeature(
    id: 'vendor_shipments',
    path: '/shipments',
    rule: AccessRule.all([
      AccessRule.role(Roles.vendor),
      AccessRule.profile(),
      AccessRule.permission(Permissions.shipmentsHandle),
    ]),
    title: _shipments,
    icon: PhosphorIconsRegular.truck,
    tab: _shipmentsTab,
  ),
  const AppFeature(
    id: 'driver_shipments',
    path: '/shipments',
    rule: AccessRule.all([
      AccessRule.role(Roles.driver),
      AccessRule.profile(),
      AccessRule.permission(Permissions.shipmentsDrive),
    ]),
    title: _shipments,
    icon: PhosphorIconsRegular.truck,
    tab: _shipmentsTab,
  ),
  const AppFeature(
    id: 'production',
    path: '/production',
    rule: AccessRule.any([
      AccessRule.permission(Permissions.productionView),
      AccessRule.permission(Permissions.productionManage),
    ]),
    title: _production,
    icon: PhosphorIconsRegular.chartLine,
    tab: AppTab(
      icon: PhosphorIconsRegular.chartLine,
      activeIcon: PhosphorIconsFill.chartLine,
      priority: 10,
    ),
  ),
  const AppFeature(
    id: 'help_desk_queue',
    path: '/help-desk',
    rule: AccessRule.permission(Permissions.helpdeskManage),
    title: _helpDesk,
    icon: PhosphorIconsRegular.headset,
    tab: AppTab(
      icon: PhosphorIconsRegular.headset,
      activeIcon: PhosphorIconsFill.headset,
      priority: 10,
    ),
  ),
  const AppFeature(
    id: 'market',
    path: '/market',
    rule: AccessRule.public(),
    title: _market,
    icon: PhosphorIconsRegular.storefront,
    tab: AppTab(
      icon: PhosphorIconsRegular.storefront,
      activeIcon: PhosphorIconsFill.storefront,
      priority: 20,
    ),
  ),
  const AppFeature(
    id: 'schemes',
    path: '/schemes',
    rule: AccessRule.public(),
    title: _schemes,
    icon: PhosphorIconsRegular.scroll,
    tab: AppTab(
      icon: PhosphorIconsRegular.scroll,
      activeIcon: PhosphorIconsFill.scroll,
      priority: 30,
    ),
  ),
  const AppFeature(
    id: 'support',
    path: '/support',
    rule: _farmer,
    title: _helpDesk,
    icon: PhosphorIconsRegular.headset,
  ),
  const AppFeature(
    id: 'crops',
    path: '/crops',
    rule: AccessRule.public(),
    title: _crops,
    icon: PhosphorIconsRegular.plant,
  ),
  const AppFeature(
    id: 'notices',
    path: '/notices',
    rule: AccessRule.public(),
    title: _notices,
    icon: PhosphorIconsRegular.megaphone,
  ),
  const AppFeature(
    id: 'manage_notices',
    path: '/admin/notices',
    rule: AccessRule.permission(Permissions.noticesManage),
    title: _manageNotices,
    icon: PhosphorIconsRegular.megaphone,
  ),
  const AppFeature(
    id: 'manage_alerts',
    path: '/admin/alerts',
    rule: AccessRule.permission(Permissions.alertsManage),
    title: _manageAlerts,
    icon: PhosphorIconsRegular.warning,
  ),
  const AppFeature(
    id: 'profile',
    path: '/profile',
    rule: AccessRule.signedIn(),
    title: _profile,
    icon: PhosphorIconsRegular.user,
  ),
]);

const _farmer = AccessRule.all([
  AccessRule.role(Roles.farmer),
  AccessRule.profile(),
]);

const _shipmentsTab = AppTab(
  icon: PhosphorIconsRegular.truck,
  activeIcon: PhosphorIconsFill.truck,
  priority: 10,
);

String _home(AppLocalizations l10n) => l10n.home;
String _farms(AppLocalizations l10n) => l10n.farms;
String _shipments(AppLocalizations l10n) => l10n.shipments;
String _production(AppLocalizations l10n) => l10n.production;
String _helpDesk(AppLocalizations l10n) => l10n.helpDesk;
String _market(AppLocalizations l10n) => l10n.market;
String _schemes(AppLocalizations l10n) => l10n.schemes;
String _crops(AppLocalizations l10n) => l10n.crops;
String _notices(AppLocalizations l10n) => l10n.notices;
String _manageNotices(AppLocalizations l10n) => l10n.manageNotices;
String _manageAlerts(AppLocalizations l10n) => l10n.manageAlerts;
String _profile(AppLocalizations l10n) => l10n.profile;
