//
//  NSManagedObject+Chassis.swift
//  
//
//  Created by Daniel Eberle on 02.03.21.
//

import CoreData



extension NSManagedObject {
    
    static var dateFormatter: DateFormatter = {

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    @objc
    open func stringValue(forAttributeName attributeName: String) -> String? {

        guard let attribute = self.entity.attributesByName[attributeName] else { return nil }
        return self.stringValue(forAttribute: attribute)
    }

    @objc
    open func stringValue(forAttribute attribute: NSAttributeDescription) -> String? {

        let stringValue: String?
        switch (attribute.attributeType) {
        case (.stringAttributeType):
            stringValue = self.value(forKey: attribute.name) as? String
        case (.doubleAttributeType):
            stringValue = (self.value(forKey: attribute.name) as? Double)?.description
        case (.dateAttributeType):
            stringValue = type(of: self).dateFormatter.string(from: (self.value(forKey: attribute.name) as! Date))
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
