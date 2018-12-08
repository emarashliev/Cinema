import Vapor
import FluentMySQL

protocol RestfulController {

    typealias ModelType = MySQLModel & Parameter
    associatedtype Model: ModelType

    func createHandler(_ req: Request) throws -> Future<Model>
    func getAllHandler(_ req: Request) throws -> Future<[Model]>
    func getHandler(_ req: Request) throws -> Future<Model>
}

extension RestfulController {

    func createHandler(_ req: Request) throws -> Future<Model> {
        let genre = try req.content.decode(Model.self)
        return genre.save(on: req)
    }

    func getAllHandler(_ req: Request) throws -> Future<[Model]> {
        return Model.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<Model> {
        return try req.parameters.next(Model.self) as! EventLoopFuture<Self.Model>
    }

}
