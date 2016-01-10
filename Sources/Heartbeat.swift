import Foundation

public struct Heartbeat {
    public let ok: Bool
    public let error: ErrorMessage

    init(ok: Bool = false, error: ErrorMessage = "") {
        self.ok = ok
        self.error = error
    }

    init?(data: NSData?) {
        if let
            rawData = data,
            jsonData = try! NSJSONSerialization.JSONObjectWithData(rawData, options: .AllowFragments) as? JSON,
            ok = jsonData["ok"] as? Bool
        {
            self.ok = ok
            self.error = jsonData["error"] as? ErrorMessage ?? ""
        } else {
            return nil
        }
    }

    /// Returns a “failed” heartbeat.
    static func dead() -> Heartbeat {
        return Heartbeat()
    }
}
