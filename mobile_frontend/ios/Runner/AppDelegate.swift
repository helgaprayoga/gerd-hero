import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, UIDocumentPickerDelegate {
  private let reportChannelName = "gerdhero/report_file"
  private var reportResult: FlutterResult?
  private var reportTemporaryURL: URL?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: reportChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "savePdf" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.savePdf(call: call, result: result)
    }
  }

  private func savePdf(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let bytes = arguments["bytes"] as? FlutterStandardTypedData,
      let fileName = arguments["fileName"] as? String
    else {
      result(FlutterError(code: "INVALID_DATA", message: "Data PDF tidak tersedia.", details: nil))
      return
    }

    let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    do {
      try bytes.data.write(to: temporaryURL, options: .atomic)
    } catch {
      result(FlutterError(code: "TEMP_FILE_FAILED", message: error.localizedDescription, details: nil))
      return
    }

    reportResult = result
    reportTemporaryURL = temporaryURL
    let picker = UIDocumentPickerViewController(url: temporaryURL, in: .exportToService)
    picker.delegate = self
    picker.modalPresentationStyle = .formSheet
    topViewController()?.present(picker, animated: true)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    reportResult?(true)
    clearReportExport()
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    reportResult?(false)
    clearReportExport()
  }

  private func clearReportExport() {
    if let url = reportTemporaryURL {
      try? FileManager.default.removeItem(at: url)
    }
    reportTemporaryURL = nil
    reportResult = nil
  }

  private func topViewController() -> UIViewController? {
    var controller = window?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }
}
