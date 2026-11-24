/// CropAnalysisModel as returned by the API.
class CropAnalysisModel {
  String? cropHealth;
  List<String>? crops;
  String? focus;
  String? distance;
  String? notice;
  List<DiagnosModel>? diagnoses;

  CropAnalysisModel({
    this.cropHealth,
    this.crops,
    this.focus,
    this.distance,
    this.notice,
    this.diagnoses,
  });

  CropAnalysisModel.fromJson(Map<String, dynamic> json) {
    cropHealth = json['crop_health'];
    crops = json['crops']?.cast<String>();
    focus = json['focus'];
    distance = json['distance'];
    notice = json['notice'];
    if (json['diagnoses'] != null) {
      diagnoses = <DiagnosModel>[];
      json['diagnoses'].forEach((v) {
        diagnoses!.add(DiagnosModel.fromJson(v));
      });
    }
  }

  // sf:custom:begin CropAnalysisModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['crop_health'] = cropHealth;
    data['crops'] = crops;
    data['focus'] = focus;
    data['distance'] = distance;
    data['notice'] = notice;
    if (diagnoses != null) {
      data['diagnoses'] = diagnoses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DiagnosModel {
  String? name;
  String? scientificName;
  String? likelihood;
  List<String>? images;
  List<String>? signs;
  String? description;
  List<String>? prevention;
  String? organicTreatment;
  String? chemicalTreatment;

  DiagnosModel({
    this.name,
    this.scientificName,
    this.likelihood,
    this.images,
    this.signs,
    this.description,
    this.prevention,
    this.organicTreatment,
    this.chemicalTreatment,
  });

  DiagnosModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    scientificName = json['scientific_name'];
    likelihood = json['likelihood'];
    images = json['images']?.cast<String>();
    signs = json['signs']?.cast<String>();
    description = json['description'];
    prevention = json['prevention']?.cast<String>();
    organicTreatment = json['organic_treatment'];
    chemicalTreatment = json['chemical_treatment'];
  }

  // sf:custom:begin DiagnosModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['scientific_name'] = scientificName;
    data['likelihood'] = likelihood;
    data['images'] = images;
    data['signs'] = signs;
    data['description'] = description;
    data['prevention'] = prevention;
    data['organic_treatment'] = organicTreatment;
    data['chemical_treatment'] = chemicalTreatment;
    return data;
  }
}
