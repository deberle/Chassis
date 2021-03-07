//
//  CoreDataError.swift
//  
//
//  Created by Daniel Eberle on 07.03.21.
//

import Foundation
import CoreData


public struct CoreDataError {

    enum ErrorType: String {

        case validation = "NSManagedObjectValidationError"
        case missingMandatoryProperty = "NSValidationMissingMandatoryPropertyError"
        case relationshipLacksMinimumCount = "NSValidationRelationshipLacksMinimumCountError"
        case relationshipExceedsMaximumCount = "NSValidationRelationshipExceedsMaximumCountError"
        case relationshipDeniedDelete = "NSValidationRelationshipDeniedDeleteError"
        case numberTooLarge = "NSValidationNumberTooLargeError"
        case numberTooSmall = "NSValidationNumberTooSmallError"
        case dateTooLate = "NSValidationDateTooLateError"
        case dateTooSoon = "NSValidationDateTooSoonError"
        case invalidDate = "NSValidationInvalidDateError"
        case stringTooLong = "NSValidationStringTooLongError"
        case stringTooShort = "NSValidationStringTooShortError"
        case stringPatternMatching = "NSValidationStringPatternMatchingError"

        init?(_ error: NSError) {

            switch error.code {
            case NSManagedObjectValidationError: self = .validation
            case NSValidationMissingMandatoryPropertyError: self = .missingMandatoryProperty
            case NSValidationRelationshipLacksMinimumCountError: self = .relationshipLacksMinimumCount
            case NSValidationRelationshipExceedsMaximumCountError: self = .relationshipExceedsMaximumCount
            case NSValidationRelationshipDeniedDeleteError: self = .relationshipDeniedDelete
            case NSValidationNumberTooLargeError: self = .numberTooLarge
            case NSValidationNumberTooSmallError: self = .numberTooSmall
            case NSValidationDateTooLateError: self = .dateTooLate
            case NSValidationDateTooSoonError: self = .dateTooSoon
            case NSValidationInvalidDateError: self = .invalidDate
            case NSValidationStringTooLongError: self = .stringTooLong
            case NSValidationStringTooShortError: self = .stringTooShort
            case NSValidationStringPatternMatchingError: self = .stringPatternMatching
            default: return nil
            }
        }
    }

    public let error: NSError
    public let managedObject: NSManagedObject?
    public let attributeName: String?
    public var entity: NSEntityDescription? {

        managedObject?.entity
    }
    public var attribute: NSAttributeDescription? {

        managedObject?.entity.attributesByName[self.attributeName ?? ""]
    }
    public var errorString: String {

        ErrorType(error)?.rawValue ?? error.localizedDescription
    }

    init(_ error: NSError) {

        self.error = error
        self.managedObject = error.userInfo["NSValidationErrorObject"] as? NSManagedObject
        self.attributeName = error.userInfo["NSValidationErrorKey"] as? String
    }

    public static func parseCoreDataErrors(_ error: Error) -> [Self] {

        let nsError: NSError = error as NSError
        let nsErrors: [NSError]
        if nsError.code == NSValidationMultipleErrorsError,
           let e = (nsError.userInfo["NSDetailedErrors"]) as? [NSError] {
            nsErrors = e
        } else {
            nsErrors = [nsError]
        }
        return nsErrors.map { Self($0) }
    }
}
