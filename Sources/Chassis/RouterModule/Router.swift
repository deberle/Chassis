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
    let modal: Bool

    public init(viewController: UIViewController?, window: UIWindow? = nil, route: Route, animated: Bool = true, modal: Bool = false) {
        self.viewController = viewController
        self.window = window
        self.route = route
        self.animated = animated
        self.modal = modal
        super.init()
    }
}

public protocol Route {

    func viewController(router: Router) -> UIViewController
}

public class Router: AppModule {
    
    public let persistenceController: PersistenceController
    private var rootViewController: UIViewController?
    
    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        super.init()
    }

    @IBAction public func route(sender: Any?, event: RoutingEvent) {

        if let viewController = event.viewController {

            viewController.navigationController?.pushViewController(event.route.viewController(router: self), animated: event.animated)
        } else if let window = event.window {

            let viewController = event.route.viewController(router: self).wrappendInNavigationController()
            window.rootViewController = viewController
            self.rootViewController = window.rootViewController
        } else if let rootViewController = self.rootViewController {

            let viewController = event.route.viewController(router: self)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: viewController, action: #selector(UIViewController.dismiss(sender:)))
            let navigationController = UINavigationController(rootViewController: viewController)
            rootViewController.present(navigationController, animated: true, completion: nil)
        }
    }
}

extension UIViewController {

    public func wrappendInNavigationController() -> UIViewController  {

        var viewController = self
        
        let excludedController = [UINavigationController.self, UITabBarController.self, UISplitViewController.self]

        if (excludedController.allSatisfy { !viewController.isKind(of: $0) }) {

            viewController = UINavigationController(rootViewController: viewController)
        }
        return viewController
    }
}

extension UIViewController {

    @objc func dismiss(sender: Any?) {

        self.dismiss(animated: true, completion: nil)
    }
}
