import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_accura_kyc/flutter_accura_kyc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'ResultScreen.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  dynamic _result = {'isValid': false};
  String language = 'en';
  Map<String, dynamic> countrySelected = {};
  Map<String, dynamic> cardSelected = {};
  Map<String, dynamic> mrzSelected = {};
  Map<String, dynamic> barcodeSelected = {};
  String mrzCountryList = 'all';
  List<Map<String, dynamic>> mrzList = [
    {"label": "Passport", "value": "passport_mrz"},
    {"label": "Mrz ID", "value": "id_mrz"},
    {"label": "Visa Card", "value": "visa_mrz"},
    {"label": "Other", "value": "other_mrz"}
  ];
  List<String> ocrCountryDropdownOptions = [''];
  List<String> ocrCardDropdownOptions = [''];
  List<String> mrzDropdownOptions = [''];
  List<String> barcodeDropdownOptions = [''];
  dynamic sdkConfig;

  String selectedCardString = "";

  @override
  void initState() {
    super.initState();
    requestForPermission();
    getMetaData();
  }

  //Code for get permissions for access camera, storage & microphone
  Future<bool> requestForPermission() async {
    List<bool> grantStatus = [];
    var status = true;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.microphone,
    ].request();
    print(statuses);
    for (var i = 0; i < statuses.length; i++) {
      // ignore: unrelated_type_equality_checks
      if (statuses[i] != null && statuses[i] != "PermissionStatus.granted") {
        grantStatus.add(true);
      } else {
        grantStatus.add(false);
      }
    }

    for (var item in grantStatus) {
      if (!item) {
        status = false;
      }
    }
    return status;
  }

  //Code for get current app oriantation.
  String getOrientation() {
    if (MediaQuery.of(context).orientation.toString().contains('landscape')) {
      return 'landscape';
    }
    return 'portrait'; //MediaQuery.of(context).orientation.toString();
  }

  void showFlutterToast(msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  //Code for get license information from SDK.
  Future<void> getMetaData() async {
    try {
      await FlutterAccuraKyc.getMetaData()
          .then((value) => {setupConfigData(json.decode(value))})
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
    if (!mounted) return;
  }

  void setupConfigData(obj) {
    setState(() {
      sdkConfig = obj;
    });
    print("setupConfigData $obj");
    setupAccuraConfig();
    List<String> tempList1 = [];
    for (var item in mrzList) {
      tempList1.add(item["label"]);
    }

    List<String> tempList2 = [];
    for (var item in obj['barcodes']) {
      tempList2.add(item['name']);
    }

    List<String> tempList3 = [];
    for (var item in obj['countries']) {
      tempList3.add(item['name']);
    }

    setState(() {
      mrzDropdownOptions = tempList1;
      barcodeDropdownOptions = tempList2;
      ocrCountryDropdownOptions = tempList3;
    });
  }

  //Code for setup document scanning messages & scan config.
  Future<void> setupAccuraConfig() async {
    try {
      var config = {
        "ACCURA_ERROR_CODE_MOTION": this.language == 'en'
            ? 'Keep Document Steady'
            : '???????? ?????? ???????? ??????????????',
        "ACCURA_ERROR_CODE_DOCUMENT_IN_FRAME": this.language == 'en'
            ? 'Keep document in frame'
            : '?????????? ???????????????? ???? ????????????',
        "ACCURA_ERROR_CODE_BRING_DOCUMENT_IN_FRAME": this.language == 'en'
            ? 'Bring card near to frame'
            : '?????????? ?????????????? ???????????? ???? ????????????',
        "ACCURA_ERROR_CODE_PROCESSING":
            this.language == 'en' ? 'Processing' : '??????????',
        "ACCURA_ERROR_CODE_BLUR_DOCUMENT": this.language == 'en'
            ? 'Blur detect in document'
            : '?????? ?????????????? ???? ??????????????',
        "ACCURA_ERROR_CODE_FACE_BLUR": this.language == 'en'
            ? 'Blur detected over face'
            : '???? ?????????? ???? ???????????? ?????? ??????????',
        "ACCURA_ERROR_CODE_GLARE_DOCUMENT": this.language == 'en'
            ? 'Glare detect in document'
            : '?????? ?????????? ???? ??????????????',
        "ACCURA_ERROR_CODE_HOLOGRAM": this.language == 'en'
            ? 'Hologram Detected'
            : '???? ?????????? ???? ???????? ???????????? ??????????????',
        "ACCURA_ERROR_CODE_DARK_DOCUMENT": this.language == 'en'
            ? 'Low lighting detected'
            : '???? ?????????? ???? ?????????? ????????????',
        "ACCURA_ERROR_CODE_PHOTO_COPY_DOCUMENT": this.language == 'en'
            ? 'Can not accept Photo Copy Document'
            : '???? ???????? ???????? ?????????? ?????? ??????????',
        "ACCURA_ERROR_CODE_FACE": this.language == 'en'
            ? 'Face not detected'
            : '???? ?????? ?????????? ???? ??????????',
        "ACCURA_ERROR_CODE_MRZ":
            this.language == 'en' ? 'MRZ not detected' : '???? ?????? ?????????? ???? MRZ',
        "ACCURA_ERROR_CODE_PASSPORT_MRZ": this.language == 'en'
            ? 'Passport MRZ not detected'
            : '???? ?????? ?????????? ???? MRZ ???????? ??????',
        "ACCURA_ERROR_CODE_ID_MRZ": this.language == 'en'
            ? 'ID card MRZ not detected'
            : '???? ?????? ?????????? ???? ?????????? ???????????? MRZ',
        "ACCURA_ERROR_CODE_VISA_MRZ": this.language == 'en'
            ? 'Visa MRZ not detected'
            : '???? ?????? ?????????? ???? Visa MRZ',
        "ACCURA_ERROR_CODE_WRONG_SIDE": this.language == 'en'
            ? 'Scanning wrong side of document'
            : '?????? ???????????? ?????????? ???? ??????????????',
        "ACCURA_ERROR_CODE_UPSIDE_DOWN_SIDE": this.language == 'en'
            ? 'Document is upside down. Place it properly'
            : '?????????????? ??????????. ?????? ???????? ????????',
        "IS_SHOW_LOGO": false,
        "SCAN_TITLE_OCR_FRONT": this.language == 'en'
            ? 'Scan Front Side of'
            : '?????? ???????????? ?????????????? ????',
        "SCAN_TITLE_OCR_BACK": this.language == 'en'
            ? 'Scan Back Side of'
            : '?????? ???????????? ???????????? ????',
        "SCAN_TITLE_OCR": this.language == 'en' ? 'Scan' : '??????',
        "SCAN_TITLE_BANKCARD":
            this.language == 'en' ? 'Scan Bank Card' : '?????? ?????????????? ????????????????',
        "SCAN_TITLE_BARCODE":
            this.language == 'en' ? 'Scan Barcode' : '?????? ?????????? ??????????????',
        "SCAN_TITLE_MRZ_PDF417_FRONT": this.language == 'en'
            ? 'Scan Front Side of Document'
            : '?????? ?????????? ?????????????? ??????????????',
        "SCAN_TITLE_MRZ_PDF417_BACK": this.language == 'en'
            ? 'Now Scan Back Side of Document'
            : '???????? ?????? ???????????? ???????????? ???? ??????????????',
        "SCAN_TITLE_DLPLATE":
            this.language == 'en' ? 'Scan Number Plate' : '?????? ?????? ????????????'
      };
      await FlutterAccuraKyc.setupAccuraConfig([config])
          .then((value) => {
                setState(() {
                  print("RESULT:- $value");
                })
              })
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
  }

  //Code for scan OCR document scanning with country & card information.
  Future<void> startOCR() async {
    try {
      var config = [
        {"enableLogs": false},
        countrySelected['id'],
        cardSelected['id'],
        cardSelected['name'],
        cardSelected['type'],
        getOrientation()
      ];
      print('startOCR:- $config');
      await FlutterAccuraKyc.startOcrWithCard(config)
          .then((value) => {
                setState(() {
                  _result = json.decode(value);
                  print("RESULT:- $_result");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResultScreen(data: _result)));
                })
              })
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
  }

  //Code for scan MRZ document with contry list & MRZ type
  Future<void> startMRZ() async {
    try {
      var config = [
        {"enableLogs": false},
        this.mrzSelected["value"],
        this.mrzCountryList,
        getOrientation()
      ];
      print('startMRZ:- $config');
      await FlutterAccuraKyc.startMRZ(config)
          .then((value) => {
                setState(() {
                  _result = json.decode(value);
                  print("RESULT:- $_result");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResultScreen(data: _result)));
                })
              })
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
  }

  //Code for scan Barcode with it type.
  Future<void> startBarcode() async {
    try {
      var config = [
        {"enableLogs": false},
        this.barcodeSelected["name"],
        getOrientation()
      ];
      print('startBarcode:- $config');
      await FlutterAccuraKyc.startBarcode(config)
          .then((value) => {
                setState(() {
                  _result = json.decode(value);
                  print("RESULT:- $_result");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResultScreen(data: _result)));
                })
              })
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
  }

  //Code for scan Bank card
  Future<void> startBankCard() async {
    try {
      var config = [
        {"enableLogs": false},
        getOrientation()
      ];
      print('startBankCard:- $config');
      await FlutterAccuraKyc.startBankCard(config)
          .then((value) => {
                setState(() {
                  _result = json.decode(value);
                  print("RESULT:- $_result");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResultScreen(data: _result)));
                })
              })
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
  }

  void onChangeMRZ(value) {
    setState(() {
      mrzSelected = mrzList.where((i) => i["label"] == value).first;
    });
  }

  void onChangeBarcode(value) {
    var selected =
        sdkConfig!['barcodes'].where((i) => i['name'] == value).first;
    print("SELECTED:- $selected");
    setState(() {
      barcodeSelected = selected;
    });
  }

  void onChangeCountry(value) {
    var selected =
        sdkConfig!['countries'].where((i) => i['name'] == value).first;
    List<String> tempList = [];
    for (var item in selected['cards']) {
      tempList.add(item['name']);
    }
    setState(() {
      countrySelected = selected;
      cardSelected = {};
      selectedCardString = "";
      ocrCardDropdownOptions = tempList;
    });
  }

  void onChangeCard(value) {
    var selectedCard =
        countrySelected['cards'].where((i) => i['name'] == value).first;
    setState(() {
      cardSelected = selectedCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    {
      print(MediaQuery.of(context).orientation.toString());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accura Flutter'),
        backgroundColor: Colors.red[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: sdkConfig == null
                  //It will display progress bar when app loading the licenses
                  ? CircularProgressIndicator()
                  : !sdkConfig['isValid']
                      //License is not valid
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/license.png",
                              height: 150,
                              width: 150,
                            ),
                            Text(
                              "License you provided for sacnning is invalid please visit www.accurascan.com for more information.",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      //License is not valid
                      : Column(
                          children: [
                            //Code for OCR
                            sdkConfig['isOCR']
                                ? Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Scan OCR Documents',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        DropdownSearch<String>(
                                            mode: Mode.MENU,
                                            showSearchBox: true,
                                            showSelectedItems: true,
                                            items: ocrCountryDropdownOptions,
                                            label: "Select Country",
                                            onChanged: (value) =>
                                                onChangeCountry(value),
                                            selectedItem: ""),
                                        Container(
                                          height: 20,
                                        ),
                                        DropdownSearch<String>(
                                            mode: Mode.MENU,
                                            showSelectedItems: true,
                                            items: ocrCardDropdownOptions,
                                            label: "Select Card",
                                            onChanged: (value) =>
                                                onChangeCard(value),
                                            selectedItem: selectedCardString),
                                        Container(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          onPressed:
                                              countrySelected.length != 0 &&
                                                      cardSelected.length != 0
                                                  ? () => {startOCR()}
                                                  : null,
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.red[800]),
                                          child: Text("START SCAN",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            Container(
                              height: 20,
                            ),
                            //Code for MRZ
                            sdkConfig['isMRZ']
                                ? Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Scan MRZ Documents',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        DropdownSearch<String>(
                                            mode: Mode.MENU,
                                            showSelectedItems: true,
                                            items: mrzDropdownOptions,
                                            label: "Select MRZ Type",
                                            onChanged: (value) =>
                                                onChangeMRZ(value),
                                            selectedItem: ""),
                                        Container(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          onPressed: mrzSelected.length != 0
                                              ? () => {startMRZ()}
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.red[800]),
                                          child: Text("START SCAN",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),

                            Container(
                              height: 20,
                            ),
                            //Code for Barcode
                            sdkConfig['isBarcode']
                                ? Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Scan Barcode Documents',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        DropdownSearch<String>(
                                            mode: Mode.MENU,
                                            showSelectedItems: true,
                                            items: barcodeDropdownOptions,
                                            label: "Select Barcode Type",
                                            popupItemDisabled: (String s) =>
                                                s.startsWith('I'),
                                            onChanged: (value) =>
                                                onChangeBarcode(value),
                                            selectedItem: ""),
                                        Container(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          onPressed: barcodeSelected.length != 0
                                              ? () => {startBarcode()}
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.red[800]),
                                          child: Text("START SCAN",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),

                            Container(
                              height: 20,
                            ),
                            //Code for Bankcard
                            sdkConfig['isBankCard']
                                ? Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Scan Bankcard',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        Text(
                                          'You can scan any bank card here by tap on "START SCAN" button.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600]),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          onPressed: () => {startBankCard()},
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.red[800]),
                                          child: Text("START SCAN",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
