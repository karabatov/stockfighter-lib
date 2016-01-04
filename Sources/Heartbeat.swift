import Foundation

public struct Heartbeat {
    public let ok: Bool
    public let error: ErrorMessage

    init(ok: Bool = false, error: ErrorMessage = "") {
        self.ok = ok
        self.error = error
    }

    init?(data: NSData) {
        if let
            jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? JSON,
            ok = jsonData["ok"] as? Bool,
            error = jsonData["error"] as? ErrorMessage
        {
            self.ok = ok
            self.error = error
        } else {
            return nil
        }
    }

    /// Returns a “failed” heartbeat.
    static func dead() -> Heartbeat {
        return Heartbeat()
    }
}
