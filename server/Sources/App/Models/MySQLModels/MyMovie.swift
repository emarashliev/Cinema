import FluentMySQL
import Vapor

final class MySQLMovie: MySQLModel {

    static var name: String { return "Movie" }

    var id: Int?
    var title: String
    var homepage: String
    var language: String
    var overview: String
}

extension MySQLMovie: Content {}
extension MySQLMovie: Migration {}
extension MySQLMovie: Parameter {}

extension MySQLMovie {
    var genres: Siblings<MySQLMovie, MySQLGenre, MySQLMovieGenrePivot> {
        return siblings()
    }

//    var actors: Siblings<Movie, Actor, MovieActorPivot> {
//        return siblings()
//    }
}
