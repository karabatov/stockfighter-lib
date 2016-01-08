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
