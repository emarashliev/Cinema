import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewaresConfig = MiddlewareConfig()
    try middlewares(services: &services, config: &middlewaresConfig)
    services.register(middlewaresConfig)
    
    // Configure the database
    var databasesConfig = DatabasesConfig()
    try databases(services: &services, config: &databasesConfig, env: env)
    services.register(databasesConfig)

    /// Configure migrations
    services.register { container -> MigrationConfig in
        var migrationConfig = MigrationConfig()
        try migrate(migrations: &migrationConfig)
        return migrationConfig
    }

    /// Register repositories
    setupRepositories(services: &services, config: &config)
}
