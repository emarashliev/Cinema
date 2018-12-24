import Foundation
import Vapor
import FluentMySQL

final class MySQLMovieGenrePivot: MySQLUUIDPivot {

    typealias Left = MySQLMovie
    typealias Right = MySQLGenre
    
    static let leftIDKey: LeftIDKey = \.movieID
    static let rightIDKey: RightIDKey = \.genreID
    static var name: String { return "MovieGenrePivot" }

    var id: UUID?
    var movieID: MySQLMovie.ID
    var genreID: MySQLGenre.ID



    init(_ movieID: MySQLMovie.ID, _ genreID: MySQLGenre.ID) {
        self.movieID = movieID
        self.genreID = genreID
    }
}

extension MySQLMovieGenrePivot: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.movieID, to: \MySQLMovie.id, onDelete: .cascade)
            builder.reference(from: \.genreID, to: \MySQLGenre.id, onDelete: .cascade)
        }
    }
}
