// ios/Runner/AppDelegate.swift

import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let channelName = "netscope/network"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(
            with: self
        )

        let controller =
            window?.rootViewController as! FlutterViewController

        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler {
            call,
            result in

            switch call.method {

            case "isSupported":
                result(false)

            case "hasUsageAccess":
                result(false)

            case "startMonitoring":
                NetworkMonitor.shared.start()
                result(nil)

            case "stopMonitoring":
                NetworkMonitor.shared.stop()
                result(nil)

            case "getCurrentUsage":
                result(nil)

            case "getAppUsage":
                result([])

            case "requestUsageAccess":
                result(nil)

            case "openAppUsageSettings":
                result(nil)

            default:
                result(
                    FlutterMethodNotImplemented
                )
            }
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions:
                launchOptions
        )
    }
}