import Vapor

struct MoviesController: RouteCollection {

    private let movieRepository: MovieRepository

    init(movieRepository: MovieRepository) {
        self.movieRepository = movieRepository
    }

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
        return try req.content.decode(Movie.self).flatMap { self.movieRepository.save(movie: $0) }
    }

    func getAllHandler(_ req: Request) throws -> Future<[Movie]> {
        guard let searchQuery = req.query[String.self, at: "searchQuery"] else {
            return movieRepository.all()
        }
        return movieRepository.search(searchQuery)
    }

    func updateHandler(_ req: Request) throws -> Future<Movie> {
        let movie = try req.content.decode(Movie.self)
        let movieId = try req.parameters.next(Movie.self)
        return movie.flatMap { self.movieRepository.update(movie: $0, id: movieId) }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let movieId = try req.parameters.next(Movie.self)
        return try movieRepository.delete(id: movieId)
    }

    func getHandler(_ req: Request) throws -> Future<MovieDetails> {
        let movieId = try req.parameters.next(MovieDetails.self)
        return try movieRepository.movieDetails(id: movieId)
    }

    private func firstParam(in req: Request) throws -> Int {
        let param = try req.parameters.values.first.or(error: Abort(.badRequest, reason: "Invalid parameter"))
        return try Int(param.value).or(error: Abort(.badRequest, reason: "Invalid parameter"))
    }

}

// MARK: - Genre siblings handlers
extension MoviesController {
    func getGenresHandler(_ req: Request) throws -> Future<[Genre]> {
        let movieId = try firstParam(in: req)
        return try movieRepository.getGenres(for: movieId)
    }

    func addGenresHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let movieId = try req.parameters.next(Movie.self)
        let genreId = try req.parameters.next(Genre.self)
        return try movieRepository.attachGenre(with: movieId, to: genreId)
    }
}

// MARK: - Actor siblings handlers
extension MoviesController {
    func getActorsHandler(_ req: Request) throws -> Future<[Actor]> {
        let movieId = try firstParam(in: req)
        return try movieRepository.getActors(for: movieId)
    }

    func addActorsHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let movieId = try req.parameters.next(Movie.self)
        let actorId = try req.parameters.next(Actor.self)
        return try movieRepository.attachActor(with: movieId, to: actorId)
    }
}

