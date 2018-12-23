import Vapor
import FluentMySQL

final class MySQLGenre: MySQLModel {

    static var name: String { return "Genre" }

    var id: Int?
    var name: String
}

extension MySQLGenre: Content {}
extension MySQLGenre: Migration {}
extension MySQLGenre: Parameter {}

//extension Genre {
//    var movies: Siblings<Genre, Movie, MovieGenrePivot> {
//        return siblings()
//    }
//}
