/// Route paths owned by the shipments feature.
abstract final class ShipmentsRouteNames {
  static const root = '/shipments';

  static const shipmentDetail = '/shipments/shipment_detail/:shipment';

  static String shipmentDetailFor(String shipment) =>
      '/shipments/shipment_detail/$shipment';

  static const requestShipment = '/shipments/request_shipment';
}
