import FluentMySQL
import Vapor

final class MySQLActor: MySQLModel {

    static var name: String { return "Actor" }

    var id: Int?
    var name: String

    init(id: Int?, name: String) {
        self.id = id
        self.name = name
    }
}

extension MySQLActor: Migration {}

extension MySQLActor {
    var movies: Siblings<MySQLActor, MySQLMovie, MySQLMovieActorPivot> {
        return siblings()
    }
}
