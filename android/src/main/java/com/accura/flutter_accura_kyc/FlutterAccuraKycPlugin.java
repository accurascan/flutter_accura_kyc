package com.accura.flutter_accura_kyc;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import com.accurascan.ocr.mrz.model.BarcodeFormat;
import com.accurascan.ocr.mrz.model.ContryModel;
import com.accurascan.ocr.mrz.util.AccuraLog;
import com.androidnetworking.AndroidNetworking;
import com.docrecog.scan.RecogEngine;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

/** FlutterAccuraKycPlugin */
public class FlutterAccuraKycPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  public static final String NAME = "AccuraKyc";
  public static Bitmap face1 = null;
  public static Bitmap face2 = null;
  public static Result faceCL = null;
  public static Result ocrCL = null;
  public static boolean ocrCLProcess = false;
  public static boolean isLivenessGetVideo = false;
  public static String livenessVideo = "";
  public static final String CAMERA = Manifest.permission.CAMERA;
  public static final String WRITE = Manifest.permission.WRITE_EXTERNAL_STORAGE;
  public static final int SEARCH_REQ_CODE = 0;
  private static final String TAG = OcrActivity.class.getSimpleName();
  private final String defaultAppOrientation = "portrait";
  public static JSONObject messagesConf = null;

  public static Result pCallbackContext = null;
  public static MethodCall pMethodCall = null;
  public static JSONArray pArgs = null;
  public static String pAction = null;
  public static final int MY_PERMISSIONS_REQUEST_CAMERA = 100;
  private static final int MY_PERMISSIONS_REQUEST_WRITE = 101;

  private static Context appContext = null;
  private static Activity appActivity = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    appContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_accura_kyc");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    try {

      if (call.method.equals("getPlatformVersion")) {

        result.success("Android " + android.os.Build.VERSION.RELEASE);
      } else if (call.method.equals("getMetaData")) {
        getMetaData(result);
      } else if (call.method.equals("cleanFaceMatch")) {

        //Code for clean face match data. 
        FlutterAccuraKycPlugin.face1 = null;
        FlutterAccuraKycPlugin.face2 = null;
        FlutterAccuraKycPlugin.isLivenessGetVideo = false;
        FlutterAccuraKycPlugin.livenessVideo = "";
        return;
      } else {

        String JSON_STRING = call.argument("arguments");
        JSONArray args = (new JSONArray(JSON_STRING));
        JSONObject accuraConf = args.getJSONObject(0);
        
        if (accuraConf.has("enableLogs")) {
          boolean isLogEnable = accuraConf.getBoolean("enableLogs");
        }

        if (call.method.equals("setupAccuraConfig")) {
          setupAccuraConfig(args, result);
        } else if (call.method.equals("startOcrWithCard")) {
          startOcrWithCard(args, result);
        } else if (call.method.equals("startMRZ")) {
          startMRZ(args, result);
        } else if (call.method.equals("startBankCard")) {
          startBankCard(args, result);
        } else if (call.method.equals("startBarcode")) {
          startBarcode(args, result);
        } else if (call.method.equals("startFaceMatch")) {
          startFaceMatch(args, result);
        } else if (call.method.equals("startLiveness")) {
          startLiveness(args, result);
        }
      }
    } catch (JSONException e) {
      e.printStackTrace();
    }
  }

  //Code for get Android license information from SDK.
  public void getMetaData(Result result) throws JSONException {

    ocrCL = result;
    RecogEngine recogEngine = new RecogEngine();
    AccuraLog.enableLogs(false);
    recogEngine.setDialog(false);
    JSONObject results = new JSONObject();
    RecogEngine.SDKModel sdkModel = recogEngine.initEngine(appContext);
    if (sdkModel.i >= 0) {
     AndroidNetworking.initialize(appContext, UnsafeOkHttpClient.getUnsafeOkHttpClient());
      results.put("sdk_version", recogEngine.getVersion());
      results.put("isValid", true);
      // if OCR enable then get card list
      if (sdkModel.isOCREnable) {
        results.put("isOCR", true);
        List<ContryModel> modelList = recogEngine.getCardList(appActivity);
        JSONArray countries = new JSONArray();
        for (int i = 0; i < modelList.size(); i++) {
          JSONObject country = new JSONObject();
          country.put("name", modelList.get(i).getCountry_name());
          country.put("id", modelList.get(i).getCountry_id());
          JSONArray cards = new JSONArray();
          List<ContryModel.CardModel> cardList = modelList.get(i).getCards();
          for (int j = 0; j < cardList.size(); j++) {
            JSONObject card = new JSONObject();
            card.put("name", cardList.get(j).getCard_name());
            card.put("id", cardList.get(j).getCard_id());
            card.put("type", cardList.get(j).getCard_type());
            cards.put(card);
          }
          country.put("cards", cards);
          countries.put(country);
        }
        results.put("countries", countries);
      }
      results.put("isOCREnable", sdkModel.isOCREnable);
      results.put("isBarcode", sdkModel.isAllBarcodeEnable);
      if (sdkModel.isAllBarcodeEnable) {
        List<BarcodeFormat> CODE_NAMES = BarcodeFormat.getList();
        JSONArray barcodes = new JSONArray();
        for (int i = 0; i < CODE_NAMES.size(); i++) {
          JSONObject barcode = new JSONObject();
          barcode.put("name", CODE_NAMES.get(i).barcodeTitle);
          barcode.put("type", CODE_NAMES.get(i).formatsType);
          barcodes.put(barcode);
        }
        results.put("barcodes", barcodes);
      }
      results.put("isBankCard", sdkModel.isBankCardEnable);
      results.put("isMRZ", sdkModel.isMRZEnable);
    } else {
      results.put("isValid", false);
    }
    Log.i(TAG, "RESULT:- " + results.toString());
    result.success(results.toString());
    return;
  }

  //Code for setup SDK config and custom messages.
  public void setupAccuraConfig(JSONArray args, Result result) throws JSONException {

    ocrCL = result;
    JSONObject messagesConf = args.getJSONObject(0);
    FlutterAccuraKycPlugin.messagesConf = messagesConf;
    result.success("Messages setup successfully");
    return;
  }

  //Code for scan OCR documents with country & card info in Android.
  public void startOcrWithCard(JSONArray args, Result result) throws JSONException {

    ocrCL = result;
    JSONObject accuraConf = args.getJSONObject(0);
    int country = args.getInt(1);
    int card = args.getInt(2);
    String cardName = args.getString(3);
    int cardType = args.getInt(4);
    String appOrientation = args.length() > 5 ? args.getString(5) : defaultAppOrientation;
    Intent myIntent = new Intent(appActivity, OcrActivity.class);
    myIntent = addDefaultConfigs(myIntent, accuraConf);
    myIntent.putExtra("app_orientation", appOrientation);
    myIntent.putExtra("type", "ocr");
    myIntent.putExtra("country_id", country);
    myIntent.putExtra("card_id", card);
    myIntent.putExtra("card_name", cardName);
    myIntent.putExtra("card_type", cardType);
    appActivity.startActivity(myIntent);
    return;
  }

  //Code for scan MRZ documents in Android.
  public void startMRZ(JSONArray args, Result result) throws JSONException {

    ocrCL = result;
    JSONObject accuraConf = args.getJSONObject(0);
    String type = args.getString(1);
    String countryList = args.getString(2);
    String appOrientation = args.length() > 3 ? args.getString(3) : defaultAppOrientation;
    Intent myIntent = new Intent(appActivity, OcrActivity.class);
    myIntent = addDefaultConfigs(myIntent, accuraConf);
    myIntent.putExtra("type", "mrz");
    myIntent.putExtra("country-list", countryList);
    myIntent.putExtra("sub-type", type);
    myIntent.putExtra("app_orientation", appOrientation);

    myIntent.addCategory( Intent.CATEGORY_HOME );
    myIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

    appActivity.startActivity(myIntent);
    return;
  }

  //Code for scan bank card in Android.
  public void startBankCard(JSONArray args, Result result) throws JSONException {

    ocrCL = result;
    JSONObject accuraConf = args.getJSONObject(0);
    Intent myIntent = new Intent(appActivity, OcrActivity.class);
    String appOrientation = args.length() > 1 ? args.getString(1) : defaultAppOrientation;
    myIntent = addDefaultConfigs(myIntent, accuraConf);
    myIntent.putExtra("type", "bankcard");
    myIntent.putExtra("app_orientation", appOrientation);
    appActivity.startActivity(myIntent);
    return;
  }

  //Code for scan barcode in Android.
  public void startBarcode(JSONArray args, Result result) throws JSONException {

    ocrCL = result;
    JSONObject accuraConf = args.getJSONObject(0);
    String type = args.getString(1);
    String appOrientation = args.length() > 2 ? args.getString(2) : defaultAppOrientation;
    Intent myIntent = new Intent(appActivity, OcrActivity.class);
    myIntent = addDefaultConfigs(myIntent, accuraConf);
    myIntent.putExtra("type", "barcode");
    myIntent.putExtra("sub-type", type);
    myIntent.putExtra("app_orientation", appOrientation);
    appActivity.startActivity(myIntent);
    return;
  }

  //Code for start face match check
  public void startFaceMatch(JSONArray args, Result result) throws JSONException {

    faceCL = result;
    JSONObject accuraConf = args.getJSONObject(0);
    JSONObject config = args.getJSONObject(1);
    String appOrientation = args.length() > 2 ? args.getString(2) : defaultAppOrientation;
    Intent intent = new Intent(appActivity, FaceMatchActivity.class);
    intent = addDefaultConfigs(intent, accuraConf);
    intent = addDefaultConfigs(intent, config);
    intent.putExtra("app_orientation", appOrientation);
    intent.putExtra("type", "fm");
    appActivity.startActivity(intent);
    return;
  }

  //Code for start liveness check
  public void startLiveness(JSONArray args, Result result) throws JSONException {

    faceCL = result;
    JSONObject accuraConf = args.getJSONObject(0);
    JSONObject config = args.getJSONObject(1);
    String appOrientation = args.length() > 2 ? args.getString(2) : defaultAppOrientation;
    Intent intent = new Intent(appActivity, FaceMatchActivity.class);
    intent = addDefaultConfigs(intent, accuraConf);
    intent = addDefaultConfigs(intent, config);
    intent.putExtra("app_orientation", appOrientation);
    intent.putExtra("type", "lv");
    appActivity.startActivity(intent);
    return;
  }

  public Intent addDefaultConfigs(Intent intent, JSONObject config) {
    Iterator<String> iter = config.keys();
    while (iter.hasNext()) {
      String key = iter.next();
      try {
        if (config.get(key) instanceof String) {
          intent.putExtra(key, config.getString(key));
        }
        if (config.get(key) instanceof Boolean) {
          intent.putExtra(key, config.getBoolean(key));
        }
        if (config.get(key) instanceof Integer) {
          intent.putExtra(key, config.getInt(key));
        }
        if (config.get(key) instanceof Double) {
          intent.putExtra(key, config.getDouble(key));
        }
      } catch (JSONException e) {
        e.printStackTrace();
      }

    }
    return intent;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public static String getSaltString() {
    String SALTCHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    StringBuilder salt = new StringBuilder();
    Random rnd = new Random();
    while (salt.length() < 18) { // length of the random string.
      int index = (int) (rnd.nextFloat() * SALTCHARS.length());
      salt.append(SALTCHARS.charAt(index));
    }
    return salt.toString();
  }

  public static Bitmap getBitmap(ContentResolver cr, Uri url)
          throws FileNotFoundException, IOException {
    InputStream input = cr.openInputStream(url);
    Bitmap bitmap = BitmapFactory.decodeStream(input);
    input.close();
    return bitmap;
  }

  public static Bitmap getBase64ToBitmap(String base64Image) {

    byte[] decodedString = Base64.decode(base64Image, Base64.DEFAULT);
    Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
    return decodedByte;
  }

  public static String getImageUri(Bitmap bitmap, String name, String path) {
    OutputStream fOut = null;
    File file = new File(path, getSaltString() + "_" + name + ".jpg");
    try {
      fOut = new FileOutputStream(file);
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    }
    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
    try {
      fOut.flush(); // Not really required
      fOut.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    return "file://"+file.getAbsolutePath();
  }


  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    appActivity = binding.getActivity();
    Log.i(TAG, "appActivity:- "+ appActivity);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    appActivity = binding.getActivity();
    Log.i(TAG, "appActivity:- "+ appActivity);
  }

  @Override
  public void onDetachedFromActivity() {

  }
}
