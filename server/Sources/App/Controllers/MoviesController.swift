import Vapor
import Fluent
import FluentSQL

struct MoviesController: RouteCollection, RestfulController {

    func boot(router: Router) throws {
        let moviesRoute = router.grouped("api", "movies")
        moviesRoute.get(use: getAllHandler)
        moviesRoute.post(use: createHandler)

        moviesRoute.get(Movie.parameter, use: getHandler)
        moviesRoute.put(Movie.parameter, use: updateHandler)
        moviesRoute.delete(Movie.parameter, use: deleteHandler)

        moviesRoute.get(Movie.parameter, "genres", use: getGenresHandler)
        moviesRoute.post(Movie.parameter, "genres", Genre.parameter, use: addGenresHandler)

        moviesRoute.get(Movie.parameter, "actors", use: getActorsHandler)
        moviesRoute.post(Movie.parameter, "actors", Actor.parameter, use: addActorsHandler)
    }
}

// MARK: - Movie handlers
extension MoviesController {
    func getAllHandler(_ req: Request) throws -> Future<[Movie]> {
        guard let searchQuery = req.query[String.self, at: "searchQuery"] else {
            return Movie.query(on: req).all()
        }

        return Movie.query(on: req).group(.or) { or in
            or.filter(\.title ~~ searchQuery)
            or.filter(\.homepage ~~ searchQuery)
            or.filter(\.language == searchQuery)
            or.filter(\.overview ~~ searchQuery)
            }.all()
    }

    func getHandler(_ req: Request) throws -> Future<MovieDetails> {
        let movieFuture = try req.parameters.next(Movie.self)
        let genresFuture = movieFuture.flatMap(to: [Genre].self) { movie in
            try movie.genres.query(on: req).all()
        }
        let actorsFuture = movieFuture.flatMap(to: [Actor].self ) { movie  in
            try movie.actors.query(on: req).all()
        }

        return map(to: MovieDetails.self, movieFuture, genresFuture, actorsFuture) { movie, genres, actors in
            MovieDetails(movie: movie, genres: genres, actors: actors)
        }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Movie.self).flatMap(to: HTTPStatus.self) { movie in
            return movie.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }

    func updateHandler(_ req: Request) throws -> Future<Movie> {
        return try flatMap(to: Movie.self, req.parameters.next(Movie.self),
                           req.content.decode(Movie.self)) { movie, updatedMovie in
                            movie.title = updatedMovie.title
                            return movie.save(on: req)
        }
    }
}

// MARK: - Genre siblings handlers
extension MoviesController {
    func getGenresHandler(_ req: Request) throws -> Future<[Genre]> {
        return try req.parameters.next(Movie.self).flatMap(to: [Genre].self) { movie in
            return try movie.genres.query(on: req).all()
        }
    }

    func addGenresHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Movie.self), req.parameters.next(Genre.self))
        { movie, genre in
            let pivot = try MovieGenrePivot(movie.requireID(), genre.requireID())
            return pivot.save(on: req).transform(to: .ok)
        }
    }
}

// MARK: - Actor siblings handlers
extension MoviesController {
    func getActorsHandler(_ req: Request) throws -> Future<[Actor]> {
        return try req.parameters.next(Movie.self).flatMap(to: [Actor].self) { movie in
            return try movie.actors.query(on: req).all()
        }
    }

    func addActorsHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Movie.self), req.parameters.next(Actor.self))
        { movie, actor in
            let pivot = try MovieActorPivot(movie.requireID(), actor.requireID())
            return pivot.save(on: req).transform(to: .ok)
        }
    }

}
