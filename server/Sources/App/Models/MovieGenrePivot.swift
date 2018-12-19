import FluentMySQL
import Vapor
import Foundation

final class MovieGenrePivot: MySQLUUIDPivot {
    
    var id: UUID?
    var movieID: Movie.ID
    var genreID: Genre.ID

    typealias Left = Movie
    typealias Right = Genre
    static let leftIDKey: LeftIDKey = \.movieID
    static let rightIDKey: RightIDKey = \.genreID

    init(_ movieID: Movie.ID, _ genreID: Genre.ID) {
        self.movieID = movieID
        self.genreID = genreID
    }
}

extension MovieGenrePivot: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.movieID, to: \Movie.id, onDelete: .cascade)
            builder.reference(from: \.genreID, to: \Genre.id, onDelete: .cascade)
        }
    }
}
