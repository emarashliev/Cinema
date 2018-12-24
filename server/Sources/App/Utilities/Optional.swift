import Foundation

extension Optional {
    func or(error: Error) throws -> Wrapped {
        switch self {
        case let x?: return x
        case nil: throw error
        }
    }
}
