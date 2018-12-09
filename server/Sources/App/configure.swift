import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    services.register(ApiMiddleware.self)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(ApiMiddleware.self) // Ask for apiKey
    services.register(middlewares)

    // Configure a MySQL database
    var databases = DatabasesConfig()
    let databaseName: String
    let databasePort: Int

    if env == .testing {
        databaseName = "cinema_app_test"
        databasePort = 3308
    } else {
        databaseName = "cinema_app_dev"
        databasePort = 3306
    }

    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost",
                                          port: databasePort,
                                          username: "cinema",
                                          password: "password",
                                          database: databaseName)

    let database = MySQLDatabase(config: mysqlConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Movie.self, database: .mysql)
    migrations.add(model: Genre.self, database: .mysql)
    migrations.add(model: Actor.self, database: .mysql)
    migrations.add(model: MovieGenrePivot.self, database: .mysql)
    migrations.add(model: MovieActorPivot.self, database: .mysql)
    services.register(migrations)

}
