class UserOrganizationDetails {
  final int UserId;
  final int OrganizationId;
  final String OrgName;
  final int OrganizationBranchId;
  final String OrgBranchName;
  final int OrganizationTypeId;

  UserOrganizationDetails({
    required this.UserId,
    required this.OrganizationId,
    required this.OrgName,
    required this.OrganizationBranchId,
    required this.OrgBranchName,
    this.OrganizationTypeId = 0,
  });

  factory UserOrganizationDetails.fromJson(Map<String, dynamic> json) {
    return UserOrganizationDetails(
      UserId: json['UserId'] == 0 ? 0 : json['UserId'],
      OrganizationId:
          json['OrganizationId'] == 0 ? 0 : json['OrganizationId'],
      OrgName: json['OrgName'] == null ? "" : json['OrgName'],
      OrganizationBranchId: json['OrganizationBranchId'] == 0
          ? 0
          : json['OrganizationBranchId'],
      OrgBranchName: json['OrgBranchName'] == null ? "" : json['OrgBranchName'],
      /* OrganizationTypeId:
          json['OrganizationTypeId'] == null ? 0 : json['OrganizationTypeId'],*/
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["UserId"] = UserId;
    map["OrganizationId"] = OrganizationId;
    map["OrgName"] = OrgName;
    map["OrganizationBranchId"] = OrganizationBranchId;
    map["OrgBranchName"] = OrgBranchName;
    // map["OrganizationTypeId"] = OrganizationTypeId;
    return map;
  }
}

class UserDetails {
  final String UserId;
  final String OrgName;
  final String Name;
  final String EmailId;
  final int OrganizationBranchId;
  final int OrganizationId;
  final int CreatedByUserId;
  final String OrganizationTypeId;

  UserDetails({
    required this.UserId,
    required this.OrgName,
    required this.Name,
    required this.EmailId,
    required this.OrganizationBranchId,
    required this.OrganizationId,
    required this.CreatedByUserId,
    required this.OrganizationTypeId,

  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      UserId: json['UserId'] == null ? "" : json['UserId'],
      OrgName: json['OrgName'] == null ? "" : json['OrgName'],
      Name: json['Name'] == null ? "" : json['Name'],
      EmailId: json['EmailId'] == null ? "" : json['EmailId'],
      OrganizationBranchId: json['OrganizationBranchId'] == null
          ? 0
          : json['OrganizationBranchId'],
      OrganizationId:
      json['OrganizationId'] == null ? 0 : json['OrganizationId'],
      CreatedByUserId:
      json['CreatedByUserId'] == null ? 0 : json['CreatedByUserId'],
      OrganizationTypeId:
      json['OrganizationTypeId'] == null ? "" : json['OrganizationTypeId'],

    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["UserId"] = UserId;
    map["OrgName"] = OrgName;
    map["Name"] = Name;
    map["EmailId"] = EmailId;
    map["OrganizationBranchId"] = OrganizationBranchId;
    map["OrganizationId"] = OrganizationId;
    map["CreatedByUserId"] = CreatedByUserId;
    map["OrganizationTypeId"] = OrganizationTypeId;
    return map;
  }
}

//[{"Latitude":"19.46626366","Longitude":"72.81160143","IsActive":true,"RadiousinMeter":50}]
class LocationDetails {
  final double Latitude;
  final double Longitude;
  final int IsActive;
  final double RadiousinMeter;

  LocationDetails({
    required this.Latitude,
    required this.Longitude,
    required this.IsActive,
    this.RadiousinMeter = 0,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    return LocationDetails(
      Latitude: json['Latitude'] == null ? "" : json['Latitude'],
      Longitude: json['Longitude'] == null ? "" : json['Longitude'],
      IsActive: json['IsActive'] == null ? false : json['IsActive'],
      /* RadiousinMeter:
          json['RadiousinMeter'] == null ? 0 : json['RadiousinMeter'],*/
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["Latitude"] = Latitude;
    map["Longitude"] = Longitude;
    map["IsActive"] = IsActive;
    /* map["RadiousinMeter"] = RadiousinMeter;*/
    return map;
  }
}
