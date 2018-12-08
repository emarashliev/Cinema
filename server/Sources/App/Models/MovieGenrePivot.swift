import FluentMySQL
import Vapor
import Foundation

final class MovieGenrePivot: MySQLUUIDPivot {
    
    var id: UUID?
    var movieID: Movie.ID
    var genreID: Genre.ID

    typealias Left = Movie
    typealias Right = Genre
    static let leftIDKey: LeftIDKey = \MovieGenrePivot.movieID
    static let rightIDKey: RightIDKey = \MovieGenrePivot.genreID

    init(_ movieID: Movie.ID, _ genreID: Genre.ID) {
        self.movieID = movieID
        self.genreID = genreID
    }
}

extension MovieGenrePivot: Migration {}
