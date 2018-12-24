import Vapor

struct MoviesController: RouteCollection {

    func boot(router: Router) throws {
        let moviesRoute = router.grouped("api", "movies")
        moviesRoute.post(use: createHandler)
        moviesRoute.get(use: getAllHandler)
        moviesRoute.put(Movie.parameter, use: updateHandler)
        moviesRoute.delete(Movie.parameter, use: deleteHandler)
        moviesRoute.get(MovieDetails.parameter, use: getHandler)

        moviesRoute.get(Movie.parameter, "genres", use: getGenresHandler)
        moviesRoute.post(Movie.parameter, "genres", Genre.parameter, use: addGenresHandler)

        moviesRoute.get(Movie.parameter, "actors", use: getActorsHandler)
        moviesRoute.post(Movie.parameter, "actors", Actor.parameter, use: addActorsHandler)
    }
}

// MARK: - Movie handlers

extension MoviesController {

    func createHandler(_ req: Request) throws -> Future<Movie> {
        let repository = try req.make(MovieRepository.self)
        return try req.content.decode(Movie.self).flatMap { repository.save(movie: $0) }
    }

    func getAllHandler(_ req: Request) throws -> Future<[Movie]> {
        let repository = try req.make(MovieRepository.self)

        guard let searchQuery = req.query[String.self, at: "searchQuery"] else {
            return repository.all()
        }
        return repository.search(searchQuery)
    }

    func updateHandler(_ req: Request) throws -> Future<Movie> {
        let repository = try req.make(MovieRepository.self)
        let movie = try req.content.decode(Movie.self)
        let movieId = try req.parameters.next(Movie.self)
        return movie.flatMap { repository.update(movie: $0, id: movieId) }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let repository = try req.make(MovieRepository.self)
        let movieId = try req.parameters.next(Movie.self)
        return try repository.delete(id: movieId)
    }

    func getHandler(_ req: Request) throws -> Future<MovieDetails> {
        let repository = try req.make(MovieRepository.self)
        let movieId = try req.parameters.next(MovieDetails.self)
        return try repository.movieDetails(id: movieId)
    }

    private func firstParam(in req: Request) throws -> Int {
        let param = try req.parameters.values.first.or(error: Abort(.badRequest, reason: "Invalid parameter"))
        return try Int(param.value).or(error: Abort(.badRequest, reason: "Invalid parameter"))
    }

}

// MARK: - Genre siblings handlers
extension MoviesController {
    func getGenresHandler(_ req: Request) throws -> Future<[Genre]> {
        let repository = try req.make(MovieRepository.self)
        let movieId = try firstParam(in: req)
        return try repository.getGenres(for: movieId)
    }

    func addGenresHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let repository = try req.make(MovieRepository.self)
        let movieId = try req.parameters.next(Movie.self)
        let genreId = try req.parameters.next(Genre.self)
        return try repository.attachGenre(with: movieId, to: genreId)
    }
}

// MARK: - Actor siblings handlers
extension MoviesController {
    func getActorsHandler(_ req: Request) throws -> Future<[Actor]> {
        let repository = try req.make(MovieRepository.self)
        let movieId = try firstParam(in: req)
        return try repository.getActors(for: movieId)
    }

    func addActorsHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let repository = try req.make(MovieRepository.self)
        let movieId = try req.parameters.next(Movie.self)
        let actorId = try req.parameters.next(Actor.self)
        return try repository.attachActor(with: movieId, to: actorId)
    }
}

