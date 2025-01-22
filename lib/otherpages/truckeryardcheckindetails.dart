import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:luxair/datastructure/vehicletoken.dart';
import 'package:luxair/widgets/common.dart';
import 'package:luxair/widgets/customdialogue.dart';
import 'package:luxair/widgets/headerclipper.dart';
import 'package:luxair/widgets/headers.dart';

import '../constants.dart';
import '../global.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class TruckYardCheckInDetails extends StatefulWidget {
  bool isExport = false;
  final VehicleToken selectedVtDetails;

  TruckYardCheckInDetails(
      {Key? key, required this.selectedVtDetails, required this.isExport})
      : super(key: key);

  @override
  State<TruckYardCheckInDetails> createState() =>
      _TruckYardCheckInDetailsState();
}

class _TruckYardCheckInDetailsState extends State<TruckYardCheckInDetails> {
  bool useMobileLayout = false, isLoading = false, isDisable = true;

  TextEditingController txtVTNO = new TextEditingController();

  @override
  void initState() {
    getGeoLocationOfStation();
    txtVTNO.text = widget.selectedVtDetails.VTNo; //"WIVT220627006";
    super.initState();
    if (isTrucker || isTruckerFF){
      getGeoLocationOfStation();
    }
    else{
      isDisable=false;
    }
  }

  getGeoLocationOfStation() async {
    var queryParams = {
      "OperationType": widget.isExport ? "3" : "4",
      "OrganizationId": selectedBaseStationBranchID.toString(),
      "VTNo": widget.selectedVtDetails.VTNo
    };
    await Global()
        .getData(
      Settings.SERVICES['VtDetailsMore'],
      queryParams,
    )
        .then((response) {
      print("data received ");
      print(json.decode(response.body)['ResponseObject']);
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> responseObjectList =
          jsonResponse['ResponseObject']['Table0'];
      geofencingInfo =
          responseObjectList.map((e) => GeofencingInfo.fromJson(e)).toList();
      print("length baseStationList = " + geofencingInfo.length.toString());
      if (isTrucker || isTruckerFF) checkLocation();
    }).catchError((onError) {
      // setState(() {
      //   isLoading = false;
      // });
      print(onError);
    });
  }

  checkLocation() async {
     print("getting locaation");
    try {
      var abc = await determinePosition();
      print(abc);
      if (abc.toLowerCase().contains("disabled")) {
        showDialog(
          context: context,
          builder: (BuildContext context) => customAlertMessageDialog(
              title: "Location Disabled",
              description: abc.toString(),
              buttonText: "Okay",
              imagepath: 'assets/images/warn.gif',
              isMobile: useMobileLayout),
        );
        return;
      }

      if (abc.toLowerCase().contains("denied")) {
        showDialog(
          context: context,
          builder: (BuildContext context) => customAlertMessageDialog(
              title: "Location Access Denied",
              description: abc.toString(),
              buttonText: "Okay",
              imagepath: 'assets/images/warn.gif',
              isMobile: useMobileLayout),
        );
        return;
      }

      if (abc.toLowerCase().contains("ok")) {
        print("getting location");
        await getLocation();
      }
    } catch (Exc) {
      print(Exc);
    } finally {
      print("this is finally");
    }
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude;
    longitude = position.longitude;

    print("---"+latitude.toString());
    print(longitude.toString());
    print("LAT LONG==${geofencingInfo[0].longitude}  ${geofencingInfo[0].latitude}");
    // var disCalc = await distance(19.173986, 72.821522, 19.2210662, 72.9757903);
    var disCalc = await distance(geofencingInfo[0].latitude,
        geofencingInfo[0].longitude, latitude, longitude);
   //  print("LAT LONG======= ${geofencingInfo[0].longitude}++${geofencingInfo[0].latitude}");
    print("DisCalculation Location======= ${disCalc}");

    print(
        "DisCalculation Location Radious======= ${geofencingInfo[0].radiusInKm.toString()}");
    print(geofencingInfo[0].radiusInKm.toString());
    if (disCalc > geofencingInfo[0].radiusInKm) {
      setState(() {
        isDisable = true;
        print("IS button disable == $isDisable");
      });
    }
    else{
      setState(() {
        isDisable = false;
        print("IS button disable == $isDisable");
      });
    }
  }


  distance(lat1, lon1, lat2, lon2) async {
    const double R = 6371; // Radius of Earth in kilometers
    var radlat1 = lat1 * math.pi / 180; // Convert latitude 1 to radians
    var radlat2 = lat2 * math.pi / 180; // Convert latitude 2 to radians
    var dlat = (lat2 - lat1) * math.pi / 180; // Difference in latitude in radians
    var dlon = (lon2 - lon1) * math.pi / 180; // Difference in longitude in radians

    // Haversine formula to calculate the distance
    var a = math.sin(dlat / 2) * math.sin(dlat / 2) +
        math.cos(radlat1) * math.cos(radlat2) *
            math.sin(dlon / 2) * math.sin(dlon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var distance = R * c; // Multiply by Earth's radius to get distance in kilometers

    return distance;
  }


  // distance(lat1, lon1, lat2, lon2) async {
  //   print("$lat1, $lon1, $lat2, $lon2");
  //   if ((lat1 == lat2) && (lon1 == lon2)) {
  //     return 0;
  //   } else {
  //     var radlat1 = math.pi * lat1 / 180;
  //     var radlat2 = math.pi * lat2 / 180;
  //     var theta = lon1 - lon2;
  //     var radtheta = math.pi * theta / 180;
  //     var dist = math.sin(radlat1) * math.sin(radlat2) +
  //         math.cos(radlat1) * math.cos(radlat2) * math.cos(radtheta);
  //     if (dist > 1) {
  //       dist = 1;
  //     }
  //     dist = math.acos(dist);
  //
  //     return dist * 6371;
  //   }
  // }


//   distance(lat1, lon1, lat2, lon2) async {
//     if ((lat1 == lat2) && (lon1 == lon2)) {
//       return 0;
//     } else {
//       var radlat1 = math.pi * lat1 / 180;
//       var radlat2 = math.pi * lat2 / 180;
//       var theta = lon1 - lon2;
//       var radtheta = math.pi * theta / 180;
//       var dist = math.sin(radlat1) * math.sin(radlat2) +
//           math.cos(radlat1) * math.cos(radlat2) * math.cos(radtheta);
//       if (dist > 1) {
//         dist = 1;
//       }
//       dist = math.acos(dist);
//       dist = dist * 180 / math.pi;
//       dist = dist * 60 * 1.1515;
// //return 40;
//       return dist * 1.609344;
//     }
//   }

  @override
  Widget build(BuildContext context) {
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = smallestDimension < 600;
    print("useMobileLayout");
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          HeaderClipperWave(
              color1: Color(0xFF3383CD),
              color2: Color(0xFF11249F),
              headerText: "Yard Check-in VT Details"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: useMobileLayout
                        ? const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 15.0)
                        : const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: useMobileLayout
                              ? MediaQuery.of(context).size.width / 5
                              : MediaQuery.of(context).size.width / 7,
                          // hard coding child width
                          child: Text(
                            "VT No.",
                            style: useMobileLayout
                                ? mobileHeaderFontStyle
                                : TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF11249F),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: useMobileLayout
                              ? MediaQuery.of(context).size.width / 1.8
                              : MediaQuery.of(context).size.width /
                                  2.5, // hard coding child width
                          child: Container(
                            height: useMobileLayout ? 40 : 65,
                            width: MediaQuery.of(context).size.width / 2.5,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: TextField(
                              controller: txtVTNO,
                              readOnly: true,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Vehicle No.",
                                hintStyle: TextStyle(color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                isDense: true,
                              ),
                              style: useMobileLayout
                                  ? mobileTextFontStyle
                                  : TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: useMobileLayout
                        ? const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0)
                        : const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!useMobileLayout) SizedBox(height: 10),
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width / 1.15,
                          color: Color(0xFF0461AA),
                        ),
                        SizedBox(height: useMobileLayout ? 10 : 20),
                        Text(
                          "Vehicle Details",
                          style: useMobileLayout
                              ? mobileHeaderFontStyle
                              : TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF11249F),
                                ),
                        ),
                        useMobileLayout
                            ? SizedBox(height: 10)
                            : SizedBox(height: 20),
                        useMobileLayout
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width / 1.01,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Column(
                                      children: [
                                        // SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.2,
                                              child: Container(
                                                height: 40,
                                                color: Colors.yellow.shade300,
                                                child: Center(
                                                  child: Text('Vehicle No.',
                                                      style:
                                                          mobileYellowTextFontStyleBold),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.2,
                                              child: Container(
                                                height: 40,
                                                color: Colors.yellow.shade300,
                                                child: Center(
                                                  child: Text('Driver Name',
                                                      style:
                                                          mobileYellowTextFontStyleBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.2,
                                              child: Container(
                                                height: 40,
                                                color: Colors.yellow.shade100,
                                                child: Center(
                                                  child: Text(
                                                      widget.selectedVtDetails
                                                          .VEHICLENO, // 'TN34Y-82223',
                                                      style:
                                                          mobileDetailsYellowBold),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.2,
                                              child: Container(
                                                height: 40,
                                                color: Colors.yellow.shade100,
                                                child: Center(
                                                  child: Text(
                                                      widget.selectedVtDetails
                                                          .DRIVERNAME, // 'John Devon',
                                                      style:
                                                          mobileDetailsYellowBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: useMobileLayout ? 10 : 20),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.09,
                                              child: Container(
                                                height: 40,
                                                color: Colors.yellow.shade300,
                                                child: Center(
                                                  child: Text(
                                                      'Slot/ Dock Details',
                                                      style:
                                                          mobileYellowTextFontStyleBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.09,
                                              child: Container(
                                                height: 40,
                                                color: Colors.yellow.shade100,
                                                child: Center(
                                                  child: Text(
                                                      widget.selectedVtDetails
                                                          .SLOTTIME, //  '08-10-2022 05:30 - 06:00',
                                                      style:
                                                          mobileDetailsYellowBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width / 1.15,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        // SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.7,
                                              child: Container(
                                                height: 50,
                                                color: Colors.yellow.shade300,
                                                child: Center(
                                                  child: Text('Vehicle No.',
                                                      style:
                                                          iPadYellowTextFontStyleBold),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.2,
                                              child: Container(
                                                height: 50,
                                                color: Colors.yellow.shade300,
                                                child: Center(
                                                  child: Text('Driver Name',
                                                      style:
                                                          iPadYellowTextFontStyleBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.7,
                                              child: Container(
                                                height: 50,
                                                color: Colors.yellow.shade100,
                                                child: Center(
                                                  child: Text('TN34Y-82223',
                                                      style:
                                                          iPadDetailsYellowBold),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.2,
                                              child: Container(
                                                height: 50,
                                                color: Colors.yellow.shade100,
                                                child: Center(
                                                  child: Text('John Devon',
                                                      style:
                                                          iPadDetailsYellowBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: useMobileLayout ? 10 : 20),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                              child: Container(
                                                height: 50,
                                                color: Colors.yellow.shade300,
                                                child: Center(
                                                  child: Text(
                                                      'Slot/ Dock Details',
                                                      style:
                                                          iPadYellowTextFontStyleBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                              child: Container(
                                                height: 50,
                                                color: Colors.yellow.shade100,
                                                child: Center(
                                                  child: Text(
                                                      '08-10-2022 05:30 - 06:00',
                                                      style:
                                                          iPadDetailsYellowBold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(height: useMobileLayout ? 10 : 40),
                      ],
                    ),
                  ),
                  Padding(
                    padding: useMobileLayout
                        ? const EdgeInsets.only(right: 00.0)
                        : const EdgeInsets.only(right: 40.0),
                    child: Align(
                      alignment: useMobileLayout
                          ? Alignment.center
                          : Alignment.topRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (isLoading) return;

                              if (isDisable) return;
                              // showSuccessMessage();
                              var submitCheckin = await submitYardCheckIn(
                                  widget.isExport ? '2' : '1',
                                  'true',
                                  'false',
                                  'false');
                              if (submitCheckin == true) {
                                var dlgstatus = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CustomDialog(
                                    title: widget.selectedVtDetails.VTNo,
                                    description: "Yard Check-in for VT# " +
                                        widget.selectedVtDetails.VTNo +
                                        " has been completed successfully",
                                    buttonText: "Okay",
                                    imagepath: 'assets/images/successchk.gif',
                                    isMobile: useMobileLayout,
                                  ),
                                );
                                var isSent = await sendSMS(
                                    widget.selectedVtDetails.DRIVERMOBILENO,
                                    widget.selectedVtDetails.VTNo,
                                    widget.selectedVtDetails.DRIVERNAME);
                                if (isSent == true) print("SMS sent");
                                if (dlgstatus == true) {
                                  Navigator.of(context)
                                      .pop(true); // To close the form
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      customAlertMessageDialog(
                                          title: "Error Occured",
                                          description:
                                              "Error occured while performing Yard Check-in, Please try again after some time",
                                          buttonText: "Okay",
                                          imagepath: 'assets/images/warn.gif',
                                          isMobile: useMobileLayout),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)), //
                              padding: const EdgeInsets.all(0.0),
                            ),
                            child: Container(
                              height: 70,
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    isLoading
                                        ? isDisable
                                            ? Colors.grey
                                            : Color(0xFF1220BC)
                                        : isDisable
                                            ? Colors.grey
                                            : Color(
                                                0xFF1220BC), //Color(0xFF1220BC),
                                    isLoading
                                        ? isDisable
                                            ? Colors.grey
                                            : Color(0xFF3540E8)
                                        : isDisable
                                            ? Colors.grey
                                            : Color(
                                                0xFF3540E8), // Color(0xFF3540E8),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 18.0, bottom: 18.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            //Text('CONTAINED BUTTON'),
                          ),
                          if (isLoading) SizedBox(width: 10),
                          if (isLoading)
                            Center(
                                child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 13,
                                    width:
                                        MediaQuery.of(context).size.height / 13,
                                    child: CircularProgressIndicator()))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  Future<bool> submitYardCheckIn(modeType, checkin, dockin, dockout) async {
    try {
      bool isValid = false;

      setState(() {
        isLoading = true;
      });

      var queryParams = {
        "OperationType": modeType.toString(),
        "pVTNo": widget.selectedVtDetails.VTNo,
        "pTPS_CHECK_IN": checkin,
        "pDOCK_IN": dockin,
        "pDOCK_OUT": dockout,
        "CreatedByUserId": loggedinUser.CreatedByUserId.toString(),
        "OrganizationBranchId":
        selectedBaseStationBranchID.toString(),//selectedTerminalID, //  loggedinUser.OrganizationBranchId,
        "OrganizationId": loggedinUser.OrganizationId.toString(),
        "IsGeoFencing": "true",
      };
      await Global()
          .getData(
        Settings.SERVICES['UpdateVT'],
        queryParams,
      )
          .then((response) {
        print("data received ");
        print(json.decode(response.body)['d']);
        isValid = true;

        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
        print(onError);
      });
      return isValid;
    } catch (Exc) {
      print(Exc);
      return false;
    }
  }
}
