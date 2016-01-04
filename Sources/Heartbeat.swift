import Foundation

let stockfighterBaseAPIURL = NSURL(string: "https://api.stockfighter.io/ob/api/")!

public typealias ErrorMessage = String
internal typealias JSON = [String: AnyObject]

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
}

/// Check that Stockfighter API is up.
public func isStockfighterAPIup(handler: ((Heartbeat) -> Void)?) {
    let heartbeatURL = stockfighterBaseAPIURL.URLByAppendingPathComponent("heartbeat")

    NSURLSession.sharedSession().dataTaskWithURL(heartbeatURL) { data, response, error in
        guard let
            rawData = data,
            heartbeat = Heartbeat(data: rawData),
            httpResponse = response as? NSHTTPURLResponse
            where httpResponse.statusCode == 200 && error == nil
        else {
            handler?(Heartbeat())
            return
        }

        handler?(heartbeat)
    }.resume()
}
