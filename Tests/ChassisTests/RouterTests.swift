//
//  RouterTest.Swift
//  
//
//  Created by Daniel Eberle on 04.11.20.
//

import XCTest
import UIKit
@testable import Chassis

enum TestRoute: Route {

case test1

    func viewController() -> UIViewController {
        
        switch self {
        case .test1:
            let vc = UIViewController()
            vc.title = "test1"
            return vc
        }
    }
}

final class RouterTests: XCTestCase {

    func testRoute() {

        let vc = UIViewController()
        let nc = UINavigationController(rootViewController: vc)
        let router = Router()
        let event = RoutingEvent(viewController: vc, route: TestRoute.test1, animated: false)
        router.route(sender: nil, event: event)

        XCTAssertEqual(nc.topViewController?.title, "test1")
    }
}


