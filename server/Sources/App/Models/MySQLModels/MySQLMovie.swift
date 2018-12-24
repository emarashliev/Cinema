import FluentMySQL
import Vapor

final class MySQLMovie: MySQLModel {

    static var name: String { return "Movie" }

    var id: Int?
    var title: String
    var homepage: String
    var language: String
    var overview: String

    init(id: Int?, title: String, homepage: String, language: String, overview: String) {
        self.id = id
        self.title = title
        self.homepage = homepage
        self.language = language
        self.overview = overview
    }
}

extension MySQLMovie: Migration {}

extension MySQLMovie {
    var genres: Siblings<MySQLMovie, MySQLGenre, MySQLMovieGenrePivot> {
        return siblings()
    }

    var actors: Siblings<MySQLMovie, MySQLActor, MySQLMovieActorPivot> {
        return siblings()
    }
}
