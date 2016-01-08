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

/// State of the level, "open" etc.
public enum LevelState: String {
    case Open = "open"
}

/// Contains properties for a game level which we need to be able to play it: instructions, trading account, etc.
public struct Level {
    let account: Account
    let instance: InstanceId
    let instructions: Instructions
    let secondsPerDay: Int
    let tickers: [StockSymbol]
    let venues: [VenueSymbol]
    let balances: [CurrencySymbol: CurrencyAmount]
}

/// Describes the current status of a level which we get through the GM API.
public struct LevelStatus {
    let totalDays: Int
    let tradingDay: Int
    let done: Bool
    let instance: InstanceId
    let state: LevelState
    let date: NSDate
}
