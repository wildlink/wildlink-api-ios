//
//  Wildlink.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation
import Alamofire

public protocol WildlinkDelegate: AnyObject {
    func didReceive(deviceToken: String)
    func didReceive(deviceKey: String)
    func didReceive(deviceId: UInt64)
}

// List of possible Error cases from the Wildlink SDK.
public struct WildlinkError: Error {
    public enum WildlinkErrorKind: Error {
        case invalidURL
        case invalidResponse
        case serverError(Error)
    }
    
    public let errorData: [String : Any]
    public let kind: WildlinkErrorKind
}

// Enum to be used when requesting segmented query results.
public enum TimePeriod {
    case hour
    case day
    case month
    case year
}

public enum WildlinkSortBy: String {
    case id = "id"
    case name = "name"
    case disabled = "disabled"
    case featured = "featured"
}

public enum WildlinkSortOrder: String {
    case ascending = "asc"
    case descending = "desc"
}

public class Wildlink: RequestInterceptor {
    //private variables/methods
    internal typealias RefreshCompletion = (_ succeeded: Bool, _ deviceToken: String?, _ deviceKey: String?, _ deviceId: UInt64?) -> Void
    internal typealias RequestRetryCompletion = (RetryResult) -> Void
    
    internal let lock = NSLock()
    internal let decoder = JSONDecoder()
    
    internal var baseUrl: URL
    internal var deviceToken = ""
    internal var deviceKey: String?
    internal var deviceId: UInt64?
    internal var senderToken = ""
    static internal var apiKey = ""
    static internal var appID = ""
    internal var isRefreshing = false
    internal var requestsToRetry: [RequestRetryCompletion] = []
    internal let queue = DispatchQueue(label: "com.wildlink.response-queue", qos: .utility, attributes: [.concurrent])
    
    private let headers = HTTPHeaders(["Content-Type": "application/json"])
    
    //public variables, methods
    public static let shared = Wildlink()
    public weak var delegate: WildlinkDelegate?
    
    internal init(){
        self.baseUrl = APIConstants.baseUrlProd
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // Initialize the Wildlink SDK using an AppID and App Secret. Optionally accepts a UUID previously given by the SDK.
    //
    // - parameter appId:               The identifier used with this
    // - parameter appSecret:           The vendor secret key provided by Wildlink to the consuming developer.
    // - parameter wildlinkDeviceToken: The Wildlink DeviceToken passed back by a previous call to initialize. This allows
    //                                  the consuming application to tie sessions together across runs. `nil` by default.
    // - parameter wildlinkDeviceKey:   The Wildlink DeviceKey passed back by a previous call to initialize. This allows
    //                                  the consuming application to request a new DeviceToken if the old one is lost, while
    //                                  still maintaining the history of this user (not considered a new device). `nil` by
    //                                  default.
    public func initialize(appId: String, appSecret: String, wildlinkDeviceToken: String? = nil, wildlinkDeviceKey: String? = nil) {
        self.baseUrl = APIConstants.baseUrlProd
        self.deviceKey = wildlinkDeviceKey
        Wildlink.appID = appId
        Wildlink.apiKey = appSecret
        guard let token = wildlinkDeviceToken else {
            refreshDeviceToken { (success, token, key, id) in
                if success, let token = token {
                    self.update(token: token)
                }
                if success, let key = key {
                    self.update(key: key)
                }
                if success, let id = id {
                    self.update(id: id)
                }
            }
            return
        }
        update(token: token)
    }
    
    // Generate a Wildlink URL string from a URL object.
    //
    // - parameter originalURL:     The URL object the user would like to convert to a Wildlink.
    // - parameter completion:      Completion closure to be called once the URL is converted to a Wildlink
    public func createVanityURL(from originalURL: URL, _ completion: @escaping(_ url: VanityURL?, _ error: WildlinkError?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("vanity")
        
        // JSON Body
        let parameters: [String : Any] = [
            "URL": originalURL.absoluteString
        ]
        
        AF.request(queryUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: self)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: VanityURL.self, decoder: decoder) { [unowned self] response in
                switch response.result {
                case .success(let url):
                    completion(url, nil)
                case .failure(let error):
                    completion(nil, generateWildlinkError(from: response.data, with: error))
                }
            }
    }
    
    // Generate a Wildlink URL string from a string object. Helper wrapper around the URL version.
    //
    // - parameter originalURL:     The URL object the user would like to convert to a Wildlink.
    // - parameter completion:      Completion closure to be called once the URL is converted to a Wildlink
    public func createVanityURL(from originalURL: String, _ completion: @escaping (_ url: VanityURL?, _ error: WildlinkError?) -> ()) {
        guard let url = URL(string: originalURL) else {
            completion(nil, WildlinkError(errorData: [:], kind: .invalidURL))
            return
        }
        createVanityURL(from: url, completion)
    }
    
    // Get the commission statistics for this user.
    //
    // - parameter completion:      Completion closure to be called once the commission statisticas are computed and downloaded.
    public func getCommissionSummary(_ completion: @escaping (_ stats: CommissionStats?, _ error: WildlinkError?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("device/stats/commission-summary")
        
        AF.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers, interceptor: self)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: CommissionStats.self, decoder: decoder) { [unowned self] response in
                switch response.result {
                case .success(let stats):
                    completion(stats, nil)
                    self.parseHeaders(from: response.response)
                case .failure(let error):
                    completion(nil, generateWildlinkError(from: response.data, with: error))
                }
            }
    }
    
    // Get the details about commissions earned by the user.
    //
    // - parameter completion:      Completion closure to be called when the results have been downloaded.
    public func getCommissionDetails(_ completion: @escaping (_ details: [CommissionDetail], _ error: WildlinkError?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("device/stats/commission-detail")
        
        AF.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers, interceptor: self)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: [CommissionDetail].self, decoder: decoder) { [unowned self] response in
                switch response.result {
                case .success(let detailsArray):
                    completion(detailsArray, nil)
                case .failure(let error):
                    completion([], self.generateWildlinkError(from: response.data, with: error))
                }
            }
    }
    
    public func searchMerchants(ids: [String], names: [String], q: String?, disabled: Bool?, featured: Bool?, sortBy: WildlinkSortBy?, sortOrder: WildlinkSortOrder?, limit: Int?, _ completion: @escaping (_ merchants: [Merchant], _ error: WildlinkError?) -> ()) {
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        
        //build the id query section
        let idQueries = ids.compactMap { URLQueryItem(name: "id", value: $0) }
        //build the name query section
        let nameQueries = names.compactMap{ URLQueryItem(name: "name", value: $0) }
        //combine them. NOTE: possible empty array here
        var queryItems = idQueries + nameQueries
        //if we have a q, add it to the query array
        if let q = q {
            queryItems.append(URLQueryItem(name: "q", value: q))
        }
        //if we were passed a disabled flag, build that
        if let disabled = disabled {
            queryItems.append(URLQueryItem(name: "disabled", value: disabled ? "true" : "false"))
        }
        //if we were passed a featured flag, build that
        if let featured = featured {
            queryItems.append(URLQueryItem(name: "featured", value: featured ? "true" : "false"))
        }
        //if sortBy was passed in, build it
        if let sortBy = sortBy {
            queryItems.append(URLQueryItem(name: "sort_by", value: sortBy.rawValue))
        }
        //if sortOrder was passed in, build it
        if let sortOrder = sortOrder {
            queryItems.append(URLQueryItem(name: "sort_order", value: sortOrder.rawValue))
        }
        components?.queryItems = queryItems
        //have to put the /v2 in here because .path overrides the
        //path component in the constructor
        components?.path = "/v2/merchant"
        let queryUrl = components!.url!
        
        AF.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers, interceptor: self)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: MerchantList.self, decoder: decoder) { [unowned self] response in
                switch response.result {
                case .success(let merchantList):
                    completion(merchantList.merchants, nil)
                case .failure(let error):
                    completion([], generateWildlinkError(from: response.data, with: error))
                }
            }
    }
    
    public func getMerchantBy(_ id: String, _ completion: @escaping (_ merchant: Merchant?, _ error: WildlinkError?) -> ()) {
        let queryUrl = baseUrl.appendingPathComponent("merchant/\(id)")
        
        AF.request(queryUrl, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers, interceptor: self)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: Merchant.self, decoder: decoder) { [unowned self] response in
                switch response.result {
                case .success(let merchant):
                    completion(merchant, nil)
                    self.parseHeaders(from: response.response)
                case .failure(let error):
                    completion(nil, generateWildlinkError(from: response.data, with: error))
                }
            }
    }
    
    // MARK: - RequestInterceptor
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseUrl.absoluteString) {
            
            let iso8601DateString = Date().iso8601
            let authString = getAuthorizationString(dateString: iso8601DateString, deviceToken: deviceToken, senderToken: senderToken)
            
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
            let fullVersionString = "\(version).\(build)"
            let device = UIDevice.current.name
            let os = UIDevice.current.systemVersion
            let userAgent = "WildlinkSDK/\(fullVersionString) (\(device)) iOS \(os)"
            
            urlRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            urlRequest.setValue(authString, forHTTPHeaderField: "Authorization")
            urlRequest.setValue(iso8601DateString, forHTTPHeaderField: "X-WF-DateTime")
        }
        completion(.success(urlRequest))
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        lock.lock() ; defer { lock.unlock() }

        if let response = request.task?.response as? HTTPURLResponse,
            //only retry on 5XX errors
            500..<600 ~= response.statusCode {
            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshDeviceToken { [unowned self] succeeded, deviceToken, deviceKey, deviceId  in
                    lock.lock() ; defer { lock.unlock() }

                    if let localDeviceToken = deviceToken {
                        self.deviceToken = localDeviceToken
                    }

                    requestsToRetry.forEach { $0(.doNotRetry) }
                    requestsToRetry.removeAll()
                }
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
    
    // MARK: - Private - Refresh Device Token
    
    // Requests a device token.
    // Reference: https://github.com/wildlink/deviceapi
    //
    internal func refreshDeviceToken(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let queryUrl = baseUrl.appendingPathComponent("device")
        
        // JSON Body
        var parameters: [String : Any] = [
            "OS": UIDevice.current.systemName
        ]
        //if we have a device key, append it to the requestb
        if let key = deviceKey {
            parameters["DeviceKey"] = key
        }
        
        AF.request(queryUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: self)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: Device.self, decoder: decoder) { [unowned self] response in
                switch response.result {
                case .success(let device):
                    completion(true, device.token, device.key, device.id)
                case .failure(let error):
                    print(error)
                    completion(false, nil, nil, nil)
                }
                self.isRefreshing = false
            }
    }
    
    internal func parseHeaders(from response: HTTPURLResponse?) {
        guard let localResponse = response else { return }
        
        if let localDeviceToken = localResponse.allHeaderFields["x-wf-devicetoken"],
            let token = localDeviceToken as? String {
            update(token: token)
        }
    }
    
    // MARK - Helper functions
    
    // Helper function to store an updated token in memory and tell the delegate about it (if set)
    //
    // - parameter token:               The new token
    func update(token: String) {
        self.deviceToken = token
        Wildlink.shared.delegate?.didReceive(deviceToken: token)
    }
    
    // Helper function to store an updated device key in memory and tell the delegate about it (if set)
    //
    // - parameter key:                 The new Wildlink device key
    func update(key: String) {
        self.deviceKey = key
        Wildlink.shared.delegate?.didReceive(deviceKey: key)
    }
    
    // Helper function to store an updated device identifier in memory and tell the delegate about it (if set)
    //
    // - parameter id:                  The new device ID
    func update(id: UInt64) {
        self.deviceId = id
        Wildlink.shared.delegate?.didReceive(deviceId: id)
    }

    // Helper function to generate the WildlinkError associated with a given API request
    func generateWildlinkError(from response: Data?, with error: Error) -> WildlinkError {
        guard let data = response, let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else {
            return WildlinkError(errorData: [:], kind: .serverError(error))
        }
        Logger.error("\(String(describing: jsonDict))")
        return WildlinkError(errorData: jsonDict, kind: .serverError(error))
    }
}

extension Wildlink {
    internal func getSignatureKey(dateString: String, deviceToken: String? = nil, senderToken: String? = nil) -> String {
        
        let stringToSign = "\(dateString)\n\(deviceToken ?? "")\n\(senderToken ?? "")\n"
        
        let secret = Wildlink.apiKey
        let hmac256 = stringToSign.digestHMac256(key: secret)
        
        return hmac256
    }
    
    internal func getAuthorizationString(dateString: String, deviceToken: String? = nil, senderToken: String? = nil) -> String {
        
        let hmac256 = getSignatureKey(dateString: dateString, deviceToken: deviceToken, senderToken: senderToken)
        let appToken = Wildlink.appID
        
        return "WFAV1 \(appToken):\(hmac256):\(deviceToken ?? ""):\(senderToken ?? "")"
    }
}
