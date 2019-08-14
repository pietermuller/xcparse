//
//  XCPResultDecoding.swift
//  xcparse
//
//  Created by Alex Botkin on 8/13/19.
//  Copyright © 2019 ChargePoint, Inc. All rights reserved.
//

import Foundation

class XCResultType : Codable {
    let name: String
    
    private enum CodingKeys : String, CodingKey {
        case name = "_name"
    }
}

class XCResultArrayValue<T: Codable> : Codable {
    let values: [T]
    
    private enum CodingKeys : String, CodingKey {
        case values = "_values"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decode(family: XCResultTypeFamily.self, forKey: .values)
    }
}

class XCResultValueType : Codable {
    let type: XCResultType
    let value: String
    
    private enum CodingKeys : String, CodingKey {
        case type = "_type"
        case value = "_value"
    }
    
    func getValue() -> Any? {
        if self.type.name == "Bool" {
            return Bool(self.value)
        } else if self.type.name == "Date" {
            let df = ISO8601DateFormatter()
            df.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            return df.date(from: self.value)
        } else if self.type.name == "Double" {
            return Double(self.value)
        } else if self.type.name == "Int" {
            return Int(self.value)
        } else {
            return self.value
        }
    }
}

class XCResultObject: Codable {
    let type: XCResultObjectType
    
    private enum CodingKeys : String, CodingKey {
        case type = "_type"
    }
}

class XCResultObjectType: Codable {
    let name: String
    let supertype: XCResultObjectType?
    
    private enum CodingKeys : String, CodingKey {
        case name = "_name"
        case supertype = "_supertype"
    }
    
    func getType() -> AnyObject.Type {
        if let type = XCResultTypeFamily(rawValue: self.name) {
            return type.getType()
        } else if let parentType = supertype {
            return parentType.getType()
        } else {
            return XCResultObjectType.self
        }
    }
}

// MARK: -
// MARK: Heterogenous Decoding

// Note: This part largely copies the homework of Kewin Remeczki's article on Swift 4 Decodable
//       and heterogenous collections. Likely need to re-examine & refactor parts here to our use case
// See: https://medium.com/@kewindannerfjordremeczki/swift-4-0-decodable-heterogeneous-collections-ecc0e6b468cf

/// These are the generic methods

/// To support a new class family, create an enum that conforms to this protocol and contains the different types.
protocol ClassFamily: Decodable {
    /// The discriminator key.
    static var discriminator: Discriminator { get }
    
    /// Returns the class type of the object coresponding to the value.
    func getType() -> AnyObject.Type
}

/// Discriminator key enum used to retrieve discriminator fields in JSON payloads.
enum Discriminator: String, CodingKey {
    case type = "_type"
}

/// An enum that assist in determining what XCResultObject type we need to parse as
enum XCResultTypeFamily: String, ClassFamily {
    case ActionAbstractTestSummary
    case ActionDeviceRecord
    case ActionPlatformRecord
    case ActionRecord
    case ActionResult
    case ActionRunDestinationRecord
    case ActionSDKRecord
    case ActionTestActivitySummary
    case ActionTestAttachment
    case ActionTestFailureSummary
    case ActionTestMetadata
    case ActionTestPerformanceMetricSummary
    case ActionTestPlanRunSummaries
    case ActionTestPlanRunSummary
    case ActionTestSummary
    case ActionTestSummaryGroup
    case ActionTestSummaryIdentifiableObject
    case ActionTestableSummary
    case ActionsInvocationMetadata
    case ActionsInvocationRecord
    case ActivityLogCommandInvocationSection
    case ActivityLogMajorSection
    case ActivityLogMessage
    case ActivityLogMessageAnnotation
    case ActivityLogSection
    case ActivityLogTargetBuildSection
    case ActivityLogUnitTestSection
    case ArchiveInfo
    case Array
    case Bool
    case CodeCoverageInfo
    case Date
    case DocumentLocation
    case Double
    case EntityIdentifier
    case Int
    case IssueSummary
    case ObjectID
    case Reference
    case ResultIssueSummaries
    case ResultMetrics
    case SortedKeyValueArray
    case SortedKeyValueArrayPair
    case String
    case TestFailureIssueSummary
    case TypeDefinition
    
    static var discriminator: Discriminator = .type
    
    func getType() -> AnyObject.Type {
        switch self {
        case .ActionAbstractTestSummary:
            return xcparse.ActionAbstractTestSummary.self
        case .ActionDeviceRecord:
            return xcparse.ActionDeviceRecord.self
        case .ActionPlatformRecord:
            return xcparse.ActionPlatformRecord.self
        case .ActionRecord:
            return xcparse.ActionRecord.self
        case .ActionResult:
            return xcparse.ActionResult.self
        case .ActionRunDestinationRecord:
            return xcparse.ActionRunDestinationRecord.self
        case .ActionSDKRecord:
            return xcparse.ActionSDKRecord.self
        case .ActionTestActivitySummary:
            return xcparse.ActionTestActivitySummary.self
        case .ActionTestAttachment:
            return xcparse.ActionTestAttachment.self
        case .ActionTestFailureSummary:
            return xcparse.ActionTestActivitySummary.self
        case .ActionTestMetadata:
            return xcparse.ActionTestMetadata.self
        case .ActionTestPerformanceMetricSummary:
            return xcparse.ActionTestPerformanceMetricSummary.self
        case .ActionTestPlanRunSummaries:
            return xcparse.ActionTestPlanRunSummaries.self
        case .ActionTestPlanRunSummary:
            return xcparse.ActionTestPlanRunSummary.self
        case .ActionTestSummary:
            return xcparse.ActionTestSummary.self
        case .ActionTestSummaryGroup:
            return xcparse.ActionTestSummaryGroup.self
        case .ActionTestSummaryIdentifiableObject:
            return xcparse.ActionTestSummaryIdentifiableObject.self
        case .ActionTestableSummary:
            return xcparse.ActionTestableSummary.self
        case .ActionsInvocationMetadata:
            return xcparse.ActionsInvocationMetadata.self
        case .ActionsInvocationRecord:
            return xcparse.ActionsInvocationRecord.self
        case .ActivityLogCommandInvocationSection:
            return xcparse.ActivityLogCommandInvocationSection.self
        case .ActivityLogMajorSection:
            return xcparse.ActivityLogMajorSection.self
        case .ActivityLogMessage:
            return xcparse.ActivityLogMessage.self
        case .ActivityLogMessageAnnotation:
            return xcparse.ActivityLogMessageAnnotation.self
        case .ActivityLogSection:
            return xcparse.ActivityLogSection.self
        case .ActivityLogTargetBuildSection:
            return xcparse.ActivityLogTargetBuildSection.self
        case .ActivityLogUnitTestSection:
            return xcparse.ActivityLogUnitTestSection.self
        case .ArchiveInfo:
            return xcparse.ArchiveInfo.self
        case .Array:
            return xcparse.XCResultArrayValue<XCResultObject>.self
        case .Bool:
            return xcparse.XCResultValueType.self
        case .CodeCoverageInfo:
            return xcparse.CodeCoverageInfo.self
        case .Date:
            return xcparse.XCResultValueType.self
        case .DocumentLocation:
            return xcparse.DocumentLocation.self
        case .Double:
            return xcparse.XCResultValueType.self
        case .EntityIdentifier:
            return xcparse.EntityIdentifier.self
        case .Int:
            return xcparse.XCResultValueType.self
        case .IssueSummary:
            return xcparse.IssueSummary.self
        case .ObjectID:
            return xcparse.ObjectID.self
        case .Reference:
            return xcparse.Reference.self
        case .ResultIssueSummaries:
            return xcparse.ResultIssueSummaries.self
        case .ResultMetrics:
            return xcparse.ResultMetrics.self
        case .SortedKeyValueArray:
            return AnyObject.self
        case .SortedKeyValueArrayPair:
            return AnyObject.self
        case .String:
            return xcparse.XCResultValueType.self
        case .TestFailureIssueSummary:
            return xcparse.TestFailureIssueSummary.self
        case .TypeDefinition:
            return xcparse.TypeDefinition.self
        }
    }
}

extension KeyedDecodingContainer {
    func decodeXCResultType<T: Codable>(forKey key: KeyedDecodingContainer<K>.Key) throws -> T {
        let resultValueType = try self.decode(XCResultValueType.self, forKey: key)
        return resultValueType.getValue() as! T
    }
    
    func decodeXCResultTypeIfPresent<T: Codable>(forKey key: KeyedDecodingContainer<K>.Key) throws -> T? {
        let resultValueType = try self.decodeIfPresent(XCResultValueType.self, forKey: key)
        return resultValueType?.getValue() as! T?
    }
    
    func decodeXCResultObject<T: Codable>(forKey key: K) throws -> T {
        let resultObject = try self.decode(XCResultObject.self, forKey: key)
        if let type = resultObject.type.getType() as? T.Type {
            return try self.decode(type.self, forKey: key)
        } else {
            return try self.decode(T.self, forKey: key)
        }
    }
    
    func decodeXCResultObjectIfPresent<T: Codable>(forKey key: K) throws -> T? {
        let resultObject = try self.decodeIfPresent(XCResultObject.self, forKey: key)
        if let type = resultObject?.type.getType() as? T.Type {
            return try self.decode(type.self, forKey: key)
        } else {
            return nil
        }
    }
    
    /// Decode a heterogeneous list of objects for a given family.
    /// - Parameters:
    ///     - family: The ClassFamily enum for the type family.
    ///     - key: The CodingKey to look up the list in the current container.
    /// - Returns: The resulting list of heterogeneousType elements.
    func decode<T : Codable, U : ClassFamily>(family: U.Type, forKey key: K) throws -> [T] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        var list = [T]()
        var tmpContainer = container
        while !container.isAtEnd {
            let resultObj = try container.decode(XCResultObject.self)
            if let type = resultObj.type.getType() as? T.Type {
                list.append(try tmpContainer.decode(type))
            }
        }
        return list
    }
}

extension JSONDecoder {
    /// Decode a heterogeneous list of objects.
    /// - Parameters:
    ///     - family: The ClassFamily enum type to decode with.
    ///     - data: The data to decode.
    /// - Returns: The list of decoded objects.
    func decode<T: ClassFamily, U: Decodable>(family: T.Type, from data: Data) throws -> [U] {
        return try self.decode([ClassWrapper<T, U>].self, from: data).compactMap { $0.object }
    }
    
    private class ClassWrapper<T: ClassFamily, U: Decodable>: Decodable {
        /// The family enum containing the class information.
        let family: T
        /// The decoded object. Can be any subclass of U.
        let object: U?
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Discriminator.self)
            // Decode the family with the discriminator.
            family = try container.decode(T.self, forKey: T.discriminator)
            // Decode the object by initialising the corresponding type.
            if let type = family.getType() as? U.Type {
                object = try type.init(from: decoder)
            } else {
                object = nil
            }
        }
    }
}

