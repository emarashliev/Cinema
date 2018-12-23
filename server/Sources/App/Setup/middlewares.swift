import Vapor

public func middlewares(config: inout MiddlewareConfig) throws {
    config.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.use(ApiMiddleware.self) // Ask for apiKey
}
