import Cocoa

func appName(fromBundleId appBundleId: String) -> String {
    return appBundleId.components(separatedBy: ".").last?.lowercased() ?? ""
}

func getHTTPHandlers() -> [String: String] {
    guard let url = URL(string: "http://") else { return [:] }
    let apps = NSWorkspace.shared.urlsForApplications(toOpen: url)

    var dict: [String: String] = [:]

    for appUrl in apps {
        let bundleId = Bundle(url: appUrl)?.bundleIdentifier ?? ""
        dict[appName(fromBundleId: bundleId)] = bundleId
    }

    return dict
}

func getCurrentHTTPHandler() -> String {
    guard let httpUrl = URL(string: "http://"),
        let handler = NSWorkspace.shared.urlForApplication(toOpen: httpUrl)
    else {
        return ""
    }

    return Bundle(url: handler)?.bundleIdentifier ?? ""
}

func setDefaultHandler(urlScheme: String, handlerBundleId: String) {
    LSSetDefaultHandlerForURLScheme(urlScheme as CFString, handlerBundleId as CFString)
}

let arguments = CommandLine.arguments
let target = arguments.count == 1 ? "" : arguments[1].lowercased()

let edgeCanaryBundleId = "com.microsoft.edgemac.Canary"
let safariTechPreviewBundleId = "com.apple.SafariTechnologyPreview"
let handlers = getHTTPHandlers()
let currentHandlerBundleId = getCurrentHTTPHandler()

if target.isEmpty || target == "toggle" {
    if currentHandlerBundleId == edgeCanaryBundleId {
        setDefaultHandler(urlScheme: "http", handlerBundleId: safariTechPreviewBundleId)
        setDefaultHandler(urlScheme: "https", handlerBundleId: safariTechPreviewBundleId)
        print("Switched from Edge Canary to Safari Technology Preview")
    } else if currentHandlerBundleId == safariTechPreviewBundleId {
        setDefaultHandler(urlScheme: "http", handlerBundleId: edgeCanaryBundleId)
        setDefaultHandler(urlScheme: "https", handlerBundleId: edgeCanaryBundleId)
        print("Switched from Safari Technology Preview to Edge Canary")
    } else {
        setDefaultHandler(urlScheme: "http", handlerBundleId: edgeCanaryBundleId)
        setDefaultHandler(urlScheme: "https", handlerBundleId: edgeCanaryBundleId)
        print("Set Edge Canary as default (was neither Edge Canary nor Safari Technology Preview)")
    }
} else {
    let currentHandlerName = appName(fromBundleId: currentHandlerBundleId)
    
    if target == currentHandlerName {
        print("\(target) is already set as the default HTTP handler")
    } else if let targetHandler = handlers[target] {
        setDefaultHandler(urlScheme: "http", handlerBundleId: targetHandler)
        setDefaultHandler(urlScheme: "https", handlerBundleId: targetHandler)
        print("Set \(target) as the default HTTP handler")
    } else {
        print("Browser '\(target)' not found")
    }
}
