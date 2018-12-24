import Vapor

struct Movie: Content {

    var id: Int?
    var title: String
    var homepage: String
    var language: String
    var overview: String
}

extension Movie: BaseEntity {}
