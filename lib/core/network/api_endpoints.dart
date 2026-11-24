abstract final class ApiEndpoints {
  static const login = '/api/v1/login';
  static const tokenRefresh = '/api/v1/token/refresh';

  static const publicPaths = <String>{login, requestOtp, verifyOtp};

  static bool isPublic(String path) =>
      publicPaths.any((public) => path.endsWith(public));

  static const me = '/api/v1/me';

  static const logout = '/api/v1/logout';

  static const logoutAll = '/api/v1/logout-all';

  static const requestOtp = '/api/v1/otp/request';

  static const verifyOtp = '/api/v1/otp/verify';

  static const changePassword = '/api/v1/profile/password';

  static String notice(String notice) => '/api/v1/notices/$notice';

  static const notices = '/api/v1/notices';

  static const alerts = '/api/v1/alerts';

  static const banners = '/api/v1/banners';

  static const farm = '/api/v1/farmer/farms';

  static const blocks = '/api/v1/farmer/blocks';

  static const soilTypes = '/api/v1/farmer/soil-types';

  static const irrigationMethods = '/api/v1/farmer/irrigation-methods';

  static const landOwnerships = '/api/v1/farmer/land-ownerships';

  static String farmDetail(String farm) => '/api/v1/farmer/farms/$farm';

  static const transactionCategories =
      '/api/v1/categories/transaction_category';

  static const seasons = '/api/v1/farmer/seasons';

  static const cropStatuses = '/api/v1/farmer/crop-statuses';

  static const currentFinancialYear = '/api/v1/financial-years/current';

  static const shipments = '/api/v1/farmer/shipments';

  static String shipment(String shipment) =>
      '/api/v1/farmer/shipments/$shipment';

  static String cancelShipment(String shipment) =>
      '/api/v1/farmer/shipments/$shipment/cancel';

  static const shipmentOptions = '/api/v1/farmer/shipments/options';

  static const vendorShipments = '/api/v1/vendor/shipments';

  static String vendorShipment(String shipment) =>
      '/api/v1/vendor/shipments/$shipment';

  static String acceptShipment(String shipment) =>
      '/api/v1/vendor/shipments/$shipment/accept';

  static String rejectShipment(String shipment) =>
      '/api/v1/vendor/shipments/$shipment/reject';

  static String reassignShipment(String shipment) =>
      '/api/v1/vendor/shipments/$shipment/assignment';

  static String receiveShipment(String shipment) =>
      '/api/v1/vendor/shipments/$shipment/receive';

  static String reweighShipmentItem(String shipment, String item) =>
      '/api/v1/vendor/shipments/$shipment/items/$item/reweigh';

  static String assignmentOptions(String shipment) =>
      '/api/v1/vendor/shipments/$shipment/assignment-options';

  static const driverShipments = '/api/v1/driver/shipments';

  static String driverShipment(String shipment) =>
      '/api/v1/driver/shipments/$shipment';

  static String recordPicked(String shipment) =>
      '/api/v1/driver/shipments/$shipment/picked';

  static String confirmPickup(String shipment) =>
      '/api/v1/driver/shipments/$shipment/pickup';

  static String markReached(String shipment) =>
      '/api/v1/driver/shipments/$shipment/reach';

  static const schemes = '/api/v1/schemes';

  static String scheme(String scheme) => '/api/v1/schemes/$scheme';

  static String applyScheme(String scheme) =>
      '/api/v1/farmer/schemes/$scheme/apply';

  static String withdrawApplication(String application) =>
      '/api/v1/farmer/applications/$application/withdraw';

  static String applicationDocument(String application) =>
      '/api/v1/farmer/applications/$application/documents';

  static const officerSchemes = '/api/v1/officer/schemes';

  static const schemeApplications = '/api/v1/farmer/applications';

  static const callCenter = '/api/v1/farmer/call-center';

  static const callBack = '/api/v1/farmer/call-back';

  static const tickets = '/api/v1/farmer/tickets';

  static String ticket(String ticket) => '/api/v1/farmer/tickets/$ticket';

  static const ticketCategory = '/api/v1/categories/ticket_category';

  static const crops = '/api/v1/crops?per_page=100';

  static const queueSummary = '/api/v1/agent/queue-summary';

  static const production = '/api/v1/production/insights';

  static String publishNotice(String notice) =>
      '/api/v1/admin/notices/$notice/publish';

  static String archiveNotice(String notice) =>
      '/api/v1/admin/notices/$notice/archive';

  static String restoreNotice(String notice) =>
      '/api/v1/admin/notices/$notice/restore';

  static String adminNoticeRemoval(String notice) =>
      '/api/v1/admin/notices/$notice';

  static String activateAlert(String alert) =>
      '/api/v1/admin/alerts/$alert/activate';

  static String cancelAlert(String alert) =>
      '/api/v1/admin/alerts/$alert/cancel';

  static String adminAlertRemoval(String alert) =>
      '/api/v1/admin/alerts/$alert';

  static const adminNotices = '/api/v1/admin/notices';

  static const adminAlerts = '/api/v1/admin/alerts';

  static const noticeType = '/api/v1/categories/notice_type';

  static const priorities = '/api/v1/admin/notices/priorities';

  static const alertType = '/api/v1/categories/alert_type';

  static const districts = '/api/v1/admin/alerts/districts';

  static const severities = '/api/v1/admin/alerts/severities';

  static const farmerProfile = '/api/v1/farmer/profile';

  static const genders = '/api/v1/farmer/genders';

  static const districtList = '/api/v1/districts';

  static const facilityTypes = '/api/v1/categories/facility_type';

  static const meetings = '/api/v1/meetings';

  static const facilities = '/api/v1/facilities';

  static const facilityStats = '/api/v1/facilities/stats';

  static const cropAnalysis = '/api/v1/crop-detector';

  static const assistantAnswer = '/api/v1/farming-assistant';

  static const nationalFarmingAiAssistantLanguages =
      '/api/v1/national-farming-ai-assistant/languages';

  static const nationalFarmingAiAssistantAnswer =
      '/api/v1/national-farming-ai-assistant/chat';
}
