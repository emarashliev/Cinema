import FluentMySQL
import Vapor

final class Genre: Codable {
    
    var id: Int?
    var name: String
}

extension Genre: MySQLModel {}
extension Genre: Content {}
extension Genre: Migration {}
extension Genre: Parameter {}

extension Genre {
    var movies: Siblings<Genre, Movie, MovieGenrePivot> {
        return siblings()
    }
}
