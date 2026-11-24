import 'package:super_flutter/data/communication/model/alert_model.dart';

/// SchemeModel as returned by the API.
class SchemeModel {
  String? id;
  String? code;
  String? name;
  String? description;
  ScopeModel? scope;
  String? startsOn;
  String? endsOn;
  bool? isOpen;
  String? eligibility;
  String? applicationProcess;
  List<String>? requiredDocuments;
  String? subsidyAmount;
  String? fundingSource;
  String? financialYear;
  List<DistrictModel>? districts;
  List<DocumentModel>? documents;
  int? applicationsCount;

  SchemeModel({
    this.id,
    this.code,
    this.name,
    this.description,
    this.scope,
    this.startsOn,
    this.endsOn,
    this.isOpen,
    this.eligibility,
    this.applicationProcess,
    this.requiredDocuments,
    this.subsidyAmount,
    this.fundingSource,
    this.financialYear,
    this.districts,
    this.documents,
    this.applicationsCount,
  });

  SchemeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    description = json['description'];
    scope = json['scope'] != null ? ScopeModel.fromJson(json['scope']) : null;
    startsOn = json['starts_on'];
    endsOn = json['ends_on'];
    isOpen = json['is_open'];
    eligibility = json['eligibility'];
    applicationProcess = json['application_process'];
    requiredDocuments = json['required_documents']?.cast<String>();
    subsidyAmount = json['subsidy_amount'];
    fundingSource = json['funding_source'];
    financialYear = json['financial_year'];
    if (json['districts'] != null) {
      districts = <DistrictModel>[];
      json['districts'].forEach((v) {
        districts!.add(DistrictModel.fromJson(v));
      });
    }
    if (json['documents'] != null) {
      documents = <DocumentModel>[];
      json['documents'].forEach((v) {
        documents!.add(DocumentModel.fromJson(v));
      });
    }
    applicationsCount = json['applications_count'];
  }

  // sf:custom:begin SchemeModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['description'] = description;
    if (scope != null) {
      data['scope'] = scope!.toJson();
    }
    data['starts_on'] = startsOn;
    data['ends_on'] = endsOn;
    data['is_open'] = isOpen;
    data['eligibility'] = eligibility;
    data['application_process'] = applicationProcess;
    data['required_documents'] = requiredDocuments;
    data['subsidy_amount'] = subsidyAmount;
    data['funding_source'] = fundingSource;
    data['financial_year'] = financialYear;
    if (districts != null) {
      data['districts'] = districts!.map((v) => v.toJson()).toList();
    }
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    data['applications_count'] = applicationsCount;
    return data;
  }
}

class ScopeModel {
  String? value;
  String? label;

  ScopeModel({this.value, this.label});

  ScopeModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin ScopeModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['label'] = label;
    return data;
  }
}

class DocumentModel {
  String? name;
  String? url;

  DocumentModel({this.name, this.url});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }

  // sf:custom:begin DocumentModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}
