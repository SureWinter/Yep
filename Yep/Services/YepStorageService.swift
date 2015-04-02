//
//  YepStorageService.swift
//  Yep
//
//  Created by kevinzhow on 15/3/30.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import Foundation
import MobileCoreServices.UTType
import AFNetworking


/**
    Struct of S3 UploadParams
*/
struct S3UploadParams {
    let url: String
    let key: String
    let acl: String
    let algorithm: String
    let signature: String
    let date: String
    let credential: String
    let encodedPolicy: String
}

/**
    Upload file to S3 with upload Params

    Use filePath or fileData

    :param: filePath  File Path, can be nil
    :param: fileData  File NSData, can be nil
    :param: mimetype  File type like image/png

    :returns: Bool  upload status
*/

func uploadFileToS3(inFilePath filePath: String?, orFileData fileData: NSData?, #mimeType: String, #s3UploadParams: S3UploadParams, #completion: (Bool, NSError?) -> ()) {

    let parameters = [
        "key": s3UploadParams.key,
        "acl": s3UploadParams.acl,
        "X-Amz-Algorithm": s3UploadParams.algorithm,
        "X-Amz-Signature": s3UploadParams.signature,
        "X-Amz-Date": s3UploadParams.date,
        "X-Amz-Credential": s3UploadParams.credential,
        "Policy": s3UploadParams.encodedPolicy
    ]
    
    let filename = "attachment"

    let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST", URLString: s3UploadParams.url, parameters: parameters, constructingBodyWithBlock: { formData in
        
        if let filePath = filePath {
            formData.appendPartWithFileURL(NSURL(fileURLWithPath: filePath)!, name: "file", fileName: filename, mimeType: mimeType, error: nil)

        } else if let fileData = fileData {
            formData.appendPartWithFileData(fileData, name: "file", fileName: filename, mimeType: mimeType)
        }
        
    }, error: nil)
    
    let manager = AFURLSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
    manager.responseSerializer = AFHTTPResponseSerializer()

    var progress: NSProgress?
    
    let uploadTask = manager.uploadTaskWithStreamedRequest(request, progress: &progress, completionHandler: { (response, responseObject, error) in

        if (error != nil) {
            println("Error \(error.description) \(response) \(responseObject)")
            if let data = responseObject as? NSData {
                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("\(string)")
            }
            completion(false, error)

        } else {
            println("Upload \(response) \(responseObject)")
            completion(true, nil)
        }
    })

    uploadTask.resume()
}

// MARK: Upload

extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// :param: string       The string to be added to the `NSMutableData`.
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        appendData(data!)
    }
}



/// Create boundary string for multipart/form-data request
///
/// :returns:            The boundary string that consists of "Boundary-" followed by a UUID string.

func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().UUIDString)"
}

/// Get S3 Private Message upload params
///
/// You can use this in Message Attachment
///
/// :S3UploadParams:     The Upload Params

func s3PrivateUploadParams(#failureHandler: ((Reason, String?) -> ())?, #completion: (S3UploadParams) -> ()) {

    s3UploadParams("/api/v1/attachments/s3_upload_form_fields", failureHandler: { (reason, error)  in
        if let failureHandler = failureHandler {
            failureHandler(reason, error)
        } else {
            defaultFailureHandler(reason, error)
        }
        
    }, completion: { S3PrivateUploadParams in
        completion(S3PrivateUploadParams)
    })
}

/// Get S3 public upload params
///
/// You can use this in Avatar
///
/// :S3UploadParams:     The Upload Params

func s3PublicUploadParams(#failureHandler: ((Reason, String?) -> ())?, #completion: (S3UploadParams) -> ()) {

    s3UploadParams("/api/v1/attachments/s3_upload_public_form_fields", failureHandler: { (reason, error)  in
        if let failureHandler = failureHandler {
            failureHandler(reason, error)
        } else {
            defaultFailureHandler(reason, error)
        }
        
    }, completion: { S3PublicUploadParams in
        completion(S3PublicUploadParams)
    })
}

/// Get S3  upload params
///
///
/// :S3UploadParams:     The Upload Params

private func s3UploadParams(url: String ,#failureHandler: ((Reason, String?) -> ())?, #completion: S3UploadParams -> Void) {
    
    let parse: JSONDictionary -> S3UploadParams? = { data in
        //println("s3FormData: \(data)")
        
        if let options = data["options"] as? JSONDictionary {
            if
                let encodedPolice = options["encoded_policy"] as? String,
                let key = options["key"] as? String,
                let signature = options["signature"] as? String,
                let urlString = options["url"] as? String,
                let policy = options["policy"] as? JSONDictionary,
                let conditions = policy["conditions"] as? [JSONDictionary] {

                    var acl: String?
                    var credential: String?
                    var algorithm: String?
                    var date: String?
                    
                    for dict in conditions {
                        for (key, value) in dict {
                            switch key {
                            case "acl":
                                acl = value as? String
                            case "x-amz-credential":
                                credential = value as? String
                            case "x-amz-algorithm":
                                algorithm = value as? String
                            case "x-amz-date":
                                date = value as? String
                            default:
                                break
                            }
                        }
                    }
                    
                    if let acl = acl, let credential = credential, let algorithm = algorithm, let date = date {
                        return S3UploadParams(url: urlString, key: key, acl: acl, algorithm: algorithm, signature: signature, date: date, credential: credential, encodedPolicy: encodedPolice)
                    }
            }
        }
    
        return nil
    }
    
    let resource = authJsonResource(path: url, method: .GET, requestParameters:[:], parse: parse)
    
    if let failureHandler = failureHandler {
        apiRequest({_ in}, baseURL, resource, failureHandler, completion)
    } else {
        apiRequest({_ in}, baseURL, resource, defaultFailureHandler, completion)
    }
}
