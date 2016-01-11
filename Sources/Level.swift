import Foundation

/// All levels for Stockfighter with related string representations for GM API.
public enum StockfighterLevel: Int, CustomStringConvertible {
    case FirstSteps = 1

    public var description: String {
        switch self {
        case .FirstSteps: return "first_steps"
        }
    }
}

/// Trading account.
public typealias Account = String

/// Level instance id, used to control a level lifecycle via the GM API.
public typealias InstanceId = Int

/// Human-readable level instructions.
public typealias Instructions = [String: String]

/// Stock symbol e.g. “FOOBAR”.
public typealias StockSymbol = String

/// Venue symbol e.g. “TESTEX”.
public typealias VenueSymbol = String

/// Currency symbol e.g. “USD”.
public typealias CurrencySymbol = String

/// Currency amount.
public typealias CurrencyAmount = Int

/// Balance for a given currency, e.g. USD: 0.
public typealias CurrencyBalance = [CurrencySymbol: CurrencyAmount]

/// State of the level, "open" etc.
public enum LevelState: String {
    case Open = "open"
    case Closed = "closed"
}

/// Contains properties for a game level which we need to be able to play it: instructions, trading account, etc.
public struct Level {
    public let account: Account
    public let instance: InstanceId
    public let instructions: Instructions
    public let secondsPerDay: Int
    public let tickers: [StockSymbol]
    public let venues: [VenueSymbol]
    public let balances: CurrencyBalance

    init?(data: NSData?) {
        guard let
            rawData = data,
            json = try! NSJSONSerialization.JSONObjectWithData(rawData, options: .AllowFragments) as? JSON,
            ok = json["ok"] as? Bool,
            account = json["account"] as? Account,
            instance = json["instanceId"] as? InstanceId,
            instructions = json["instructions"] as? Instructions,
            secondsPerDay = json["secondsPerTradingDay"] as? Int,
            tickers = json["tickers"] as? [StockSymbol],
            venues = json["venues"] as? [VenueSymbol],
            balances = json["balances"] as? CurrencyBalance
            where ok == true
        else { return nil }

        self.account = account
        self.instance = instance
        self.instructions = instructions
        self.secondsPerDay = secondsPerDay
        self.tickers = tickers
        self.venues = venues
        self.balances = balances
    }
}

/// Describes the current status of a level which we get through the GM API.
public struct InstanceStatus {
    public let totalDays: Int
    public let tradingDay: Int
    public let done: Bool
    public let instance: InstanceId
    public let state: LevelState
    public let date: NSDate

    init?(data: NSData?) {
        guard let
            rawData = data,
            json = try! NSJSONSerialization.JSONObjectWithData(rawData, options: .AllowFragments) as? JSON,
            ok = json["ok"] as? Bool,
            details = json["details"] as? NSDictionary,
            totalDays = details["endOfTheWorldDay"] as? Int,
            tradingDay = details["tradingDay"] as? Int,
            done = json["done"] as? Bool,
            instance = json["id"] as? InstanceId,
            stateValue = json["state"] as? String,
            state = LevelState(rawValue: stateValue)
            where ok == true
        else { return nil }

        self.totalDays = totalDays
        self.tradingDay = tradingDay
        self.done = done
        self.instance = instance
        self.state = state
        self.date = NSDate()
    }
}
