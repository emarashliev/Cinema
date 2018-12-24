import Vapor
import FluentMySQL

final class MySQLGenre: MySQLModel {

    static var name: String { return "Genre" }

    var id: Int?
    var name: String

    init(id: Int?, name: String) {
        self.id = id
        self.name = name
    }
}

extension MySQLGenre: Migration {}

extension MySQLGenre {
    var movies: Siblings<MySQLGenre, MySQLMovie, MySQLMovieGenrePivot> {
        return siblings()
    }
}
