import RoutingKit
import XCTest

final class RouterTests: XCTestCase {
    func testRouter() throws {
        let route = Route(path: ["foo", "bar", "baz", ":user"], output: 42)
        let router = TrieRouter(Int.self)
        router.register(route: route)
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["foo", "bar", "baz", "Tanner"], parameters: &params), 42)
        XCTAssertEqual(params.get("user"), "Tanner")
    }
    
    func testCaseSensitiveRouting() throws {
        let route = Route<Int>(path: [.constant("path"), .constant("TO"), .constant("fOo")], output: 42)
        let router = TrieRouter<Int>()
        router.register(route: route)
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["PATH", "tO", "FOo"], parameters: &params), nil)
        XCTAssertEqual(router.route(path: ["path", "TO", "fOo"], parameters: &params), 42)
    }
    
    func testCaseInsensitiveRouting() throws {
        let route = Route<Int>(path: [.constant("path"), .constant("TO"), .constant("fOo")], output: 42)
        let router = TrieRouter<Int>(options: [.caseInsensitive])
        router.register(route: route)
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["PATH", "tO", "FOo"], parameters: &params), 42)
    }

    func testAnyRouting() throws {
        let route0 = Route<Int>(path: [.constant("a"), .anything], output: 0)
        let route1 = Route<Int>(path: [.constant("b"), .parameter("1"), .anything], output: 1)
        let route2 = Route<Int>(path: [.constant("c"), .parameter("1"), .parameter("2"), .anything], output: 2)
        let route3 = Route<Int>(path: [.constant("d"), .parameter("1"), .parameter("2")], output: 3)
        let route4 = Route<Int>(path: [.constant("e"), .parameter("1"), .catchall], output: 4)
        let route5 = Route<Int>(path: [.anything, .constant("e"), .parameter("1")], output: 5)

        let router = TrieRouter<Int>()
        router.register(route: route0)
        router.register(route: route1)
        router.register(route: route2)
        router.register(route: route3)
        router.register(route: route4)
        router.register(route: route5)

        var params = Parameters()
        XCTAssertEqual(router.route(path: ["a", "b"], parameters: &params), 0)
        XCTAssertNil(router.route(path: ["a"], parameters: &params))
        XCTAssertEqual(router.route(path: ["a", "a"], parameters: &params), 0)
        XCTAssertEqual(router.route(path: ["b", "a", "c"], parameters: &params), 1)
        XCTAssertNil(router.route(path: ["b"], parameters: &params))
        XCTAssertNil(router.route(path: ["b", "a"], parameters: &params))
        XCTAssertEqual(router.route(path: ["b", "a", "c"], parameters: &params), 1)
        XCTAssertNil(router.route(path: ["c"], parameters: &params))
        XCTAssertNil(router.route(path: ["c", "a"], parameters: &params))
        XCTAssertNil(router.route(path: ["c", "b"], parameters: &params))
        XCTAssertEqual(router.route(path: ["d", "a", "b"], parameters: &params), 3)
        XCTAssertNil(router.route(path: ["d", "a", "b", "c"], parameters: &params))
        XCTAssertNil(router.route(path: ["d", "a"], parameters: &params))
        XCTAssertEqual(router.route(path: ["e", "1", "b", "a"], parameters: &params), 4)
        XCTAssertEqual(router.route(path: ["f", "e", "1"], parameters: &params), 5)
        XCTAssertEqual(router.route(path: ["g", "e", "1"], parameters: &params), 5)
        XCTAssertEqual(router.route(path: ["g", "e", "1"], parameters: &params), 5)
    }

    func testRouterSuffixes() throws {
        let route1 = Route<Int>(path: [.constant("a")], output: 1)
        let route2 = Route<Int>(path: [.constant("aa")], output: 2)

        let router = TrieRouter<Int>(options: [.caseInsensitive])
        router.register(route: route1)
        router.register(route: route2)

        var params = Parameters()
        XCTAssertEqual(router.route(path: ["a"], parameters: &params), 1)
        XCTAssertEqual(router.route(path: ["aa"], parameters: &params), 2)
    }


    func testDocBlock() throws {
        let route = Route<Int>(path: ["users", ":user"], output: 42)
        let router = TrieRouter<Int>()
        router.register(route: route)
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["users", "Tanner"], parameters: &params), 42)
        XCTAssertEqual(params.get("user"), "Tanner")
    }

    func testDocs() throws {
        let router = TrieRouter(Double.self)
        router.register(route: Route(path: ["fun", "meaning_of_universe"], output: 42))
        router.register(route: Route(path: ["fun", "leet"], output: 1337))
        router.register(route: Route(path: ["math", "pi"], output: 3.14))
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["fun", "meaning_of_universe"], parameters: &params), 42)
    }

    func testDocs2() throws {
        let router = TrieRouter(String.self)
        router.register(route: Route(path: [.constant("users"), .parameter("user_id")], output: "show_user"))

        var params = Parameters()
        _ = router.route(path: ["users", "42"], parameters: &params)
        print(params)
    }
    
    // https://github.com/vapor/routing/issues/64
    func testParameterPercentDecoding() throws {
        let router = TrieRouter(String.self)
        router.register(route: Route(path: [.constant("a"), .parameter("b")], output: "c"))
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["a", "te%20st"], parameters: &params), "c")
        XCTAssertEqual(params.get("b"), "te st")
    }

    // https://github.com/vapor/routing-kit/issues/74
    func testCatchAllNested() throws {
        let router = TrieRouter(String.self)
        router.register(route: Route(path: [.catchall], output: "/**"))
        router.register(route: Route(path: ["a", .catchall], output: "/a/**"))
        router.register(route: Route(path: ["a", "b", .catchall], output: "/a/b/**"))
        router.register(route: Route(path: ["a", "b"], output: "/a/b"))
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["a"], parameters: &params), "/**")
        XCTAssertEqual(router.route(path: ["a", "b"], parameters: &params), "/a/b")
        XCTAssertEqual(router.route(path: ["a", "b", "c"], parameters: &params), "/a/b/**")
        XCTAssertEqual(router.route(path: ["a", "c"], parameters: &params), "/a/**")
        XCTAssertEqual(router.route(path: ["b"], parameters: &params), "/**")
        XCTAssertEqual(router.route(path: ["b", "c", "d", "e"], parameters: &params), "/**")
    }

    func testCatchAllPrecedence() throws {
        let router = TrieRouter(String.self)
        router.register(route: Route(path: ["v1", "test"], output: "a"))
        router.register(route: Route(path: ["v1", .catchall], output: "b"))
        router.register(route: Route(path: ["v1", .anything], output: "c"))
        var params = Parameters()
        XCTAssertEqual(router.route(path: ["v1", "test"], parameters: &params), "a")
        XCTAssertEqual(router.route(path: ["v1", "test", "foo"], parameters: &params), "b")
        XCTAssertEqual(router.route(path: ["v1", "foo"], parameters: &params), "c")
    }
}
