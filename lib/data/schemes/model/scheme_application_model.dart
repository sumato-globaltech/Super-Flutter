import 'package:super_flutter/data/schemes/model/scheme_application_document_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_party_model.dart';

/// SchemeApplicationModel as returned by the API.
class SchemeApplicationModel {
  String? id;
  ShipmentPartyModel? scheme;
  StatusModel? status;
  bool? canWithdraw;
  DateTime? appliedAt;
  DateTime? reviewedAt;
  String? decisionNote;
  String? amountApproved;
  String? amountDisbursed;
  String? disbursedOn;
  List<SchemeApplicationDocumentModel>? documents;

  SchemeApplicationModel({
    this.id,
    this.scheme,
    this.status,
    this.canWithdraw,
    this.appliedAt,
    this.reviewedAt,
    this.decisionNote,
    this.amountApproved,
    this.amountDisbursed,
    this.disbursedOn,
    this.documents,
  });

  SchemeApplicationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    scheme = json['scheme'] != null
        ? ShipmentPartyModel.fromJson(json['scheme'])
        : null;
    status = json['status'] != null
        ? StatusModel.fromJson(json['status'])
        : null;
    canWithdraw = json['can_withdraw'];
    appliedAt = json['applied_at'] != null
        ? DateTime.tryParse(json['applied_at'].toString())
        : null;
    reviewedAt = json['reviewed_at'] != null
        ? DateTime.tryParse(json['reviewed_at'].toString())
        : null;
    decisionNote = json['decision_note'];
    amountApproved = json['amount_approved'];
    amountDisbursed = json['amount_disbursed'];
    disbursedOn = json['disbursed_on'];
    if (json['documents'] != null) {
      documents = <SchemeApplicationDocumentModel>[];
      json['documents'].forEach((v) {
        documents!.add(SchemeApplicationDocumentModel.fromJson(v));
      });
    }
  }

  // sf:custom:begin SchemeApplicationModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (scheme != null) {
      data['scheme'] = scheme!.toJson();
    }
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['can_withdraw'] = canWithdraw;
    data['applied_at'] = appliedAt?.toIso8601String();
    data['reviewed_at'] = reviewedAt?.toIso8601String();
    data['decision_note'] = decisionNote;
    data['amount_approved'] = amountApproved;
    data['amount_disbursed'] = amountDisbursed;
    data['disbursed_on'] = disbursedOn;
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
