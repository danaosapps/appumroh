import 'dart:convert';
import 'dart:math';
import 'package:appumroh/group_info.dart';
import 'package:appumroh/private_message.dart';
import 'package:appumroh/reset_password.dart';
import 'package:appumroh/verify_email.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';
import 'package:uuid/uuid.dart';
import 'package:restart_app/restart_app.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:shutdown/shutdown.dart' as shutdown;
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'home.dart';

class Global {
	static const PROTOCOL = "http";
	//static const HOST = "192.168.22.115";
	static const HOST = "dev.jtindonesia.com";
	//static const WS_SERVER = "192.168.22.115";
	static const WS_SERVER = "49.50.10.47";
	static const API_URL = PROTOCOL+"://"+HOST+"/appumroh_web";
	static const USERDATA_URL = PROTOCOL+"://"+HOST+"/appumroh_web/userdata/";
	static const BANNER_AD_ID = "ca-app-pub-3940256099942544/6300978111";
	static const INTERSTITIAL_AD_ID = "ca-app-pub-3940256099942544/1033173712";
	static var USER_ID = 0;
	static var USER_INFO = {};
	static var GOOGLE_SIGN_IN_INSTANCE = null;
	static const MAIN_COLOR = Color(0xff4c945c);
	static const SECONDARY_COLOR = Color(0xff2d4f34);
	static var CURRENT_QURAN_THEME_ID = 1;
	static var CURRENT_THEME = {};
	static var XMPP_SERVER = "xabber.org";
	static var XMPP_HOST = "139.162.240.38";
	static var XMPP_PORT = 5222;
	static var XMPP_SENDER_USER_ID = "";
	static var XMPP_RECEIVER_USER_ID = "";
	static var XMPP_PASSWORD = "";
	static var XMPP_MESSAGE_LISTENER = null;
	static late FlutterXmpp flutterXmpp;
	static var CURRENT_LATITUDE = -6.229728;
	static var CURRENT_LONGITUDE = 106.6894315;
	static var ACCOUNT_LOGIN_TYPE = "email"; // email, google, facebook
	static const API_KEY = "X2ZPdrQEGVdTF5SRGLtF7jV7";
	static const API_SECRET = "xYBS8Tx9qtJSFNuQTkvRJku3qpn7BvxKjLvNHeeByy7QGtKNcg25Z47tHE8CyMNFbUBu8pAM24rcvTmkGKp3K9";
	static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin = null;
	static const NOTIFICATION_TYPE_JOIN_GROUP = "join_group";
	static const NOTIFICATION_TYPE_GROUP_JOIN_ACCEPTED = "join_accepted";
	static const NOTIFICATION_TYPE_GROUP_EXITED = "user_exited_group";
	static const NOTIFICATION_TYPE_PANIC = "panic";
	static const NOTIFICATION_TYPE_BROADCAST = "broadcast";
	static const NOTIFICATION_TYPE_MESSAGE = "message";
	static var CURRENT_SCREEN = "main";
	static var homeSetState = null;
	static var privateMessageSetState = null;
	static var mainTabSetState = null;

	static void show(message) {
		Fluttertoast.showToast(
    	    msg: message,
    	    toastLength: Toast.LENGTH_SHORT,
    	    gravity: ToastGravity.BOTTOM,
    	    timeInSecForIosWeb: 1
    	);
	}

	static void navigate(context, screen) {
		Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
	}

	static Future navigateAndWait(BuildContext context, var page) async {
		return (await Navigator.push(context, MaterialPageRoute(builder: (context) => page)));
	}

	static void replaceScreen(context, screen) {
		Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
	}

	static void clearNavigationStack(context, screen) {
		Navigator.pushAndRemoveUntil<dynamic>(context, MaterialPageRoute<dynamic>(
				builder: (BuildContext context) => screen,
			), (route) => false
		);
	}

	static Future<Position> getCurrentPosition() async {
		bool serviceEnabled;
		LocationPermission permission;
		serviceEnabled = await Geolocator.isLocationServiceEnabled();
		if (!serviceEnabled) {
			return Future.error('Location services are disabled.');
		}
		permission = await Geolocator.checkPermission();
		if (permission == LocationPermission.denied) {
			permission = await Geolocator.requestPermission();
			if (permission == LocationPermission.denied) {
				return Future.error('Location permissions are denied');
			}
		}
		if (permission == LocationPermission.deniedForever) {
			return Future.error('Location permissions are permanently denied, we cannot request permissions.');
		}
		return await Geolocator.getCurrentPosition();
	}

	static void httpGet(string, uri, {var headers = null, onSuccess = null, onError = null, onTimeout = null}) async {
		if (headers == null) {
			headers = Map<String, String>();
		}
		var response = await http.get(uri, headers: headers);
		if (onSuccess != null) {
			onSuccess(response.body);
		}
	}

	static httpGetSync(string, uri, {var headers = null}) async {
		if (headers == null) {
			headers = Map<String, String>();
		}
		var response = await http.get(uri, headers: headers);
		return response;
	}

	static void httpPost(string, uri, {var body = null, var headers = null, onSuccess = null, onError = null, onTimeout = null}) async {
		if (headers == null) {
			headers = Map<String, String>();
		}
		var response = await http.post(uri, headers: headers, body: body);
		if (onSuccess != null) {
			onSuccess(response.body);
		}
	}

	static httpPostSync(string, uri, {var body = null, var headers = null}) async {
		if (headers == null) {
			headers = Map<String, String>();
		}
		var response = await http.post(uri, headers: headers, body: body);
		return response;
	}

	static String formatDuration(Duration duration) {
		String twoDigits(int n) => n.toString().padLeft(2, "0");
		String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
		String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
		return twoDigits(duration.inHours)+":"+twoDigitMinutes+":"+twoDigitSeconds;
	}

	static Future<String> loadStringFromAsset(assetPath) async {
		return await rootBundle.loadString(assetPath);
	}

	static Future<String> readString(String name, String defaultValue) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		return prefs.getString(name) ?? defaultValue;
	}

	static Future<int> readInt(String name, int defaultValue) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		return prefs.getInt(name) ?? defaultValue;
	}

	static Future<double> readDouble(String name, double defaultValue) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		return prefs.getDouble(name) ?? defaultValue;
	}

	static Future<void> writeString(String name, String value) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString(name, value);
	}

	static Future<void> writeInt(String name, int value) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setInt(name, value);
	}

	static Future<void> writeDouble(String name, double value) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setDouble(name, value);
	}

	static Color getColorFromHex(String code) {
		return new Color(int.parse(code.substring(1, 7), radix: 16)+0xFF000000);
	}

	static Future<AlertDialog> showProgressDialog(BuildContext context, String message) async {
		AlertDialog alert = AlertDialog(
			content: new Row(
				children: [
					CircularProgressIndicator(),
					SizedBox(width: 10),
					Expanded(child: Container(margin: EdgeInsets.only(left: 7), child:Text(message)))
				])
		);
		showDialog(barrierDismissible: false,
			context:context,
			builder:(BuildContext context){
				return alert;
			},
		);
		return alert;
	}

	static Future<void> hideProgressDialog(BuildContext context) async {
		Navigator.pop(context);
	}

	static void alert(BuildContext context, var string, String title, String message) async {
		showDialog<String>(
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: Text(title),
				content: Text(message),
				actions: <Widget>[
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: Text(string!.ok),
					),
				],
			),
		);
	}

	static void alertConfirm(BuildContext context, var string, String title, String message, onOk) async {
		showDialog<String>(
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: Text(title),
				content: Text(message),
				actions: <Widget>[
					TextButton(
						onPressed: () {
							Navigator.pop(context);
							if (onOk != null) {
								onOk();
							}
						},
						child: Text(string!.ok),
					),
				],
			),
		);
	}

	static void confirm(BuildContext context, var string, String title, String message, okCallback, cancelCallback) async {
		showDialog<String>(
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: Text(title),
				content: Text(message),
				actions: <Widget>[
					TextButton(
						onPressed: () {
							Navigator.pop(context);
							if (cancelCallback != null) {
								cancelCallback();
							}
						},
						child: Text(string!.cancel),
					),
					TextButton(
							onPressed: () {
								Navigator.pop(context);
								if (okCallback != null) {
									okCallback();
								}
							},
							child: Text(string!.ok))
				],
			),
		);
	}

	static void hideKeyboard(context) {
		FocusScope.of(context).requestFocus(FocusNode());
	}

	static Future<void> setupXmpp() async {
		DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
		AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
		var deviceModel = androidInfo.model;
		if (deviceModel == "CPH1923") {
			XMPP_SENDER_USER_ID = "danaos";
			XMPP_RECEIVER_USER_ID = "danaos2";
			XMPP_PASSWORD = "HaloDunia123";
		} else {
			XMPP_SENDER_USER_ID = "danaos2";
			XMPP_RECEIVER_USER_ID = "danaos";
			XMPP_PASSWORD = "HaloDunia123";
		}
		var auth = {
			"user_jid": XMPP_SENDER_USER_ID+"@"+Global.XMPP_SERVER+"/Android",
			"password": XMPP_PASSWORD,
			"host": Global.XMPP_HOST,
			"port": Global.XMPP_PORT
		};
		flutterXmpp = new FlutterXmpp(auth);
		await flutterXmpp.login();
		await flutterXmpp.start((event) {
			print("start event:");
			print(event);
			print("message type:");
			print(event['type'].toString());
			if (event['type'].toString() == "incoming") {
				if (XMPP_MESSAGE_LISTENER != null) {
					XMPP_MESSAGE_LISTENER(event['body'].toString());
				}
			}
		}, (error) {
			print("start error:");
			print(error);
		});
	}

	static Future<void> sendMessage(message) async {
		await flutterXmpp.sendMessage(XMPP_RECEIVER_USER_ID+"@"+XMPP_SERVER, message, "");
	}

	static void setMessageListener(_listener) {
		XMPP_MESSAGE_LISTENER = _listener;
	}

	static String generateUUID() {
		return Uuid().v4();
	}

	static void restartApp() {
		Restart.restartApp();
	}

	static Future<void> initUniLinks(context, string) async {
		try {
			linkStream.listen((String? link) async {
				var params = link!.substring(link.indexOf("?")+1, link.length).split("&");
				var data = "";
				for (var param in params) {
					var paramName = param.split("=")[0];
					var paramValue = Uri.decodeFull(param.split("=")[1]);
					if (paramName == "data") {
						data = utf8.decode(base64.decode(paramValue));
					}
				}
				print("DATA:");
				print(data);
				var obj = jsonDecode(data);
				var hmacToken = generateHmacSHA256("api_key="+API_KEY+"&api_secret="+API_SECRET+"&action="+obj['action'].toString()+"&user_id="+obj['user_id'].toString());
				if (hmacToken == obj['token'].toString()) {
					if (obj['action'].toString() == "reset_password") {
						Get.to(ResetPassword(context, string, obj['data']['email'].toString()));
					} else if (obj['action'].toString() == "verify_email") {
						print("VERIFICATION TOKEN:");
						print(obj['data']['verification_token'].toString());
						Get.to(VerifyEmail(context, string, obj['data']['email'].toString(), obj['data']['verification_token'].toString()));
					}
				} else {
					await shutdown.shutdown();
				}
			}, onError: (err) {
			});
		} on PlatformException {
		}
	}

	static String generateHmacSHA256(value) {
		var key = utf8.encode(API_SECRET);
		var bytes = utf8.encode(value);
		var hmacSha256 = Hmac(sha256, key);
		var digest = hmacSha256.convert(bytes);
		return base64.encode(utf8.encode(digest.toString()));
	}

	static String generateRandomNumber(length) {
		var rng = new Random();
		var randomNumber = "";
		for (var i = 0; i < length; i++) {
			randomNumber += rng.nextInt(100).toString();
		}
		return randomNumber;
	}

	static void showNotification(title, body, payload) async {
		/*const AndroidNotificationDetails androidPlatformChannelSpecifics =
		AndroidNotificationDetails('appumroh_notifications', 'AppUmroh Notifications',
				channelDescription: 'Manage notifications for AppUmroh',
				importance: Importance.max,
				priority: Priority.high,
				ticker: 'ticker');
		const NotificationDetails platformChannelSpecifics =
		NotificationDetails(android: androidPlatformChannelSpecifics);
		await flutterLocalNotificationsPlugin!.show(
				0, title, body, platformChannelSpecifics,
				payload: 'item x');*/
		await AwesomeNotifications().createNotification(
				content: NotificationContent(
						id: 10,
						channelKey: 'appumroh_notifications',
						title: title,
						body: body,
						payload: convertToStringMap(payload)
				)
		);
	}

	static Map<String, String>? convertToStringMap(Map<String, dynamic> dynamicParams) {
		Map<String, String> params = new Map<String, String>();
		var dynamicValues = dynamicParams.values.toList();
		var i = 0;
		for (var key in dynamicParams.keys) {
			params[key] = dynamicValues[i];
			i++;
		}
		return params;
	}

	static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
		print('Handling a background message ${message.messageId}');
		if (message != null) {
			if (message.notification != null) {
				print("Received payload:");
				print(jsonEncode(message.data));
				showNotification(message.notification!.title, message.notification!.body, message.data);
			}
		}
	}

	static Future<void> initNotifications(context, string) async {
		if (!kIsWeb) {
			/*AndroidNotificationChannel channel = const AndroidNotificationChannel(
					'appumroh_notifications',
					'AppUmroh Notifications'
			);
			flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
			await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<
					AndroidFlutterLocalNotificationsPlugin>()
					?.createNotificationChannel(channel);
			await FirebaseMessaging.instance
					.setForegroundNotificationPresentationOptions(
				alert: true,
				badge: true,
				sound: true,
			);*/
		}
		/*const AndroidInitializationSettings initializationSettingsAndroid =
		AndroidInitializationSettings('app_icon');
		final IOSInitializationSettings initializationSettingsIOS =
		IOSInitializationSettings(
				onDidReceiveLocalNotification: onDidReceiveLocalNotification);
		final InitializationSettings initializationSettings = InitializationSettings(
				android: initializationSettingsAndroid,
				iOS: initializationSettingsIOS);
		flutterLocalNotificationsPlugin!.initialize(initializationSettings,
				onSelectNotification: selectNotification);*/
		await AwesomeNotifications().initialize(
				'resource://drawable/icon',
				[
					NotificationChannel(
							channelGroupKey: 'appumroh_notifications_group',
							channelKey: 'appumroh_notifications',
							channelName: 'AppUmroh Notifications',
							channelDescription: 'Manage notifications for AppUmroh',
							defaultColor: Color(0xFF9D50DD),
							ledColor: Colors.white
					)
				]
		);
		await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
			if (!isAllowed) {
				AwesomeNotifications().requestPermissionToSendNotifications();
			}
		});
	}

	static Future<void> initFCMListener(context, string) async {
		await AwesomeNotifications().actionStream.listen((ReceivedNotification receivedNotification) async {
			print("Clicked notification:");
			print(receivedNotification);
			print("CURRENT SCREEN:");
			print(Global.CURRENT_SCREEN);
			if (receivedNotification.payload != null) {
				var type = receivedNotification.payload!['type'].toString();
				print("Clicked notification type:");
				print(type);
				if (type == Global.NOTIFICATION_TYPE_JOIN_GROUP) {
					var groupInfo = jsonDecode(receivedNotification.payload!['group'].toString());
					print("GROUP INFO:");
					print(groupInfo);
					if (Global.CURRENT_SCREEN == "group_info") {
						Get.back();
					}
					Get.to(GroupInfo(context, string, groupInfo));
				} else if (type == Global.NOTIFICATION_TYPE_GROUP_JOIN_ACCEPTED) {
					var groupInfo = jsonDecode(receivedNotification.payload!['group'].toString());
					print("GROUP INFO:");
					print(groupInfo);
					if (Global.CURRENT_SCREEN == "group_info") {
						Get.back();
					}
					Get.to(GroupInfo(context, string, groupInfo));
				} else if (type == Global.NOTIFICATION_TYPE_BROADCAST) {
					var message = receivedNotification.payload!['message'].toString();
					var broadcasts = await jsonDecode(await readString("broadcasts", "[]"));
					broadcasts.add({
						"group_id": receivedNotification.payload!['group_id'].toString(),
						"user_id": receivedNotification.payload!['user_id'].toString(),
						"message": message,
						"sender": receivedNotification.payload!['sender'].toString(),
						"date": receivedNotification.payload!['date'].toString()
					});
					await writeString("broadcasts", jsonEncode(broadcasts));
					HomeState.showBroadcastMessage(message);
				} else if (type == Global.NOTIFICATION_TYPE_MESSAGE) {
					var message = jsonDecode(receivedNotification.payload!['message'].toString());
					var chatID = int.parse(receivedNotification.payload!['chat_id'].toString());
					Global.navigate(context, PrivateMessage(context, string, chatID, message));
				}
			}
		});
	}

	/*static Future<void> selectNotification(String? payload) async {
		print("Notification selected: "+payload!);
	}*/

	static Future<void> onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
		print("onDidReceiveLocalNotification:");
		print("Title: "+title!);
		print("Body: "+body!);
		print("Payload: "+payload!);
	}

	static void updateFCMToken(string) async {
		FirebaseMessaging messaging = FirebaseMessaging.instance;
		String? token = await messaging.getToken(
			vapidKey: "BI3XvY48T4P5sh4cmbhaAOJRUTijVecg2ovWsn-GcwSLhCjhGnkagY5gM9fyeJM3RMl5pmBbv4ThNqYE-hxkX2Q",
		);
		print("FCM TOKEN:");
		print(token!);
		if (Global.USER_ID != 0) {
			print("Updating FCM key...");
			Global.httpPost(
					string, Uri.parse(Global.API_URL + "/user/update_fcm_key"),
					body: <String, String>{
						"user_id": Global.USER_ID.toString(),
						"fcm_key": token
					}, onSuccess: (response) {
						print("update_fcm_key response:");
						print(response);
			});
		}
	}

	static Future<void> initFCM(context, string) async {
		initNotifications(context, string);
		FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  			print('Got a message whilst in the foreground!');
  			print('Message data: ${message.data}');
				if (message.notification != null) {
    			print('Message also contained a notification: ${message.notification}');
					print("Received payload:");
					print(jsonEncode(message.data));
    			showNotification(message.notification!.title, message.notification!.body, message.data);
					var obj = convertToStringMap(message.data);
					var type = obj!['type'].toString();
					if (type == NOTIFICATION_TYPE_PANIC) {
						var user = jsonDecode(obj['user'].toString());
						var panicUser = jsonDecode(obj['panic_user'].toString());
						AudioCache player = AudioCache();
						player.play('audios/notification.mp3');
						HomeState.highlightMarker(string, int.parse(obj['user_id'].toString()),
								double.parse(panicUser['lat'].toString()), double.parse(panicUser['lng'].toString()));
					} else if (type == Global.NOTIFICATION_TYPE_BROADCAST) {
						var message = obj['message'].toString();
						var broadcasts = await jsonDecode(await readString("broadcasts", "[]"));
						broadcasts.add({
							"group_id": obj['group_id'].toString(),
							"user_id": obj['user_id'].toString(),
							"message": message,
							"sender": obj['sender'].toString(),
							"date": obj['date'].toString()
						});
						await writeString("broadcasts", jsonEncode(broadcasts));
						HomeState.showBroadcastMessage(message);
					} else if (type == Global.NOTIFICATION_TYPE_MESSAGE) {
						var message = jsonDecode(obj['message'].toString());
						if (CURRENT_SCREEN == "private_message") {
							PrivateMessageState.addMessage(message);
						} else {
							showNotification(string.text252+" "+message['sender']['name'].toString(), message['message'].toString(), message);
						}
					}
  			}
		});
		FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
	}

	static void sendFCMMessage(fcmKey, title, body, payload) async {
		var response = await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
				headers: {
					"Content-Type": "application/json",
					"Authorization": "key=AAAAeiWUXLo:APA91bG-KdxJv1U4FQRSSfflD9W0412oGETk35NVj08--eMkVB8AK97z-R9UIxdQWweit5tnYxnwhoLm_-9xHJ7I0psJdSI2WI8Lxdn7arMpn7K3EE5ZAg3WGaFiq_CpEx_V-B1Cyu9c"
				}, body: jsonEncode(
					{
						"to": fcmKey,
						"notification": {
							"title": title,
							"body": body,
							"sound": "default",
							"badge": "1"
						},
						"data": payload,
						"priority": "high"
					}
				));
		print("SEND FCM MESSAGE RESPONSE:");
		print(response.body);
	}

	static Future<BitmapDescriptor> getMarkerIcon(groupInfo, userID) async {
		String iconName = "marker_member.png";
		bool isDriver = false;
		bool isOfficer = false;
		for (var member in groupInfo['group_members']) {
			if (int.parse(member['user_id'].toString()) == userID && member['role'].toString() == "driver") {
				isDriver = true;
				break;
			} else if (int.parse(member['user_id'].toString()) == userID && member['role'].toString() == "officer") {
				isOfficer = true;
				break;
			}
		}
		if (isDriver) {
			iconName = "marker_driver.png";
		} else if (isOfficer) {
			iconName = "marker_officer.png";
		} else if (userID == int.parse(groupInfo['user_id'].toString())) {
			iconName = "marker_leader.png";
		} else {
			iconName = "marker_member.png";
		}
		print("ICON NAME:");
		print(iconName);
		return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)), "assets/images/"+iconName);
	}

	static String? getPhoneBookNumber(phones) {
		if (phones.length > 0) {
			String phone = phones[0].value;
			if (phone == null) phone = "";
			phone = phone.trim();
			if (phone.startsWith("0")) {
				phone = phone.substring(1, phone.length);
			}
			if (phone.startsWith("62")) {
				phone = "+"+phone;
			}
			if (!phone.startsWith("+") && !phone.startsWith("+62")) {
				phone = "+62"+phone;
			}
			return phone;
		}
		return null;
	}

	static void sendSMSMessage(phone, message) async {
		List<String> recepients = [];
		recepients.add(phone);
		String result = await sendSMS(message: message, recipients: recepients).catchError((onError) {
			print(onError);
		});
		print("SEND SMS RESULT:");
		print(result);
	}

	static String getGroupMemberRole(group, userID) {
		var members = group['group_members'];
		if (members != null) {
			for (var member in members) {
				if (int.parse(member['user_id'].toString().trim()) == userID) {
					return member['role'].toString();
				}
			}
		}
		return "member";
	}

	static getGroupMember(group, userID) {
		var groupMembers = group['group_members'];
		if (groupMembers != null) {
			for (var i = 0; i < groupMembers.length; i++) {
				var groupMember = groupMembers[i];
				if (int.parse(groupMember['user_id'].toString().trim()) == userID) {
					return group['members'][i];
				}
			}
		}
		return null;
	}

	static bool isInRadius(LatLng northEast, LatLng southWest, LatLng latLng) {
		LatLngBounds bounds = new LatLngBounds(northeast: northEast, southwest: southWest);
		return bounds.contains(latLng);
	}

	static LatLng getNorthEastLatLng(LatLng latLng) {
		return LatLng(latLng.latitude+0.001, latLng.longitude-0.001);
	}

	static LatLng getSouthWestLatLng(LatLng latLng) {
		return LatLng(latLng.latitude-0.001, latLng.longitude+0.001);
	}

	static void rebuildAllChildren(BuildContext context) {
		void rebuild(Element el) {
			el.markNeedsBuild();
			el.visitChildren(rebuild);
		}
		(context as Element).visitChildren(rebuild);
	}
}
