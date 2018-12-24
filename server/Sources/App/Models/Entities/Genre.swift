import Vapor

struct Genre: Content {

    var id: Int?
    var name: String
}

extension Genre: BaseEntity {}
