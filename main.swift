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
          let handler = NSWorkspace.shared.urlForApplication(toOpen: httpUrl) else {
        return ""
    }
    
    return appName(fromBundleId: Bundle(url: handler)?.bundleIdentifier ?? "")
}

func setDefaultHandler(urlScheme: String, handlerBundleId: String) {
    LSSetDefaultHandlerForURLScheme(urlScheme as CFString, handlerBundleId as CFString)
}

let arguments = CommandLine.arguments
let target = arguments.count == 1 ? "" : arguments[1].lowercased()

let edgeCanaryBundleId = "com.microsoft.edgemac.Canary"
let handlers = getHTTPHandlers()
let currentHandlerName = getCurrentHTTPHandler()

if target.isEmpty {
    for (key, _) in handlers {
        let mark = key == currentHandlerName ? "* " : "  "
        print("\(mark)\(key)")
    }
} else {
    if target == currentHandlerName {
        print("\(target) is already set as the default HTTP handler")
    } else if let targetHandler = handlers[target] {
        setDefaultHandler(urlScheme: "http", handlerBundleId:targetHandler)
        setDefaultHandler(urlScheme: "https", handlerBundleId: targetHandler)
    } else {
        setDefaultHandler(urlScheme: "http", handlerBundleId: "com.microsoft.edgemac.Canary")
        setDefaultHandler(urlScheme: "https", handlerBundleId: "com.microsoft.edgemac.Canary")
        print("Attempted to set MS Edge as the default browser")
    }
}
