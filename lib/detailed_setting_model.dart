class DetailedSettingModel {
  double? widthMax;
  double? widthMin;
  double? heightMax;
  double? heightMin;
  String? exclude;
  String? include;

  DetailedSettingModel(
      {this.widthMax = 0,
      this.widthMin = 0,
      this.heightMax = 0,
      this.heightMin = 0,
      this.exclude = "",
      this.include = ""});

  DetailedSettingModel.fromJson(Map<String, dynamic> json) {
    widthMax = json['widthMax'];
    widthMin = json['widthMin'];
    heightMax = json['heightMax'];
    heightMin = json['heightMin'];
    exclude = json['exclude'];
    include = json['include'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['widthMax'] = widthMax;
    data['widthMin'] = widthMin;
    data['heightMax'] = heightMax;
    data['heightMin'] = heightMin;
    data['exclude'] = exclude;
    data['include'] = include;
    return data;
  }
}
