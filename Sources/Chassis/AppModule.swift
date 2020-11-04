//
//  File.swift
//  
//
//  Created by Daniel Eberle on 04.11.20.
//

import Foundation
import UIKit

open class AppModule: UIResponder {

    public static func setup(modules: [AppModule] ) {

        zip(modules, modules.dropFirst()).forEach {

            $0.nextModule = $1
        }
    }

    var nextModule: AppModule?

    public override var next: UIResponder? {

        return self.nextModule
    }
}

