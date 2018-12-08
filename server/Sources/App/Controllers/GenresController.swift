import Vapor

struct GenresController: RouteCollection {
    
    func boot(router: Router) throws {
        let genresRoute = router.grouped("api", "genres")
        genresRoute.post(use: createHandler)
        genresRoute.get(use: getAllHandler)
        genresRoute.get(Genre.parameter, use: getHandler)
        genresRoute.get(Genre.parameter, "movies", use: getMoviesHandler)
    }

    func createHandler(_ req: Request) throws -> Future<Genre> {
        let genre = try req.content.decode(Genre.self)
        return genre.save(on: req)
    }

    func getAllHandler(_ req: Request) throws -> Future<[Genre]> {
        return Genre.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<Genre> {
        return try req.parameters.next(Genre.self)
    }

    func getMoviesHandler(_ req: Request) throws -> Future<[Movie]> {
        return try req.parameters.next(Genre.self).flatMap(to: [Movie].self) { genre in
            return try genre.movies.query(on: req).all()
        }
    }
    
}
