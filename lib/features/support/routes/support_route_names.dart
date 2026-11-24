/// Route paths owned by the support feature.
abstract final class SupportRouteNames {
  static const root = '/support';

  static const ticketDetail = '/support/ticket_detail/:ticket';

  static String ticketDetailFor(String ticket) =>
      '/support/ticket_detail/$ticket';

  static const createTicket = '/support/create_ticket';
}
