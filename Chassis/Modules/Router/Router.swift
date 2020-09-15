//
//  Router.swift
//  Chassis
//
//  Created by Daniel Eberle on 13.09.20.
//

import Foundation
import UIKit
import CoreData



class RoutingEvent: UIEvent {
    
    let viewController: UIViewController
    let route: Route
    
    init(viewController: UIViewController, route: Route) {
        self.viewController = viewController
        self.route = route
    }
}

enum Route {
    
    case detailView(_ objectID: NSManagedObjectID)
    
    func viewController() -> UIViewController {
        switch self {
        case .detailView(let objectID):
            let controller = UIStoryboard(name: "DetailViewController", bundle: nil)
                .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            controller.objectID = objectID
            return controller
        }
    }
}

class Router: AppModule {
    
    @IBAction func route(sender: Any?, event: RoutingEvent) {

        event.viewController.navigationController?.pushViewController(event.route.viewController(), animated: true)
    }
}
