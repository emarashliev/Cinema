import Vapor

struct Actor: Content {

    var id: Int?
    var name: String
}

extension Actor: BaseEntity {}
