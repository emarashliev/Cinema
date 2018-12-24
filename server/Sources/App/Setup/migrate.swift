import Vapor
import FluentMySQL //use your database driver here

public func migrate(migrations: inout MigrationConfig) throws {
    migrations.add(model: MySQLMovie.self, database: .mysql)
    migrations.add(model: MySQLGenre.self, database: .mysql)
    migrations.add(model: MySQLActor.self, database: .mysql)
    migrations.add(model: MySQLMovieGenrePivot.self, database: .mysql)
    migrations.add(model: MySQLMovieActorPivot.self, database: .mysql)
}
