import Vapor

struct GenresController: RouteCollection {

    func boot(router: Router) throws {
        let genresRoute = router.grouped("api", "genres")
        genresRoute.post(use: createHandler)
        genresRoute.get(use: getAllHandler)
        genresRoute.get(Genre.parameter, use: getHandler)
        genresRoute.delete(Genre.parameter, use: deleteHandler)

    }
}

// MARK: - Genre handlers

extension GenresController {
    func createHandler(_ req: Request) throws -> Future<Genre> {
        let repository = try req.make(GenreRepository.self)
        return try req.content.decode(Genre.self).flatMap { repository.save(genre: $0) }
    }

    func getAllHandler(_ req: Request) throws -> Future<[Genre]> {
        let repository = try req.make(GenreRepository.self)
        return repository.all()
    }

    func getHandler(_ req: Request) throws -> Future<Genre> {
        let repository = try req.make(GenreRepository.self)
        let genreId = try req.parameters.next(Genre.self)
        return try repository.find(id: genreId)
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let repository = try req.make(GenreRepository.self)
        let genreId = try req.parameters.next(Genre.self)
        return try repository.delete(id: genreId)
    }
}
