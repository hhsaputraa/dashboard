import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var nativePushChannel: FlutterMethodChannel?
  private var cachedDeviceToken: String?
  private var cachedDeviceError: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { [weak self] granted, error in
          if let error = error {
            self?.handleRegistrationError(error.localizedDescription)
          }
          DispatchQueue.main.async {
            application.registerForRemoteNotifications()
          }
        }
      )
    }

    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupNativePushChannel(registry: engineBridge.pluginRegistry)
  }

  private func setupNativePushChannel(registry: FlutterPluginRegistry) {
    guard nativePushChannel == nil else { return }
    let registrar = registry.registrar(forPlugin: "NativePushChannelPlugin")
    let channel = FlutterMethodChannel(
      name: "com.bprsupra.dashboard/native_push",
      binaryMessenger: registrar.messenger()
    )
    self.nativePushChannel = channel

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      switch call.method {
      case "getDeviceToken":
        let token = self.cachedDeviceToken ?? UserDefaults.standard.string(forKey: "flutter.apns_device_token")
        let error = self.cachedDeviceError ?? UserDefaults.standard.string(forKey: "flutter.apns_error")
        var res: [String: String] = [:]
        if let t = token { res["token"] = t }
        if let e = error { res["error"] = e }
        result(res)
      case "requestRegistration":
        self.triggerPushRegistration()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func triggerPushRegistration() {
    DispatchQueue.main.async {
      if #available(iOS 10.0, *) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { [weak self] granted, error in
          if let error = error {
            self?.handleRegistrationError(error.localizedDescription)
          }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
        }
      } else {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    self.cachedDeviceToken = token
    self.cachedDeviceError = nil

    UserDefaults.standard.set(token, forKey: "flutter.apns_device_token")
    UserDefaults.standard.removeObject(forKey: "flutter.apns_error")
    UserDefaults.standard.synchronize()

    self.nativePushChannel?.invokeMethod("onDeviceToken", token)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    handleRegistrationError(error.localizedDescription)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  private func handleRegistrationError(_ errorMsg: String) {
    self.cachedDeviceError = errorMsg
    UserDefaults.standard.set(errorMsg, forKey: "flutter.apns_error")
    UserDefaults.standard.synchronize()
    self.nativePushChannel?.invokeMethod("onDeviceTokenError", errorMsg)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }
}

