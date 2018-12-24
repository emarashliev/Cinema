import Vapor

protocol BaseEntity: Parameter where ResolvedParameter == Int {}

extension BaseEntity {

    static func resolveParameter(_ parameter: String, on container: Container) throws -> Int {
        return try Int(parameter).or(error: Abort(.badRequest, reason: "Invalid parameter"))
    }
}
