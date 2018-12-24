import Vapor

public func middlewares(services: inout Services, config: inout MiddlewareConfig) throws {
    /// Register providers first
    services.register(ApiMiddleware.self)
    
    config.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.use(ApiMiddleware.self) // Ask for apiKey
}
