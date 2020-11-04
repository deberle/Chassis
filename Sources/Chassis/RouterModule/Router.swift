//
//  Router.swift
//  PTC_Traditional
//
//  Created by Daniel Eberle on 13.09.20.
//

import Foundation
import UIKit
import CoreData



public class RoutingEvent: UIEvent {

    let viewController: UIViewController
    let route: Route
    let animated: Bool

    public init(viewController: UIViewController, route: Route, animated: Bool = true) {
        self.viewController = viewController
        self.route = route
        self.animated = animated
    }
}

public protocol Route {

    func viewController() -> UIViewController
}

public class Router: AppModule {

    @IBAction public func route(sender: Any?, event: RoutingEvent) {

        event.viewController.navigationController?.pushViewController(event.route.viewController(), animated: event.animated)
    }
}
