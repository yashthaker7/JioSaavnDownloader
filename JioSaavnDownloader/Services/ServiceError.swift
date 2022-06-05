//
//  ServiceError'.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import Foundation
import Alamofire

struct ServiceError: Error, LocalizedError {
    
    enum ErrorLocalizedDescription: String {
        case noResponse                         = "No response."
        case songIdNotFound                     = "Song id not found."
        case somethingWentWrong                 = "Something went wrong."
        case invalidURL                         = "Invalid URL."
        case errorWhileDownloading              = "Error while downloading."
    }
    
    enum ResponseErrorCode: Int {
        case BAD_REQUEST            = 400
        case UNAUTHORIZED           = 401
        case CONFLICT               = 409
        case UNPROCESSABLE_ENTITY   = 422
        case INTERNAL_SERVER_ERROR  = 500
        case SERVICE_UNAVAILABLE    = 503
    }
    
    var code: Int = 0
    private var description: String
    
    init?(code: Int, message: String) {
        guard let _ = ResponseErrorCode(rawValue: code) else { return nil }
        self.code = code
        self.description = message
    }
    
    init(_ afError: AFError) {
        switch afError {
        case .sessionTaskFailed(error: let error):
            self.code = (error as NSError).code
            self.description = error.localizedDescription
        default:
            self.code = (afError as NSError).code
            self.description = afError.localizedDescription
        }
    }
    
    init(_ error: Error) {
        self.code = (error as NSError).code
        self.description = error.localizedDescription
    }
    
    init(_ errorLocalizedDescription: ErrorLocalizedDescription) {
        self.description = errorLocalizedDescription.rawValue
    }
    
    init(_ localizedDescription: String) {
        self.description = localizedDescription
    }
    
    public var localizedDescription: String { return description }
    
    public var errorDescription: String? { return description }
}

