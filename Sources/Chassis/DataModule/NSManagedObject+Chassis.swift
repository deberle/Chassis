//
//  NSManagedObject+Chassis.swift
//  
//
//  Created by Daniel Eberle on 02.03.21.
//

import CoreData



extension NSManagedObject {

    @objc
    open func stringValue(forAttribute attribute: NSAttributeDescription) -> String? {

        let stringValue: String?
        switch (attribute.attributeType) {
        case (.stringAttributeType):
            stringValue = self.value(forKey: attribute.name) as? String
        case (.doubleAttributeType):
            stringValue = (self.value(forKey: attribute.name) as? Double)?.description
        default:
            stringValue = nil
        }
        return stringValue
    }

    @objc
    open func setStringValue(_ string: String?, forAttribute attribute: NSAttributeDescription) {

        switch (attribute.attributeType) {
        case (.stringAttributeType):
            self.setValue(string, forKey: attribute.name)
        case (.doubleAttributeType):
            self.setValue(string != nil ? Double(string!) : nil, forKey: attribute.name)
        default: break
        }
    }
}
