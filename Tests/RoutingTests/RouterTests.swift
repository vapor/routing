import Async
import Dispatch
import Bits
import Routing
import Service
import XCTest

class RouterTests: XCTestCase {
    func testRouter() throws {
        let router = TrieRouter<Int>()

        let path: [PathComponent.Parameter] = [.string("foo"), .string("bar"), .string("baz")]

        let route = Route<Int>(path: [.constants(path), .parameter], output: 42)
        router.register(route: route)

        let container = BasicContainer(
            config: Config(),
            environment: .development,
            services: Services(),
            on: wrap(EmbeddedEventLoop())
        )
        let params = Params()
        XCTAssertEqual(router.route(path: path + [.string("Tanner")], parameters: params), 42)
        try XCTAssertEqual(params.parameter(User.self, using: container).wait().name, "Tanner")
    }
    
    func testCaseSensitiveRouting() throws {
        let router = TrieRouter<Int>()
        
        let path: [PathComponent.Parameter] = [.string("path"), .string("TO"), .string("fOo")]
        
        let route = Route<Int>(path: [.constants(path)], output: 42)
        router.register(route: route)
        
        let params = Params()
        XCTAssertEqual(router.route(path: [.string("PATH"), .string("tO"), .string("FOo")], parameters: params), nil)
        XCTAssertEqual(router.route(path: [.string("path"), .string("TO"), .string("fOo")], parameters: params), 42)
    }
    
    func testCaseInsensitiveRouting() throws {
        let router = TrieRouter<Int>()
        router.caseInsensitive = true
        
        let path: [PathComponent.Parameter] = [.string("path"), .string("TO"), .string("fOo")]
        
        let route = Route<Int>(path: [.constants(path)], output: 42)
        router.register(route: route)
        
        let params = Params()
        XCTAssertEqual(router.route(path: [.string("PATH"), .string("tO"), .string("FOo")], parameters: params), 42)
    }

    func testAnyRouting() throws {
        let router = TrieRouter<Int>()
        
        let route0 = Route<Int>(path: [
            .constants([.string("a")]),
            .anything
        ], output: 0)
        
        let route1 = Route<Int>(path: [
            .constants([.string("b")]),
            .parameter,
            .anything
        ], output: 1)
        
        let route2 = Route<Int>(path: [
            .constants([.string("c")]),
            .parameter,
            .parameter,
            .anything
        ], output: 2)
        
        let route3 = Route<Int>(path: [
            .constants([.string("d")]),
            .parameter,
            .parameter,
        ], output: 3)
        
        let route4 = Route<Int>(path: [
            .constants([.string("e")]),
            .parameter,
            .anything,
            .constants([.string("a")])
        ], output: 4)
        
        router.register(route: route0)
        router.register(route: route1)
        router.register(route: route2)
        router.register(route: route3)
        router.register(route: route4)
        
        XCTAssertEqual(
            router.route(path: [.string("a"), .string("b")], parameters: Params()),
            0
        )
        
        XCTAssertNil(router.route(path: [.string("a")], parameters: Params()))
        
        XCTAssertEqual(
            router.route(path: [.string("a"), .string("a")], parameters: Params()),
            0
        )
        
        XCTAssertEqual(
            router.route(path: [.string("b"), .string("a"), .string("c")], parameters: Params()),
            1
        )
        
        XCTAssertNil(router.route(path: [.string("b")], parameters: Params()))
        XCTAssertNil(router.route(path: [.string("b"), .string("a")], parameters: Params()))
        
        XCTAssertEqual(
            router.route(path: [.string("b"), .string("a"), .string("c")], parameters: Params()),
            1
        )
        
        XCTAssertNil(router.route(path: [.string("c")], parameters: Params()))
        XCTAssertNil(router.route(path: [.string("c"), .string("a")], parameters: Params()))
        XCTAssertNil(router.route(path: [.string("c"), .string("b")], parameters: Params()))
        
        XCTAssertEqual(
            router.route(path: [.string("d"), .string("a"), .string("b")], parameters: Params()),
            3
        )
        
        XCTAssertNil(router.route(path: [.string("d"), .string("a"), .string("b"), .string("c")], parameters: Params()))
        XCTAssertNil(router.route(path: [.string("d"), .string("a")], parameters: Params()))
        
        XCTAssertEqual(
            router.route(path: [.string("e"), .string("a"), .string("b"), .string("a")], parameters: Params()),
            4
        )
    }
    
    func testConflictingParameters() throws {
        let router = TrieRouter<Bool>()
        
        let path: [PathComponent.Parameter] = [.string("component")]
        
        let route = Route<Bool>(path: [.constants(path), .parameter], output: true)
        router.register(route: route)
        
        let route2 = Route<Bool>(path: [.constants(path), .parameter, .constants(path)], output: false)
        router.register(route: route2)
        
        let params = Params()
        XCTAssertEqual(router.route(path: [.string("component"), .string("aaa"), .string("component")], parameters: params), false)
        XCTAssertEqual(router.route(path: [.string("component"), .string("TO")], parameters: params), true)
        XCTAssertEqual(router.route(path: [.string("component")], parameters: params), nil)
    }

    func testRouterSuffixes() throws {
        let router = TrieRouter<Int>()
        router.caseInsensitive = true

        let path1: [PathComponent.Parameter] = [.string("a")]
        let path2: [PathComponent.Parameter] = [.string("aa")]
        let route1 = Route<Int>(path: [.constants(path1)], output: 1)
        let route2 = Route<Int>(path: [.constants(path2)], output: 2)
        router.register(route: route1)
        router.register(route: route2)

        let params = Params()
        XCTAssertEqual(router.route(path: [.string("a")], parameters: params), 1)
        XCTAssertEqual(router.route(path: [.string("aa")], parameters: params), 2)
    }

    static let allTests = [
        ("testRouter", testRouter),
        ("testCaseInsensitiveRouting", testCaseInsensitiveRouting),
        ("testCaseSensitiveRouting", testCaseSensitiveRouting),
        ("testAnyRouting", testAnyRouting),
        ("testRouterSuffixes", testRouterSuffixes),
        ("testConflictingParameters", testConflictingParameters),
    ]
}

final class Params: ParameterContainer {
    var parameters: Parameters = []
    init() {}
}

final class User: Parameter {
    var name: String

    init(name: String) {
        self.name = name
    }

    static func make(for parameter: String, using container: Container) throws -> Future<User> {
        return Future.map(on: container) { User(name: parameter) }
    }
}
