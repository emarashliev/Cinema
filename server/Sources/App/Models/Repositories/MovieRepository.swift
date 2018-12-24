import Vapor
import FluentSQL
import FluentMySQL

protocol MovieRepository: ServiceType {
    
    func save(movie: Movie) -> Future<Movie>
    func update(movie: Movie, id: Int) -> Future<Movie>
    func delete(id: Int) throws -> Future<HTTPStatus>
    func all() -> Future<[Movie]>
    func movieDetails(id: Int) throws -> Future<MovieDetails>
    func search(_ searchQuery: String) -> Future<[Movie]>
    func getGenres(for movieId: Int) throws -> Future<[Genre]>
    func attachGenre(with id: Int, to movieId: Int) throws -> Future<HTTPStatus>
    func getActors(for movieId: Int) throws -> Future<[Actor]>
    func attachActor(with id: Int, to movieId: Int) throws -> Future<HTTPStatus>

}

final class MySQLMovieRepository: MovieRepository {
    
    let db: MySQLDatabase.ConnectionPool
    
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }
    
    func save(movie: Movie) -> Future<Movie> {
        return db.withConnection { conn in
            return MySQLMovie(id: movie.id,
                              title: movie.title,
                              homepage: movie.homepage,
                              language: movie.language,
                              overview: movie.overview)
                .save(on: conn)
                .map(to: Movie.self) { self.mysqlMovieToEntity($0) }
        }
    }
    
    func update(movie: Movie, id: Int) -> Future<Movie> {
        return db.requestConnection().flatMap { conn in
            return try self.find(in: MySQLMovie.self, id: id, conn: conn)
                .map(to: MySQLMovie.self) {
                    $0.title = movie.title
                    $0.overview = movie.overview
                    $0.homepage = movie.homepage
                    $0.homepage = movie.homepage
                    return $0
                }
                .update(on: conn)
                .map(to: Movie.self) { self.mysqlMovieToEntity($0) }
        }
    }
    
    func delete(id: Int) throws -> Future<HTTPStatus> {
        return db.requestConnection().flatMap { conn in
            return try self.find(in: MySQLMovie.self, id: id, conn: conn)
                .flatMap(to: HTTPStatus.self) { movie in
                    return movie.delete(on: conn).transform(to: HTTPStatus.noContent)
            }
        }
    }
    
    func all() -> Future<[Movie]> {
        return db.withSQLConnection { conn in
            MySQLMovie.query(on: conn)
                .all()
                .map { $0.map { self.mysqlMovieToEntity($0) } }
        }
    }
    
    func movieDetails(id: Int) throws -> Future<MovieDetails> {
        return db.requestConnection().flatMap { conn in
            let movie = MySQLMovie.find(id, on: conn)
                .unwrap(or: Abort(.notFound, reason: "Not found Movie with id \(id)"))
            let genres = movie.flatMap(to: [Genre].self) { movie in
                try movie.genres.query(on: conn).all().map { $0.map { Genre(id: $0.id, name: $0.name) } }
            }
            let actors = movie.flatMap(to: [Actor].self) { movie in
                try movie.actors.query(on: conn).all().map { $0.map { Actor(id: $0.id, name: $0.name) } }
            }
            return map(to: MovieDetails.self, movie, genres, actors) { movie, genres, actors in
                MovieDetails(movie: self.mysqlMovieToEntity(movie), genres: genres, actors: actors)
            }
        }
    }
    
    func search(_ searchQuery: String) -> Future<[Movie]> {
        return db.withSQLConnection { conn in
            MySQLMovie.query(on: conn)
                .group(.or) { or in
                    or.filter(\.title ~~ searchQuery)
                    or.filter(\.homepage ~~ searchQuery)
                    or.filter(\.language == searchQuery)
                    or.filter(\.overview ~~ searchQuery)
                }
                .all()
                .map { $0.map { self.mysqlMovieToEntity($0) } }
        }
    }

    func getGenres(for movieId: Int) throws -> Future<[Genre]> {
        return db.requestConnection().flatMap { conn in
            return try self.find(in: MySQLMovie.self, id: movieId, conn: conn)
                .flatMap(to: [Genre].self) { movie in
                    return try movie.genres.query(on: conn)
                        .all()
                        .map { $0.map { Genre(id: $0.id, name: $0.name) } }
            }
        }
    }

    func attachGenre(with id: Int, to movieId: Int) throws -> Future<HTTPStatus> {
        return db.requestConnection().flatMap { conn in
            let genre = try self.find(in: MySQLGenre.self, id: movieId, conn: conn)
            let movie = try self.find(in: MySQLMovie.self, id: movieId, conn: conn)
            return flatMap(to: HTTPStatus.self, genre, movie) { genre, movie in
                let pivot = try MySQLMovieGenrePivot(movie.requireID(), genre.requireID())
                return pivot.save(on: conn).transform(to: .ok)
            }
        }
    }

    func getActors(for movieId: Int) throws -> Future<[Actor]> {
        return db.requestConnection().flatMap { conn in
            return try self.find(in: MySQLMovie.self, id: movieId, conn: conn)
                .flatMap(to: [Actor].self) { movie in
                    return try movie.actors.query(on: conn)
                        .all()
                        .map { $0.map { Actor(id: $0.id, name: $0.name) } }
            }
        }
    }

    func attachActor(with id: Int, to movieId: Int) throws -> Future<HTTPStatus> {
        return db.requestConnection().flatMap { conn in
            let actor = try self.find(in: MySQLActor.self, id: movieId, conn: conn)
            let movie = try self.find(in: MySQLMovie.self, id: movieId, conn: conn)
            return flatMap(to: HTTPStatus.self, actor, movie) { actor, movie in
                let pivot = try MySQLMovieActorPivot(movie.requireID(), actor.requireID())
                return pivot.save(on: conn).transform(to: .ok)
            }
        }
    }

    private func mysqlMovieToEntity(_ mysqlMovie: MySQLMovie) -> Movie {
        return  Movie(id: mysqlMovie.id,
                      title: mysqlMovie.title,
                      homepage: mysqlMovie.homepage,
                      language: mysqlMovie.language,
                      overview: mysqlMovie.overview)
    }
    
    private func find<T>(in: T.Type, id: Int, conn: MySQLConnection) throws -> Future<T> where T: MySQLModel {
        return T.find(id, on: conn)
            .unwrap(or: Abort(.notFound, reason: "Not found \(T.name) with id \(id)"))
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
