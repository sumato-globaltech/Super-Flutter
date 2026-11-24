/// Route paths owned by the admin_communication feature.
abstract final class AdminCommunicationRouteNames {
  static const root = '/admin/notices';

  static const adminAlerts = '/admin/alerts';

  static const addNotice = '/admin/notices/add';

  static const editNotice = '/admin/notices/edit/:notice';

  static String editNoticeFor(String notice) => '/admin/notices/edit/$notice';

  static const addAlert = '/admin/alerts/add';

  static const editAlert = '/admin/alerts/edit/:alert';

  static String editAlertFor(String alert) => '/admin/alerts/edit/$alert';
}
