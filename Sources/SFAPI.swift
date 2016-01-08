import Foundation

public typealias ErrorMessage = String
internal typealias JSON = [String: AnyObject]

/// Implements Stockfighter API methods.
public class SFAPI {

    private let apiURL: NSURL
    private let gmURL: NSURL
    private let URLSession: NSURLSession

    // MARK: Init

    public init(baseAPI: String, APIKey: String) {
        if let baseURL = NSURL(string: baseAPI) {
            self.apiURL = baseURL.URLByAppendingPathComponent("ob/api")
            self.gmURL = baseURL.URLByAppendingPathComponent("gm")
        } else {
            fatalError("Could not initialize API URLs with address: \(baseAPI)")
        }

        let sessionConf = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConf.HTTPAdditionalHeaders = ["X-Starfighter-Authorization": APIKey]

        URLSession = NSURLSession(configuration: sessionConf)
    }

    // MARK: Heartbeat

    /// Check that Stockfighter API is up.
    public func isAPIUp(handler: ((Heartbeat) -> Void)?) {
        URLSession.dataTaskWithURL(SFAPI.APIHeartbeat(apiURL)) { data, response, error in
            guard let
                rawData = data,
                heartbeat = Heartbeat(data: rawData),
                httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200 && error == nil
            else {
                handler?(Heartbeat.dead())
                return
            }

            handler?(heartbeat)
        }.resume()
    }
}

// MARK: URL generation
extension SFAPI {
    /// API Heartbeat: https://starfighter.readme.io/docs/heartbeat
    class func APIHeartbeat(baseURL: NSURL) -> NSURL {
        return baseURL.URLByAppendingPathComponent("heartbeat")
    }
}
