import Vapor
import App
import FluentMySQL

//MARK: - Setup
extension Application {

    static func setup(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing

        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }

        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)
        return app
    }
}

//MARK: - Sending requests
extension Application {
    func sendRequest<T>(to path: String,
                               method: HTTPMethod,
                               queryItems: [URLQueryItem] = [URLQueryItem](),
                               headers: HTTPHeaders = .init(),
                               body: T? = nil) throws -> Response where T: Content {

        let responder = try self.make(Responder.self)
        var url = URLComponents(string: path)!
        url.queryItems = queryItems
        url.queryItems!.append(URLQueryItem(name: "apiKey", value: try Helpers.getApiKey()))
        let request = HTTPRequest(method: method, url: url.url!, headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        return try responder.respond(to: wrappedRequest).wait()
    }

    func getRequest(to path: String,
                    queryItems: [URLQueryItem] = [URLQueryItem](),
                    headers: HTTPHeaders = .init()) throws -> Response {

        let emptyContent: EmptyContent? = nil
        return try sendRequest(to: path, method: .GET, queryItems: queryItems, headers: headers, body: emptyContent)
    }

    struct EmptyContent: Content {}
}
