import Vapor
import FluentMySQL
import FluentSQL
import Foundation

protocol MovieRepository: ServiceType {

    func find(id: Int) -> Future<Movie?>
    func all() -> Future<[Movie]>
    func search(_ searchQuery: String) -> Future<[Movie]>
}

final class MySQLMovieRepository: MovieRepository {

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(id: Int) -> Future<Movie?> {
        return db.withSQLConnection { conn in
             MySQLMovie.find(id, on: conn).map { movie in
                 Movie(id: movie!.id,
                             title: movie!.title,
                             homepage: movie!.homepage,
                             language: movie!.language,
                             overview: movie!.overview)
            }
        }
    }

    func all() -> Future<[Movie]> {
        return db.withSQLConnection { conn in
             MySQLMovie.query(on: conn).all().map { movies in
                movies.map {
                     Movie(id: $0.id,
                                title: $0.title,
                                homepage: $0.homepage,
                                language: $0.language,
                                overview: $0.overview)
                }
            }
        }
    }

    func search(_ searchQuery: String) -> Future<[Movie]> {
        return db.withSQLConnection { conn in
             MySQLMovie.query(on: conn).group(.or) { or in
                or.filter(\.title ~~ searchQuery)
                or.filter(\.homepage ~~ searchQuery)
                or.filter(\.language == searchQuery)
                or.filter(\.overview ~~ searchQuery)
                }
                .all()
                .map { movies in
                    movies.map {
                         Movie(id: $0.id,
                                     title: $0.title,
                                     homepage: $0.homepage,
                                     language: $0.language,
                                     overview: $0.overview)
                    }
            }
        }
    }
}

//MARK: - ServiceType conformance
extension MySQLMovieRepository {
    static let serviceSupports: [Any.Type] = [MovieRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
