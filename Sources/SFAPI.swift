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

    // MARK: URL response check

    private func checkAPIResponseWithFailMessage(message: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Heartbeat? {
        if let error = error {
            debugPrint("\(message): \(error.description)")
            return nil
        }

        guard let
            heartbeat = Heartbeat(data: data),
            httpResponse = response as? NSHTTPURLResponse
            where httpResponse.statusCode == 200
        else {
            debugPrint("\(message): got status code != 200")
            return nil
        }

        if !heartbeat.ok {
            debugPrint("\(message): \(heartbeat.error)")
        }

        return heartbeat
    }

    // MARK: Heartbeat

    /// Check that Stockfighter API is up.
    public func isAPIUp(handler: ((Heartbeat) -> Void)?) {
        let request = requestWithMethod(.GET, URL: SFAPI.APIHeartbeat(apiURL))
        URLSession.dataTaskWithRequest(request) { data, response, error in
            if let heartbeat = self.checkAPIResponseWithFailMessage("Bad response on API heartbeat check", data: data, response: response, error: error) {
                handler?(heartbeat)
            } else {
                handler?(Heartbeat.dead())
            }
        }.resume()
    }

    // MARK: GM API

    /// Start a level.
    public func startLevel(level: StockfighterLevel, handler: ((Level) -> Void)?) {
        let request = requestWithMethod(.POST, URL: SFAPI.GMStartLevel(gmURL, level: level))
        URLSession.dataTaskWithRequest(request) { data, response, error in
            let message = "Got a bad response when creating level “\(level.description)”"
            guard let
                _ = self.checkAPIResponseWithFailMessage(message, data: data, response: response, error: error),
                newLevel = Level(data: data)
            else {
                debugPrint("\(message): could not create new Level object.")
                return
            }

            handler?(newLevel)
        }.resume()
    }

    /// Stop a running level.
    public func stopLevelInstance(instance: InstanceId, handler: ((Bool) -> Void)?) {
        let request = requestWithMethod(.POST, URL: SFAPI.GMStopLevelInstance(gmURL, instance: instance))
        URLSession.dataTaskWithRequest(request) { data, response, error in
            let message = "Got a bad response when stopping instance “\(instance)”"
            guard let heartbeat = self.checkAPIResponseWithFailMessage(message, data: data, response: response, error: error) else {
                handler?(false)
                return
            }

            handler?(heartbeat.ok)
        }.resume()
    }

    /// Get a running level snapshot.
    public func getStateForLevelInstance(instance: InstanceId, handler: ((InstanceStatus) -> Void)?) {
        let request = requestWithMethod(.GET, URL: SFAPI.GMInstanceStatus(gmURL, instance: instance))
        URLSession.dataTaskWithRequest(request) { data, response, error in
            let message = "Got a bad response when requesting status for instance “\(instance)”"
            guard let
                _ = self.checkAPIResponseWithFailMessage(message, data: data, response: response, error: error),
                instanceStatus = InstanceStatus(data: data)
            else {
                debugPrint(message)
                return
            }

            handler?(instanceStatus)
        }.resume()
    }

    // MARK: HTTP task generation

    private enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
    }

    private func requestWithMethod(method: HTTPMethod, URL: NSURL) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = method.rawValue
        return request
    }
}

// MARK: URL generation
extension SFAPI {
    /// API Heartbeat: https://starfighter.readme.io/docs/heartbeat
    class func APIHeartbeat(baseURL: NSURL) -> NSURL {
        return baseURL.URLByAppendingPathComponent("heartbeat", isDirectory: false)
    }

    /// Starting a level.
    class func GMStartLevel(baseURL: NSURL, level: StockfighterLevel) -> NSURL {
        return baseURL
            .URLByAppendingPathComponent("levels")
            .URLByAppendingPathComponent(level.description, isDirectory: false)
    }

    /// Stopping a level.
    class func GMStopLevelInstance(baseURL: NSURL, instance: InstanceId) -> NSURL {
        return baseURL
            .URLByAppendingPathComponent("instances")
            .URLByAppendingPathComponent(String(instance))
            .URLByAppendingPathComponent("stop", isDirectory: false)
    }

    /// Getting a running level status.
    class func GMInstanceStatus(baseURL: NSURL, instance: InstanceId) -> NSURL {
        return baseURL
            .URLByAppendingPathComponent("instances")
            .URLByAppendingPathComponent(String(instance), isDirectory: false)
    }
}
