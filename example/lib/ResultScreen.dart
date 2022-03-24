import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accura_kyc/flutter_accura_kyc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key, this.data}) : super(key: key);

  final dynamic data;

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  var scrollController = new ScrollController();
  String language = 'en';
  String facematchURI = '';
  dynamic _result = {'isValid': false};
  double fontsize = 16;

  String matchFileURL = '';
  String livenessScore = '0.0';
  String faceMatchScore = '0.0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      facematchURI = widget.data['face'].toString();
    });
    print("DATA FROM OTHER SCREEN");
    print(widget.data);
  }

  void showFlutterToast(msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  String getOrientation() {
    if (MediaQuery.of(context).orientation.toString().contains('landscape')) {
      return 'landscape';
    }
    return 'portrait'; //MediaQuery.of(context).orientation.toString();
  }

  //Code for Face match custom with messages & face config.
  Future<void> startFaceMatch() async {
    try {
      var accuraConfs = {
        "enableLogs": false,
        "with_face": true,
        "face_uri": this.facematchURI
      };
      var config = {
        "feedbackTextSize": 18,
        "feedBackLowLightMessage": this.language == 'en'
            ? 'Low light detected'
            : 'تم الكشف عن إضاءة منخفضة',
        "feedBackStartMessage": this.language == 'en'
            ? 'Put your face inside the oval'
            : 'ضع وجهك داخل الشكل البيضاوي',
        "feedBackframeMessage":
            this.language == 'en' ? 'Frame Your Face' : 'ضع إطارًا لوجهك',
        "feedBackAwayMessage":
            this.language == 'en' ? 'Move Phone Away' : 'انقل الهاتف بعيدًا',
        "feedBackOpenEyesMessage":
            this.language == 'en' ? 'Keep Your Eyes Open' : 'أبق أعينك مفتوحة',
        "feedBackCloserMessage":
            this.language == 'en' ? 'Move Phone Closer' : 'نقل الهاتف أقرب',
        "feedBackCenterMessage":
            this.language == 'en' ? 'Move Phone Center' : 'نقل مركز الهاتف',
        "feedBackMultipleFaceMessage": this.language == 'en'
            ? 'Multiple Face Detected'
            : 'تم اكتشاف وجوه متعددة',
        "feedBackHeadStraightMessage": this.language == 'en'
            ? 'Keep Your Head Straight'
            : 'حافظ على استقامة رأسك',
        "feedBackBlurFaceMessage": this.language == 'en'
            ? 'Blur Detected Over Face'
            : 'تم اكتشاف ضبابية على الوجه',
        "feedBackGlareFaceMessage":
            this.language == 'en' ? 'Glare Detected' : 'تم الكشف عن الوهج',
        // <!--// 0 for clean face and 100 for Blurry face or set it -1 to remove blur filter-->
        "setBlurPercentage": 99,
        // <!--// Set min percentage for glare or set it -1 to remove glare filter-->
        "setGlarePercentage_0": -1,
        // <!--// Set max percentage for glare or set it -1 to remove glare filter-->
        "setGlarePercentage_1": -1,
        "isShowLogo": true,
        "feedBackProcessingMessage":
            this.language == 'en' ? 'Processing...' : 'يعالج...',
      };
      print('CONFIG $accuraConfs $config');
      await FlutterAccuraKyc.startFaceMatch(
              [accuraConfs, config, getOrientation()])
          .then((value) => {
                setState(() {
                  _result = json.decode(value);
                  print("RESULT:- $_result");
                  matchFileURL = _result['detect'].toString();
                  livenessScore = '0.0';
                  faceMatchScore = _result['score'].toString();
                })
              })
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
  }

  //Code for liveness with custom messages & face config.
  Future<void> startLiveness() async {
    try {
      var accuraConfs = {
        "enableLogs": false,
        "with_face": true,
        "face_uri": this.facematchURI
      };
      var config = {
        "feedbackTextSize": 18,
        "feedBackframeMessage":
            this.language == 'en' ? 'Frame Your Face' : 'ضع إطارًا لوجهك',
        "feedBackAwayMessage":
            this.language == 'en' ? 'Move Phone Away' : 'انقل الهاتف بعيدًا',
        "feedBackOpenEyesMessage":
            this.language == 'en' ? 'Keep Your Eyes Open' : 'أبق أعينك مفتوحة',
        "feedBackCloserMessage":
            this.language == 'en' ? 'Move Phone Closer' : 'نقل الهاتف أقرب',
        "feedBackCenterMessage":
            this.language == 'en' ? 'Move Phone Center' : 'نقل مركز الهاتف',
        "feedBackMultipleFaceMessage": this.language == 'en'
            ? 'Multiple Face Detected'
            : 'تم اكتشاف وجوه متعددة',
        "feedBackHeadStraightMessage": this.language == 'en'
            ? 'Keep Your Head Straight'
            : 'حافظ على استقامة رأسك',
        "feedBackBlurFaceMessage": this.language == 'en'
            ? 'Blur Detected Over Face'
            : 'تم اكتشاف ضبابية على الوجه',
        "feedBackGlareFaceMessage":
            this.language == 'en' ? 'Glare Detected' : 'تم الكشف عن الوهج',
        // <!--// 0 for clean face and 100 for Blurry face or set it -1 to remove blur filter-->
        "setBlurPercentage": 99,
        // <!--// Set min percentage for glare or set it -1 to remove glare filter-->
        "setGlarePercentage_0": -1,
        // <!--// Set max percentage for glare or set it -1 to remove glare filter-->
        "setGlarePercentage_1": -1,
        "isSaveImage": true,
        "liveness_url": 'your liveness url',
        // <!--// set containt type of your liveness url. like "form_data" or "raw_data". Default containt type is "form_data" -->
        "contentType": 'form_data',
        //        New SDK changes in configs
        "feedBackLowLightMessage": this.language == 'en'
            ? 'Low light detected'
            : 'تم الكشف عن إضاءة منخفضة',
        "feedbackLowLightTolerence": 39,
        "feedBackStartMessage": this.language == 'en'
            ? 'Put your face inside the oval'
            : 'ضع وجهك داخل الشكل البيضاوي',
        "feedBackLookLeftMessage": this.language == 'en'
            ? 'Look over your left shoulder'
            : 'انظر فوق كتفك الأيسر',
        "feedBackLookRightMessage": this.language == 'en'
            ? 'Look over your right shoulder'
            : 'انظر فوق كتفك الأيمن',
        "feedBackOralInfoMessage": this.language == 'en'
            ? 'Say each digits out loud'
            : 'قل كل رقم بصوت عالٍ',
        "feedBackProcessingMessage":
            this.language == 'en' ? 'Processing...' : 'يعالج...',
        "enableOralVerification": false,
        "codeTextColor": 'white',
        "isShowLogo": true
      };
      print('CONFIG $accuraConfs $config');
      await FlutterAccuraKyc.startLiveness(
              [accuraConfs, config, getOrientation()])
          .then((value) => {
                setState(() {
                  _result = json.decode(value);
                  print("RESULT:- $_result");
                  matchFileURL = _result['detect'].toString();
                  livenessScore = _result['score'].toString();
                  faceMatchScore = _result['fm_score'].toString();
                })
              })
          .onError((error, stackTrace) =>
              {showFlutterToast("Error :" + error.toString())});
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accura Result"),
        backgroundColor: Colors.red[800],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 12,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        child: Column(children: [
                          getImageOnDocument(),
                          getDataWidgets(),
                          getMRZDataWidgets(),
                          getImagesWidgets(),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //Code for display face images.
  Widget getImageOnDocument() {
    return new Column(
      children: [
        widget.data['face'] != null
            ? Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: 100,
                        child: Image.file(
                          new File(widget.data['face']
                              .toString()
                              .replaceAll('file:///', '')),
                        ),
                      ),
                      matchFileURL != ''
                          ? Container(
                              margin: EdgeInsets.only(left: 50),
                              height: 150,
                              width: 100,
                              child: Image.file(
                                new File(
                                    matchFileURL.replaceAll('file:///', '')),
                              ),
                            )
                          : Container()
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0),
                                ),
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, right: 20, left: 20),
                                primary: Colors.red[800]),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/ic_liveness.png",
                                  height: 30,
                                  width: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "LIVENESS",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () {
                              startLiveness();
                            },
                          ),
                          Visibility(
                            visible: true,
                            child: livenessScore != ''
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        double.parse(livenessScore)
                                                .toStringAsFixed(2)
                                                .toString() +
                                            "%",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ],
                                  )
                                : Container(),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0),
                                ),
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, right: 20, left: 20),
                                primary: Colors.red[800]),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/ic_facematch.png",
                                  height: 30,
                                  width: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "FACEMATCH",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () {
                              startFaceMatch();
                            },
                          ),
                          Visibility(
                            visible: faceMatchScore != "" ? true : false,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  double.parse(faceMatchScore)
                                          .toStringAsFixed(2)
                                          .toString() +
                                      "%",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  //Code for display document image for front & back.
  Widget getImagesWidgets() {
    return new Column(
        children: ["front_img", "back_img"]
            .map(
              (e) => (widget.data[e] != null && widget.data[e].length != 0
                  ? Column(
                      children: [
                        Container(
                          color: Colors.grey.withOpacity(0.5),
                          child: Text(
                            e == 'front_img' ? 'FRONT SIDE' : 'BACK SIDE',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding:
                              EdgeInsets.only(top: 15, bottom: 15, left: 10),
                        ),
                        Image.file(
                          new File(widget.data[e]
                              .toString()
                              .replaceAll('file:///', '')),
                        ),
                      ],
                    )
                  : Container()),
            )
            .toList());
  }

  //Code for display MRZ, OCR, Barcode, BankCard data
  Widget getDataWidgets() {
    return new Column(
        children: ["front_data", "back_data"]
            .map(
              (e) => (widget.data[e] != null && widget.data[e].length != 0
                  ? Column(
                      children: [
                        Container(
                          color: Colors.grey.withOpacity(0.5),
                          child: Text(
                            e == 'front_data'
                                ? getResultType(widget.data['type'])
                                : 'OCR Back',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding:
                              EdgeInsets.only(top: 15, bottom: 15, left: 10),
                        ),
                        getSubDataWidgets(e)
                      ],
                    )
                  : Container()),
            )
            .toList());
  }

  Widget getSubDataWidgets(key) {
    List<Widget> list = [];

    if (widget.data[key] != null) {
      widget.data[key].forEach((k, v) => {
            if (!k.toString().contains('_img'))
              {
                list.add(new Table(
                  border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.red, width: 1),
                      outside: BorderSide(color: Colors.red, width: 0.5)),
                  children: [
                    TableRow(children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(k.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize)),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: k != "signature"
                                ? Text(v.toString(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontsize))
                                : Image.file(
                                    new File(v
                                        .toString()
                                        .replaceAll('file:///', '')),
                                  ),
                          ),
                        ),
                      )
                    ]),
                  ],
                ))
              }
          });
    }
    return new Column(children: list);
  }

  Widget getMRZDataWidgets() {
    List<Widget> list = [];

    if (widget.data['mrz_data'] != null) {
      widget.data['mrz_data'].forEach((k, v) => {
            if (!k.toString().contains('_img'))
              {
                list.add(new Table(
                  border: TableBorder.all(color: Color(0xFFD32D39)),
                  children: [
                    TableRow(children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(k.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize)),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: k != "signature"
                                ? Text(v.toString(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontsize))
                                : Image.file(
                                    new File(v
                                        .toString()
                                        .replaceAll('file:///', '')),
                                  ),
                          ),
                        ),
                      )
                    ]),
                  ],
                ))
              }
          });
    }
    return new Column(children: list);
  }

  String getResultType(type) {
    switch (type) {
      case "BANKCARD":
        return "Bank Card Data";
      case "DL_PLATE":
        return "Vehicle Plate";
      case "BARCODE":
        return "Barcode Data";
      case "PDF417":
        return "PDF417 Barcode";
      case "OCR":
        return "OCR Front";
      case "MRZ":
        return "MRZ";
      case "BARCODEPDF417":
        return "USA DL Result";
      default:
        return "Front Side";
    }
  }
}
