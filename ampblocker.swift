// ampblocker.swift by staturnz @0x7FF7

import Foundation


enum error: Error {
    case error(reason: String, addr: String, val: String)
}


func address(ptr: UnsafeRawPointer) -> String {
    let addr = Int(bitPattern: ptr)
    return String(format: "%p", addr)
}


func ignoreDevices(arg: Bool, force: Bool) throws {
    if #available(OSX 10.15, *) {
        do {
            guard var ret = CFPreferencesCopyAppValue("ignore-devices" as CFString, ".GlobalPreferences" as CFString) else {
                throw error.error(reason: "'nil value'", addr: "nil", val: "nil")
            }
            if ((ret as! Bool) == arg && !force) {
                throw error.error(reason: "'ignore-device is already set to \(arg)'", addr: address(ptr: &ret), val: "\(ret)")
            } else {
                var writeRet: Void = CFPreferencesSetAppValue("ignore-devices" as CFString, arg as CFBoolean, ".GlobalPreferences" as CFString)
                CFPreferencesAppSynchronize(".GlobalPreferences" as CFString)
                let checkAfterWrite = CFPreferencesCopyAppValue("ignore-devices" as CFString, ".GlobalPreferences" as CFString)
                if ((checkAfterWrite as? Bool ?? false) == arg) {
                    print("[*] Success: ignore-device is set to \(arg).")
                } else {
                    throw error.error(reason: "'failed to write value to ignore-device'", addr: address(ptr: &writeRet), val: "\(String(describing: checkAfterWrite))")
                }
            }
        } catch error.error(let reason, let addr, let val){
            print("[*] Error: \(reason) at: \(addr) with val: \(val)")
            return
        }
    } else {
        print("[*] Error: Tool is for macOS 10.15 only.")
    }
}


func blockAutoSync(arg: Bool, force: Bool) throws {
    if #available(OSX 10.15, *) {
        do {
            if let AMPDevicesAgent = UserDefaults(suiteName: "com.apple.AMPDevicesAgent") {
                var ret = AMPDevicesAgent.bool(forKey: "dontAutomaticallySyncIPods")
                if (ret == arg && !force) {
                    throw error.error(reason: "'dontAutomaticallySyncIPods is already set to \(arg)'", addr: address(ptr: &ret), val: "\(ret)")
                } else {
                    var writeRet: Void = AMPDevicesAgent.set(arg, forKey: "dontAutomaticallySyncIPods")
                    let checkAfterWrite = AMPDevicesAgent.bool(forKey: "dontAutomaticallySyncIPods")
                    if (checkAfterWrite == arg) {
                        print("[*] Success: dontAutomaticallySyncIPods is set to \(arg).")
                    } else {
                        throw error.error(reason: "'failed to write value to dontAutomaticallySyncIPods'", addr: address(ptr: &writeRet), val: "\(checkAfterWrite)")
                    }
                }
            }   
        } catch error.error(let reason, let addr, let val){
            print("[*] Error: \(reason) at: \(addr) with val: \(val)")
            return
        }
    } else {
        print("[*] Error: Tool is for macOS 10.15 only.")
    }
}


func main() {
    var val = false;
    var force = false;

    guard CommandLine.arguments.count > 1 else {
        print("usage: ./ampblocker <start/stop> -f (optional)")
        return
    }

    if (CommandLine.arguments.count == 3) {
        if (CommandLine.arguments[2].lowercased() == "-f") {
            force = true
        } else {
            print("[*] Error: Argument \(CommandLine.arguments[2].lowercased()) is invaild")
            return
        }
    }

    if (CommandLine.arguments[1].lowercased() == "start") {
        val = true
    } else if (CommandLine.arguments[1].lowercased() == "stop") {
        val = false
    } else {
        print("[*] Error: Argument \(CommandLine.arguments[1].lowercased()) is invaild")
     return
    }

    try? blockAutoSync(arg: val, force: force)
    try? ignoreDevices(arg: val, force: force)

    return
}


main()
