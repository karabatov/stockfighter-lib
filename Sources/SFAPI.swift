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

    // MARK: GM API

    /// Start a level.
    public func startLevel(level: StockfighterLevel, handler: ((Level) -> Void)?) {
        URLSession.dataTaskWithURL(SFAPI.GMStartLevel(gmURL, level: level)) { data, response, error in
            guard let
                rawData = data,
                newLevel = Level(data: rawData),
                httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200 && error == nil
            else {
                fatalError("Got a bad response when creating level “\(level.description)”")
            }

            handler?(newLevel)
        }.resume()
    }

    /// Get a running level snapshot.
    public func getStateForLevelInstance(instance: InstanceId, handler: ((InstanceStatus) -> Void)?) {
        URLSession.dataTaskWithURL(SFAPI.GMInstanceStatus(gmURL, instance: instance)) { data, response, error in
            guard let
                rawData = data,
                instanceStatus = InstanceStatus(data: rawData),
                httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200 && error == nil
            else {
                debugPrint("Got a bad response when requesting status for instance “\(instance)”")
                return
            }

            handler?(instanceStatus)
        }.resume()
    }
}

// MARK: URL generation
extension SFAPI {
    /// API Heartbeat: https://starfighter.readme.io/docs/heartbeat
    class func APIHeartbeat(baseURL: NSURL) -> NSURL {
        return baseURL.URLByAppendingPathComponent("heartbeat")
    }

    /// Starting a level.
    class func GMStartLevel(baseURL: NSURL, level: StockfighterLevel) -> NSURL {
        return baseURL
            .URLByAppendingPathComponent("levels")
            .URLByAppendingPathComponent(level.description)
    }

    /// Getting a running level status.
    class func GMInstanceStatus(baseURL: NSURL, instance: InstanceId) -> NSURL {
        return baseURL
            .URLByAppendingPathComponent("instances")
            .URLByAppendingPathComponent(String(instance))
    }
}
