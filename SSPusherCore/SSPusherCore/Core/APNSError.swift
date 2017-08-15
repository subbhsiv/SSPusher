//
//  APNSError.swift
//  SSPusherCore
//
//  Created by Subbhaash Siva on 8/15/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

public enum APNSError: Int {
    case badCertificateEnvironment
    case badCollapseId
    case badDeviceToken
    case badExpirationDate
    case badMessageId
    case badPath
    case badPriority
    case badTopic
    case deviceTokenNotForTopic
    case duplicateHeaders
    case expiredProviderToken
    case forbidden
    case idleTimeout
    case invalidProviderToken
    case missingDeviceToken
    case missingProviderToken
    case missingTopic
    case payloadEmpty
    case serviceUnavailable
    case tooManyProviderTokenUpdates
    case topicDisallowed
    case unknown
    case unregistered
    case badRequest = 400
    case badCertificate = 403
    case methodNotAllowed = 405
    case deviceTokenNoLongerActive = 410
    case payloadTooLarge = 413
    case tooManyRequests = 429
    case internalServerError = 500
    case shutdown = 503

    internal static func apnsErrorFromError(_ error: NSError) -> APNSError {
        return apnsErrorFromCode(code: error.code, string: error.localizedDescription)
    }
    
    private static func apnsErrorFromCode(code: Int, string: String) -> APNSError {
        if code == 0 || string.isEmpty {
            return .unknown
        }
        
        switch (code, string) {
        case (400, "BadCollapseId"):
            return .badCollapseId
        case (400, "BadDeviceToken"):
            return .badDeviceToken
        case (400, "BadExpirationDate"):
            return .badExpirationDate
        case (400, "BadMessageId"):
            return .badMessageId
        case (400, "BadPriority"):
            return .badPriority
        case (400, "BadTopic"):
            return .badTopic
        case (400, "DeviceTokenNotForTopic"):
            return .deviceTokenNotForTopic
        case (400, "DuplicateHeaders"):
            return .duplicateHeaders
        case (400, "IdleTimeout"):
            return .idleTimeout
        case (400, "MissingDeviceToken"):
            return .missingDeviceToken
        case (400, "MissingTopic"):
            return .missingTopic
        case (400, "PayloadEmpty"):
            return .payloadEmpty
        case (400, "TopicDisallowed"):
            return .payloadTooLarge
        case (403, "BadCertificate"):
            return .badCertificate
        case (403, "BadCertificateEnvironment"):
            return .badCertificateEnvironment
        case (403, "ExpiredProviderToken"):
            return .expiredProviderToken
        case (403, "Forbidden"):
            return .forbidden
        case (403, "InvalidProviderToken"):
            return .invalidProviderToken
        case (403, "MissingProviderToken"):
            return .missingProviderToken
        case (404,  "BadPath"):
            return .badPath
        case (405,   "MethodNotAllowed"):
            return .methodNotAllowed
        case (410,   "Unregistered"):
            return .unregistered
        case (413,   "PayloadTooLarge"):
            return .payloadTooLarge
        case (429,   "TooManyProviderTokenUpdates"):
            return .tooManyProviderTokenUpdates
        case (429,   "TooManyRequests"):
            return .tooManyRequests
        case (500,   "InternalServerError"):
            return .internalServerError
        case (503,   "ServiceUnavailable"):
            return .serviceUnavailable
        case (503,   "Shutdown"):
            return .shutdown
        default:
            return .unknown
        }
    }
    
    public var description: String {
        switch self {
        case .badCertificate:
            return "The certificate was bad."
        case .badCertificateEnvironment:
            return "The client certificate was for the wrong environment."
        case .badCollapseId:
            return "The collapse identifier exceeds the maximum allowed size"
        case .badDeviceToken:
            return "The specified device token was bad. Verify that the request contains a valid token and that the token matches the environment."
        case .badExpirationDate:
            return "The apns-expiration value is bad."
        case .badMessageId:
            return "The apns-id value is bad."
        case .badPath:
            return "The request contained a bad :path value."
        case .badPriority:
            return "The apns-priority value is bad."
        case .badRequest:
            return "Bad Request"
        case .badTopic:
            return "The apns-topic was invalid."
        case .deviceTokenNoLongerActive:
            return "The device token is no longer active for the topic."
        case .deviceTokenNotForTopic:
            return "The device token does not match the specified topic."
        case .duplicateHeaders:
            return "One or more headers were repeated."
        case .expiredProviderToken:
            return "The provider token is stale and a new token should be generated."
        case .forbidden:
            return "The specified action is not allowed."
        case .idleTimeout:
            return "Idle time out."
        case .internalServerError:
            return "An internal server error occurred."
        case .invalidProviderToken:
            return "The provider token is not valid or the token signature could not be verified."
        case .methodNotAllowed:
            return "The specified :method was not POST."
        case .missingDeviceToken:
            return "The device token is not specified in the request :path. Verify that the :path header contains the device token."
        case .missingProviderToken:
            return "No provider certificate was used to connect to APNs and Authorization header was missing or no provider token was specified."
        case .missingTopic:
            return "The apns-topic header of the request was not specified and was required. The apns-topic header is mandatory when the client is connected using a certificate that supports multiple topics."
        case .payloadEmpty:
            return "The message payload was empty."
        case .payloadTooLarge:
            return "The message payload was too large. See Creating the Remote Notification Payload for details on maximum payload size."
        case .serviceUnavailable:
            return "The service is unavailable."
        case .shutdown:
            return "The server is shutting down."
        case .tooManyProviderTokenUpdates:
            return "The provider token is being updated too often."
        case .tooManyRequests:
            return "Too many requests were made consecutively to the same device token."
        case .topicDisallowed:
            return "Pushing to this topic is not allowed."
        case .unknown:
            return "Error occurred while sending push notification."
        case .unregistered:
            return "The device token is inactive for the specified topic."
        }
    }
}
