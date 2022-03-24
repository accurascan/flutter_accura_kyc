import UIKit
import AccuraKYC

//View controller for face match.
class FMController: UIViewController {
    
    var livenessConfigs:[String: Any] = [:]
    var callBack: FlutterResult? = nil
    var reactViewController:UIViewController? = nil
    var audioPath: URL? = nil
    var isFacematchDone = false
    var isCalledCallBack = false
    
    func closeMe() {
//        self.win!.rootViewController = reactViewController!
        self.dismiss(animated: true) {}
    }
    var win: UIWindow? = nil
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if ScanConfigs.accuraConfigs.index(forKey: "with_face") != nil {
            gl.withFace = ScanConfigs.accuraConfigs["with_face"] as! Bool
            if gl.withFace {
                if ScanConfigs.accuraConfigs.index(forKey: "face_uri") != nil {
                    if let face = SwiftFlutterAccuraKycPlugin.getImageFromUri(path: ScanConfigs.accuraConfigs["face_uri"] as! String) {
                        gl.face1 = face
                        gl.face1Detect = EngineWrapper.detectSourceFaces(gl.face1)
                    }
                }
                if ScanConfigs.accuraConfigs.index(forKey: "face_base64") != nil {
                    let newImageData = Data(base64Encoded: ScanConfigs.accuraConfigs["face_base64"] as! String)
                    if let newImageData = newImageData {
                        gl.face1 = UIImage(data: newImageData)
                        gl.face1Detect = EngineWrapper.detectSourceFaces(gl.face1)
                    }
                }
            } else {
                if ScanConfigs.accuraConfigs.index(forKey: "face1") == nil {
                    
                    callBack!(FlutterError.init(code: "101", message: "Missing face1 configration", details: nil))
                    closeMe()
                    return
                }
                if ScanConfigs.accuraConfigs.index(forKey: "face2") != nil {
                    let isFace2 = ScanConfigs.accuraConfigs["face2"] as! Bool
                    if isFace2 {
                        if gl.face1 == nil {
                            
                            callBack!(FlutterError.init(code: "101", message: "Please first take Face1 Photo", details: nil))
                            closeMe()
                            return
                        } else {
                            gl.face1Detect = EngineWrapper.detectSourceFaces(gl.face1)
                        }
                    }
                } else {
                    
                    callBack!(FlutterError.init(code: "101", message: "Missing face2 configration", details: nil))
                    closeMe()
                    return
                }
            }
            
        } else {
            
            callBack!(FlutterError.init(code: "101", message: "Missing with_face configration", details: nil))
            closeMe()
            return
        }
        if (!isCalledCallBack) {
            isCalledCallBack = true
            startFC()
        }
    }
    
    func startFC() {
        let facematch = Facematch()
        // To customize your screen theme and feed back messages
        facematch.setBackGroundColor(FaceMatchConfigs.backgroundColor)
        if livenessConfigs["livenessBackground"] != nil {
            facematch.setBackGroundColor(livenessConfigs["livenessBackground"] as! String)
        }
        facematch.setCloseIconColor(LivenessConfigs.livenessCloseIconColor)
        if livenessConfigs["livenessCloseIconColor"] != nil {
            facematch.setCloseIconColor(livenessConfigs["livenessCloseIconColor"] as! String)
        }
        facematch.setFeedbackBackGroundColor(LivenessConfigs.livenessfeedbackBackground)
        if livenessConfigs["livenessfeedbackBackground"] != nil {
            facematch.setFeedbackBackGroundColor(livenessConfigs["livenessfeedbackBackground"] as! String)
        }
        facematch.setFeedbackTextColor(LivenessConfigs.livenessfeedbackTextColor)
        if livenessConfigs["livenessfeedbackTextColor"] != nil {
            facematch.setFeedbackTextColor(livenessConfigs["livenessfeedbackTextColor"] as! String)
        }
        facematch.setFeedbackTextSize(Float(LivenessConfigs.feedbackTextSize))
        if livenessConfigs["feedbackTextSize"] != nil {
            facematch.setFeedbackTextSize(livenessConfigs["feedbackTextSize"] as! Float)
        }
        facematch.setFeedBackframeMessage(LivenessConfigs.feedBackframeMessage)
        if livenessConfigs["feedBackframeMessage"] != nil {
            facematch.setFeedBackframeMessage(livenessConfigs["feedBackframeMessage"] as! String)
        }
        facematch.setFeedBackAwayMessage(LivenessConfigs.feedBackAwayMessage)
        if livenessConfigs["feedBackAwayMessage"] != nil {
            facematch.setFeedBackAwayMessage(livenessConfigs["feedBackAwayMessage"] as! String)
        }
        facematch.setFeedBackOpenEyesMessage(LivenessConfigs.feedBackOpenEyesMessage)
        if livenessConfigs["feedBackOpenEyesMessage"] != nil {
            facematch.setFeedBackOpenEyesMessage(livenessConfigs["feedBackOpenEyesMessage"] as! String)
        }
        facematch.setFeedBackCloserMessage(LivenessConfigs.feedBackCloserMessage)
        if livenessConfigs["feedBackCloserMessage"] != nil {
            facematch.setFeedBackCloserMessage(livenessConfigs["feedBackCloserMessage"] as! String)
        }
        facematch.setFeedBackCenterMessage(LivenessConfigs.feedBackCenterMessage)
        if livenessConfigs["feedBackCenterMessage"] != nil {
            facematch.setFeedBackCenterMessage(livenessConfigs["feedBackCenterMessage"] as! String)
        }
        facematch.setFeedbackMultipleFaceMessage(LivenessConfigs.feedBackMultipleFaceMessage)
        if livenessConfigs["feedBackMultipleFaceMessage"] != nil {
            facematch.setFeedbackMultipleFaceMessage(livenessConfigs["feedBackMultipleFaceMessage"] as! String)
        }
        facematch.setFeedBackFaceSteadymessage(LivenessConfigs.feedBackHeadStraightMessage)
        if livenessConfigs["feedBackHeadStraightMessage"] != nil {
            facematch.setFeedBackFaceSteadymessage(livenessConfigs["feedBackHeadStraightMessage"] as! String)
        }
        facematch.setFeedBackLowLightMessage(LivenessConfigs.feedBackLowLightMessage)
        if livenessConfigs["feedBackLowLightMessage"] != nil {
            facematch.setFeedBackLowLightMessage(livenessConfigs["feedBackLowLightMessage"] as! String)
        }
        facematch.setFeedBackBlurFaceMessage(LivenessConfigs.feedBackBlurFaceMessage)
        if livenessConfigs["feedBackBlurFaceMessage"] != nil {
            facematch.setFeedBackBlurFaceMessage(livenessConfigs["feedBackBlurFaceMessage"] as! String)
        }
        facematch.setFeedBackGlareFaceMessage(LivenessConfigs.feedBackGlareFaceMessage)
        if livenessConfigs["feedBackGlareFaceMessage"] != nil {
            facematch.setFeedBackGlareFaceMessage(livenessConfigs["feedBackGlareFaceMessage"] as! String)
        }
        facematch.setFeedBackProcessingMessage(LivenessConfigs.feedBackProcessingMessage)
        if livenessConfigs.index(forKey: "feedBackProcessingMessage") != nil {
            facematch.setFeedBackProcessingMessage(livenessConfigs["feedBackProcessingMessage"] as! String)
        }
        facematch.isShowLogoImage(LivenessConfigs.isShowLogo)
        if livenessConfigs.index(forKey: "isShowLogo") != nil {
            facematch.isShowLogoImage(livenessConfigs["isShowLogo"] as! Bool)
        }
        facematch.setLogoImage("ic_logo.png")
        
        // 0 for clean face and 100 for Blurry face
        facematch.setBlurPercentage(Int32(LivenessConfigs.setBlurPercentage)) // set blure percentage -1 to remove this filter
        
        if livenessConfigs["setBlurPercentage"] != nil {
            facematch.setBlurPercentage(livenessConfigs["setBlurPercentage"] as! Int32)
        }
        
        var glarePerc0 = Int32(LivenessConfigs.setGlarePercentage_0)
        if livenessConfigs["setGlarePercentage_0"] != nil {
            glarePerc0 = livenessConfigs["setGlarePercentage_0"] as! Int32
        }
        var glarePerc1 = Int32(LivenessConfigs.setGlarePercentage_1)
        if livenessConfigs["setGlarePercentage_1"] != nil {
            glarePerc1 = livenessConfigs["setGlarePercentage_1"] as! Int32
        }
        // Set min and max percentage for glare
        facematch.setGlarePercentage(glarePerc0, glarePerc1) //set glaremin -1 and glaremax -1 to remove this filter
        // Do any additional setup after loading the view.
        facematch.setFacematch(self)
    }
}

extension FMController: FacematchData {
    
    func facematchViewDisappear() {
        print("CALL facematchViewDisappear")
        if !isFacematchDone {
            closeMe()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if (!self.isCalledCallBack) {
                    self.isCalledCallBack = true
                    self.callBack!(FlutterError.init(code: "101", message: "User decline face match", details: nil))
                }
            }
        }
        if gl.face2 != nil {
            EngineWrapper.faceEngineClose()
        }
    }
    
    func facematchData(_ FaceImage: UIImage!) {
        
        print("CALL facematchData")
        isCalledCallBack = true
        isFacematchDone = true
        if gl.face1 == nil {
            var results:[String: Any] = [:]
            results["status"] = false
            results["with_face"] = gl.withFace
            gl.face1 = FaceImage
            if gl.face1Detect == nil {
                if let img1 = SwiftFlutterAccuraKycPlugin.getImageUri(img: gl.face1!, name: nil) {
                    results["img_1"] = img1
                }
            } else {
                if let img1 = SwiftFlutterAccuraKycPlugin.getImageUri(img: SwiftFlutterAccuraKycPlugin.resizeImage(image: gl.face1!, targetSize: gl.face1Detect!.bound), name: nil) {
                    results["img_1"] = img1
                }
            }
            if results.index(forKey: "img_1") != nil {
                
                callBack!(SwiftFlutterAccuraKycPlugin.convertJSONString(results: results))
            } else {
                
                callBack!(FlutterError.init(code: "101", message: "Error found in data. Please try again", details: nil))
            }
            closeMe()
            
        } else {
            gl.face1Detect = EngineWrapper.detectSourceFaces(gl.face1)
            gl.face2 = FaceImage
            gl.face2Detect = EngineWrapper.detectTargetFaces(FaceImage, feature1: gl.face1Detect!.feature)
            let score = EngineWrapper.identify(gl.face1Detect!.feature, featurebuff2: gl.face2Detect!.feature)
            var results:[String: Any] = [:]
            results["status"] = true
            results["score"] = score*100
            results["with_face"] = gl.withFace
            if !gl.withFace {
                if let img1 = SwiftFlutterAccuraKycPlugin.getImageUri(img: gl.face1!, name: nil) {
                    results["img_1"] = img1
                }
                if let img2 = SwiftFlutterAccuraKycPlugin.getImageUri(img: gl.face2!, name: nil) {
                    results["img_2"] = img2
                }
            } else {
                if let img1 = SwiftFlutterAccuraKycPlugin.getImageUri(img: SwiftFlutterAccuraKycPlugin.resizeImage(image: gl.face2!, targetSize: gl.face2Detect!.bound), name: nil) {
                    results["detect"] = img1
                }
            }
            
            callBack!(SwiftFlutterAccuraKycPlugin.convertJSONString(results: results))
            SwiftFlutterAccuraKycPlugin.cleanFaceData()
            closeMe()
        }
    }
}
