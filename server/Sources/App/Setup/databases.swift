import Vapor
import FluentMySQL

public func databases(config: inout DatabasesConfig, env: Environment) throws {
    switch env {
    case .production:
        // TODO: this have to be implemented when we're ready for production
        break
    case .development:
        let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost",
                                              port: 3306,
                                              username: "cinema",
                                              password: "password",
                                              database: "cinema_app_dev")
        /// Register the databases
        config.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
    case .testing:
        // TODO:
        break
    default:
        throw Abort(.internalServerError, reason: "Unknow environment type.")
    }
}
