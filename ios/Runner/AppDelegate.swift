import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static var apnsErrorString: String?
  private static var apnsTokenHex: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let registrar = self.registrar(forPlugin: "ApnsDiagnosticPlugin")
    if let registrar = registrar {
      let channel = FlutterMethodChannel(
        name: "com.bprsupra.dashboard/apns_diagnostics",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { (call, result) in
        if call.method == "getApnsDiagnostic" {
          result([
            "error": AppDelegate.apnsErrorString ?? "",
            "token": AppDelegate.apnsTokenHex ?? "",
            "isRegistered": UIApplication.shared.isRegisteredForRemoteNotifications
          ])
        } else if call.method == "requestRegister" {
          UIApplication.shared.registerForRemoteNotifications()
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    AppDelegate.apnsTokenHex = tokenParts.joined()
    AppDelegate.apnsErrorString = nil
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    AppDelegate.apnsErrorString = error.localizedDescription
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
