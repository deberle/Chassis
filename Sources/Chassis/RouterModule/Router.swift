//
//  Router.swift
//  Chassis
//
//  Created by Daniel Eberle on 13.09.20.
//

import Foundation
import UIKit
import CoreData



public class RoutingEvent: UIEvent {

    let viewController: UIViewController?
    let window: UIWindow?
    let route: Route
    let animated: Bool

    public init(viewController: UIViewController?, window: UIWindow? = nil, route: Route, animated: Bool = true) {
        self.viewController = viewController
        self.window = window
        self.route = route
        self.animated = animated
    }
}

public protocol Route {

    func viewController(router: Router) -> UIViewController
}

public class Router: AppModule {
    
    public let persistenceController: PersistenceController
    
    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        super.init()
    }

    @IBAction public func route(sender: Any?, event: RoutingEvent) {

        if let viewController = event.viewController {
            viewController.navigationController?.pushViewController(event.route.viewController(router: self), animated: event.animated)
        }
        
        if let window = event.window {
            window.rootViewController = event.route.viewController(router: self)
        }
    }
}
