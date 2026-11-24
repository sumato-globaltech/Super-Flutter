/// QueueSummaryModel as returned by the API.
class QueueSummaryModel {
  int? open;
  int? overdueFollowUps;
  int? resolvedToday;
  int? unassigned;

  QueueSummaryModel({
    this.open,
    this.overdueFollowUps,
    this.resolvedToday,
    this.unassigned,
  });

  QueueSummaryModel.fromJson(Map<String, dynamic> json) {
    open = json['open'];
    overdueFollowUps = json['overdue_follow_ups'];
    resolvedToday = json['resolved_today'];
    unassigned = json['unassigned'];
  }

  // sf:custom:begin QueueSummaryModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['open'] = open;
    data['overdue_follow_ups'] = overdueFollowUps;
    data['resolved_today'] = resolvedToday;
    data['unassigned'] = unassigned;
    return data;
  }
}
