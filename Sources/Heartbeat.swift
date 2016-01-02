import Foundation

public class Heartbeat {
    /// Check that Stockfighter API is up.
    public class func isAPIup(handler: ((Bool) -> Void)?) {
        guard let heartbeatURL = NSURL(string: "https://api.stockfighter.io/ob/api/heartbeat") else {
            handler?(false)
            return
        }

        NSURLSession.sharedSession().dataTaskWithURL(heartbeatURL) { data, response, error in
            guard error == nil else {
                handler?(false)
                return
            }

            handler?(true)
        }.resume()
    }
}
