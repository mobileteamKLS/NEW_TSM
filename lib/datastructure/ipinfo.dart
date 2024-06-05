class IpInfo {
  String? ip;
  String? city;
  String? country;
  String? org;

  IpInfo(
      {this.ip,
        this.city,
        this.country,
        this.org});

  IpInfo.fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
    city = json['city'];
    country = json['country'];
    org = json['org'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ip'] = this.ip;
    data['city'] = this.city;
    data['country'] = this.country;
    data['org'] = this.org;
    return data;
  }
}
