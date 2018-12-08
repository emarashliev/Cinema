import FluentSQLite
import Vapor

final class Movie: Codable {

    var id: Int?
    var title: String
    var homepage: String
    var language: String
    var overview: String
}

extension Movie: SQLiteModel {}
extension Movie: Content {}
extension Movie: Migration {}
extension Movie: Parameter {}

extension Movie {
    var genres: Siblings<Movie, Genre, MovieGenrePivot> {
        return siblings()
    }

    var actors: Siblings<Movie, Actor, MovieActorPivot> {
        return siblings()
    }
}
