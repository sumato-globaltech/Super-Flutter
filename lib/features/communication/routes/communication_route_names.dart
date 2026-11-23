/// Route paths owned by the communication feature.
abstract final class CommunicationRouteNames {
  static const notices = '/notices';
  static const alerts = '/alerts';

  /// Detail page for a single notice.
  static String noticeDetail(String id) => '/notices/$id';

  /// Route template for GoRouter.
  static const noticeDetailTemplate = '/notices/:noticeId';
}
